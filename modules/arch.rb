# frozen_string_literal: true

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
    page = ArchWiki.find_page(query)

    next embed t('arch.wiki.no-results') unless page

    embed do |m|
      m.title = page.title
      m.description = page.url
    end
  end

  def self.package_field(pkg)
    pkg => {repo:, name:, version:, desc:}
    date = pkg.builddate.strftime('%Y-%m-%d')

    {
      name: "#{repo}/#{name}",
      value: <<~VAL
        #{desc}
        #{t('arch.ps.result-footer', version, date, pkg.web_url)}
      VAL
    }
  end

  def self.package_search_embed(query, pkgs)
    embed do |m|
      m.title = t('arch.ps.title', query)
      m.fields = pkgs.first(5).map { package_field(_1) }
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

  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
  def self.package_embed(pkg)
    csize = pkg.csize.to_fs(:human_size)
    isize = pkg.isize.to_fs(:human_size)
    license = pkg.license.join(', ')

    embed do |m|
      m.color = 0x0088cc

      m.title = "#{pkg.repo}/#{pkg.name}"
      m.url = pkg.web_url
      m.description = pkg.desc

      m.fields = [
        { name: t('arch.package.url'), value: pkg.url },
        { name: t('arch.package.license'), value: license, inline: true },
        { name: t('arch.package.csize'), value: csize, inline: true },
        { name: t('arch.package.isize'), value: isize, inline: true },
        { name: t('arch.package.packager'), value: pkg.packager }
      ]

      m.footer = { text: t('arch.package.version', pkg.version) }
      m.timestamp = pkg.builddate
    end
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize

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
