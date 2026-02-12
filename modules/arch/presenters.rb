# frozen_string_literal: true

module Arch
  ##
  # Presenter methods for Arch module embeds and formatting
  module Presenters
    ##
    # Format a package as a field for embed display
    def self.package_field(pkg)
      pkg => {repo:, name:, version:, desc:}
      date = pkg.builddate.strftime('%Y-%m-%d')

      {
        name: "#{repo}/#{name}",
        value: <<~VAL
          #{desc}
          #{QBot::Helpers.t('arch.ps.result-footer', version, date, pkg.web_url)}
        VAL
      }
    end

    ##
    # Build embed data structure for package search results
    def self.package_search_embed_data(query, pkgs)
      {
        title: QBot::Helpers.t('arch.ps.title', query),
        fields: pkgs.first(5).map { package_field(_1) }
      }
    end

    ##
    # Build embed data structure for package details
    def self.package_embed_data(pkg)
      csize = pkg.csize.to_fs(:human_size)
      isize = pkg.isize.to_fs(:human_size)
      license = pkg.license.join(', ')

      {
        color: 0x0088cc,
        title: "#{pkg.repo}/#{pkg.name}",
        url: pkg.web_url,
        description: pkg.desc,
        fields: [
          { name: QBot::Helpers.t('arch.package.url'), value: pkg.url },
          { name: QBot::Helpers.t('arch.package.license'), value: license, inline: true },
          { name: QBot::Helpers.t('arch.package.csize'), value: csize, inline: true },
          { name: QBot::Helpers.t('arch.package.isize'), value: isize, inline: true },
          { name: QBot::Helpers.t('arch.package.packager'), value: pkg.packager }
        ],
        footer: { text: QBot::Helpers.t('arch.package.version', pkg.version) },
        timestamp: pkg.builddate
      }
    end
  end
end
