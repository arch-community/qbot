$mw = MediawikiApi::Client.new "https://wiki.archlinux.org/api.php"

if $config['wiki-username'] && $config['wiki-password']
  $mw.log_in $config['wiki-username'], $config['wiki-password']
end

def wiki_embed(channel, title)
  channel.send_embed do |m|
    m.title = "Arch Wiki: #{title}"
    m.description = "https://wiki.archlinux.org/index.php/#{title.split.join('_')}"
  end
end

def search_pkg(query)
  JSON.parse URI.open('https://www.archlinux.org/packages/search/json/?q='+query).read
end

module Arch
  extend Discordrb::Commands::CommandContainer

  command :aw, {
    help_available: true,
    description: 'Searches the Arch Wiki',
    usage: '.aw <query>',
    min_args: 1
  } do |event, *qs|
    query = qs.join(' ')
    # Check if the page exists
    q = ($mw.query titles: query).data

    if !q['pages']['-1'] # If it exists:
      _, pg = q['pages'].first
      # Embed a link to it
      wiki_embed(event.channel, pg['title'])
    else # Search the wiki for the query
      sq = ($mw.query list: 'search', srsearch: query).data
      if sq['searchinfo']['totalhits'] < 1 # If not found, notify
        event.channel.send_embed do |m|
          m.title = 'No results found'
        end
      else # Embed a link to the first search result
        firstres = sq['search'][0]
        wiki_embed(event.channel, firstres['title'])
      end
    end
  end

  command :ps, {
    help_available: true,
    description: 'Searches the Arch repositories for a package',
    usage: '.ps <query>',
    min_args: 1
  } do |event, *qs|
    query = qs.join(' ')
    response = search_pkg(query)

    res = response['results']
    if res.empty?
      event.channel.send_embed do |m|
        m.title = 'No results found'
      end
      return
    end


    documents = []
    corpus = res.map.with_index { |r, idx|
      documents[idx] = TfIdfSimilarity::Document.new("#{r['repo']} #{r['pkgname']} #{r['pkgdesc']}")
    }

    query_document = TfIdfSimilarity::Document.new(query)
    corpus << query_document

    model = TfIdfSimilarity::BM25Model.new(corpus, library: :narray)

    matrix = model.similarity_matrix

    ordered_results = res.map.with_index.sort_by { |r, idx|
      matrix[
        model.document_index(documents[idx]),
        model.document_index(query_document)
      ]
    }

    event.channel.send_embed do |m|
      m.title = "Search results for #{query}"
      m.fields = ordered_results.first(5).map { |r, idx|
        {
          name: "#{r['repo']}/#{r['pkgname']}",
          value: <<-END
            #{r['pkgdesc']}
            version **#{r['pkgver']}** | last update **#{Time.parse(r['last_update']).strftime('%Y-%m-%d')}** | [web link](https://www.archlinux.org/packages/#{r['repo']}/#{r['arch']}/#{r['pkgname']})
          END
        }
      }
    end

  end
end
