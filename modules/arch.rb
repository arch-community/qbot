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

def sort_results(res, query)
    corpus = res.map { |r|
      keywords = [r['repo'], r['pkgname'], r['pkgname'].split('-') * 2].flatten.join(' ')
      TfIdfSimilarity::Document.new("#{keywords} #{r['pkgdesc']}")
    }
    corpus << TfIdfSimilarity::Document.new(query)

    model = TfIdfSimilarity::BM25Model.new(corpus, library: :narray)

    matrix = model.similarity_matrix

    return res.map.with_index.sort_by { |r, idx|
      matrix[model.document_index(corpus[idx]), model.document_index(corpus.last)]
    }.map(&:first)
end

module Arch
  extend Discordrb::Commands::CommandContainer

  command :aw, {
    help_available: true,
    description: 'Searches the Arch Wiki',
    usage: '.aw <query>',
    min_args: 1
  } do |event, *qs|
    log(event)

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
    log(event)

    query = qs.join(' ')
    response = search_pkg(query)

    # Error if no results found
    res = response['results']
    if res.empty?
      event.channel.send_embed { _1.title = 'No results found' }
      return
    end

    ordered_results = sort_results(res, query)

    # Embed the search results
    event.channel.send_embed do |m|
      m.title = "Search results for #{query}"
      m.fields = ordered_results.first(5).map { |r|
        s_ver = r['pkgver']
        s_time = Time.parse(r['last_update']).strftime('%Y-%m-%d')
        s_url = "https://www.archlinux.org/packages/#{r['repo']}/#{r['arch']}/#{r['pkgname']}"

        {
          name: "#{r['repo']}/#{r['pkgname']}",
          value: <<-END
            #{r['pkgdesc']}
            version **#{s_ver}** | last update **#{s_time}** | [web link](#{s_url})
          END
        }
      }
    end
  end

  command :p, {
    help_available: true,
    description: 'Shows info for a given package',
    usage: '.p <pkgname>',
    min_args: 1,
    max_args: 1
  } do |event, pn|
    log(event)


  end
end
