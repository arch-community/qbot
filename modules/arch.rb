# frozen_string_literal: true

require_relative 'arch/presenters'

# every day at 3 AM:
QBot.scheduler.cron '0 3 * * *' do
  UpdateArchReposJob.perform_later
end

# Arch Linux wiki and package searching commands.
module Arch
  extend Discordrb::Commands::CommandContainer

  command :archwiki, {
    aliases: %i[aw arch-chan-uwu], # :3
    help_available: true,
    usage: '.aw <query>',
    min_args: 1
  } do |event, *_|
    query = after_nth_word(1, event.text)
    page = QBot::ArchWiki.find_page(query)

    next embed t('arch.wiki.no-results') unless page

    embed do |m|
      m.title = page.title
      m.description = page.url
    end
  end

  def self.package_field(pkg)
    Presenters.package_field(pkg)
  end

  def self.package_search_embed(query, pkgs)
    data = Presenters.package_search_embed_data(query, pkgs)
    embed do |m|
      m.title = data[:title]
      m.fields = data[:fields]
    end
  end

  command :packagesearch, {
    aliases: [:ps],
    help_available: true,
    description: 'Searches the Arch repositories for a package',
    usage: '.ps <query>',
    min_args: 1
  } do |event, *_|
    query = after_nth_word(1, event.text)

    results = ArchRepos::Index.instance.pkg_query(query)
    next embed t('arch.ps.no-results') if results.empty?

    package_search_embed(query, results)
  end

  def self.package_embed(pkg)
    data = Presenters.package_embed_data(pkg)
    embed do |m|
      m.color = data[:color]
      m.title = data[:title]
      m.url = data[:url]
      m.description = data[:description]
      m.fields = data[:fields]
      m.footer = data[:footer]
      m.timestamp = data[:timestamp]
    end
  end

  command :package, {
    aliases: [:p],
    help_available: true,
    usage: '.p <pkgname>',
    min_args: 1,
    max_args: 1
  } do |_, name|
    pkg = ArchRepos::DBCache.instance.package(name)
    next embed t('arch.package.not-found') unless pkg

    package_embed(pkg)
  end
end
