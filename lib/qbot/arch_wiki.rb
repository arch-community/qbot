# frozen_string_literal: true

##
# Arch wiki searching etc
module ArchWiki
  API_BASE = 'https://wiki.archlinux.org/api.php'

  # this lint is incorrect
  # rubocop: disable Style/BlockDelimiters
  PageInfo = Data.define(:title, :pageid, :url) do
    def self.query(pageid)
      res = ArchWiki.url_info(pageid)
      val = res['pages'].values.first

      title = val['title']
      url = val['canonicalurl']

      new(pageid:, title:, url:)
    end
  end
  # rubocop: enable Style/BlockDelimiters

  def self.client
    @client ||= MediawikiApi::Client.new(API_BASE)
  end

  def self.query(...)
    client.query(...).data
  end

  def self.prop(...)
    client.prop(...).data
  end

  def self.url_info(pageid)
    prop('info', inprop: 'url', pageids: pageid)
  end

  def self.find_exact_page(title)
    res = query(titles: title, inprop: 'url')

    return nil if res['pages'].key?('-1')

    res['pages'].values.first
  end

  def self.search_pages(srsearch, srlimit:)
    res = query(list: 'search', srsearch:, srlimit:)

    res['search']
  end

  def self.find_page(title)
    res = find_exact_page(title) || search_pages(title, srlimit: 1)&.first
    return nil unless res

    PageInfo.query(res['pageid'])
  end
end
