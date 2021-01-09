# frozen_string_literal: true

# Arch Linux wiki and package searching commands.
module Arch
  extend Discordrb::Commands::CommandContainer

  @wiki = MediawikiApi::Client.new 'https://wiki.archlinux.org/api.php'
  attr_accessor :wiki

  def self.wiki_login(username, password)
    @wiki.log_in(username, password)
  end

  def self.wiki_embed(channel, title)
    channel.send_embed do |m|
      m.title = "Arch Wiki: #{title}"
      m.description = "https://wiki.archlinux.org/index.php/#{title.split.join('_')}"
    end
  end

  def self.search_pkg(query)
    JSON.parse URI.open('https://www.archlinux.org/packages/search/json/?q=' + query).read
  end

  def self.mkcorpus(res)
    res.map do |r|
      keywords = [r['repo'], r['pkgname'], r['pkgname'].split('-') * 10].flatten.join(' ')
      TfIdfSimilarity::Document.new("#{keywords} #{r['pkgdesc']}")
    end
  end

  def self.sort_results(results, query)
    corpus = mkcorpus(results)
    corpus << TfIdfSimilarity::Document.new(query)

    model = TfIdfSimilarity::BM25Model.new(corpus, library: :narray)

    matrix = model.similarity_matrix

    results.map.with_index.sort_by do |_r, idx|
      matrix[model.document_index(corpus[idx]), model.document_index(corpus.last)]
    end.map(&:first)
  end

  command :archwiki, {
    aliases: [:aw, :'arch-chan-uwu'], # joke
    help_available: true,
    usage: '.aw <query>',
    min_args: 1
  } do |event, *qs|
    log(event)

    query = qs.join(' ')

    # Check if the page exists
    q = (@wiki.query titles: query).data

    if !q['pages']['-1']
      # If it exists:
      _, pg = q['pages'].first
      # Embed a link to it
      Arch.wiki_embed(event.channel, pg['title'])
    else
      # Search the wiki for the query
      sq = (@wiki.query list: 'search', srsearch: query).data

      if sq['searchinfo']['totalhits'] < 1
        # If not found, notify
        embed event, t('arch.wiki.no-results')
      else
        # Embed a link to the first search result
        firstres = sq['search'][0]
        wiki_embed event.channel, firstres['title']
      end
    end
  end

  command :packagesearch, {
    aliases: [:ps],
    help_available: true,
    description: 'Searches the Arch repositories for a package',
    usage: '.ps <query>',
    min_args: 1
  } do |event, *qs|
    log(event)

    query = qs.join(' ')
    response = Arch.search_pkg(query)

    # Error if no results found
    res = response['results']
    if res.empty?
      embed event, t('arch.ps.no-results')
      return
    end

    ordered_results = sort_results(res, query)

    # Embed the search results
    event.channel.send_embed do |m|
      m.title = t('arch.ps.title', query)
      m.fields = ordered_results.first(5).map do |r|
        ver = r['pkgver']
        time = Time.parse(r['last_update']).strftime('%Y-%m-%d')
        url = "https://www.archlinux.org/packages/#{r['repo']}/#{r['arch']}/#{r['pkgname']}"

        {
          name: "#{r['repo']}/#{r['pkgname']}",
          value: <<~VAL
            #{r['pkgdesc']}
            #{t 'arch.ps.version'} **#{ver}** | #{t 'arch.ps.last-update'} **#{time}** | [#{t 'arch.ps.link'}](#{url})
          VAL
        }
      end
    end
  end

  command :package, {
    aliases: [:package],
    help_available: true,
    usage: '.p <pkgname>',
    min_args: 1,
    max_args: 1
  } do |event, _pn|
    log(event)
    embed event, t('cfg.nyi')
  end
end

if QBot.config.wiki_username && QBot.config.wiki_password
  Arch.wiki_login(QBot.config.wiki_username, QBot.config.wiki_password)
end
