# frozen_string_literal: true

##
# Searches the Arch repos and the AUR.
# Arch repo search is done locally.
# AUR search is done through the API as there's no easy way to get a listing
# of packages on the AUR.
module PkgSearch
  PackageEntry = Struct.new(
    *%i[
      filename name base version desc groups csize isize
      md5sum sha256sum pgpsig
      url license arch builddate packager replaces conflicts provides
      depends optdepends makedepends checkdepends
    ]
  )

  def self.aur_api_args(query) = {
    v: 5,
    type: 'search',
    by: 'name-desc',
    arg: query
  }

  def self.aur_search(query)
    URI
      .encode_www_form(aur_api_args(query))
      .then { "https://aur.archlinux.org/rpc/?#{_1}" }
      .then { URI.parse(_1).open.read }
      .then { JSON.parse _1 }
  end

  def self.read_tgz(stream)
    stream
      .then { Zlib::GzipReader.new _1 }
      .then { Gem::Package::TarReader.new(_1) }
      .then { _1.to_h { |n| [n.full_name, n.read] } }
      .then { _1.filter { |_, v| v } }
  end

  def self.array_attrs = %i[
    groups license replaces conflicts provides
    depends makedepends optdepends checkdepends
  ]

  def self.normalize_field(field)
    header, *args = field.split("\n")

    /%(?<fname>[A-Z]+)%/ =~ header
    name = fname&.downcase&.to_sym
    return nil unless name

    args, = *args if args.one? && !(array_attrs.include? name)
    args = args.to_i if %i[csize isize builddate].include? name

    [name, args]
  end

  def self.parse_desc(text)
    desc = PackageEntry.new

    text.split("\n\n").each do |field|
      name, args = normalize_field(field)
      next unless name

      desc[name] = args
    end

    desc
  end

  def self.get_repo(name)
    base = QBot.config.arch.mirror

    files = URI("#{base}/#{name}/os/x86_64/#{name}.db.tar.gz").open.then { read_tgz _1 }
    files.values.map { parse_desc _1 }.to_h { [_1[:name], _1] }
  end

  def self.cache_repo(name)
    p name
    @repos ||= {}
    @repos[name] ||= get_repo(name)
  end

  def self.cache_all_repos
    QBot.config.arch.repos.each { cache_repo _1 }
  end

  def self.all_pkgs
    cache_all_repos
    @repos.join
  end

  def self.index
    Picky::Index.new(:package_entries) {}
      # source { all_pkgs }
      # backend Picky::Backends::SQLite.new
      # indexing splits_text_on: /[\s-]/

      # category :name
      # category :desc
    #end
  end

  def self.search(query)
    @search ||= Picky::Search.new index do
      searching splits_text_on: /[\s,-]/
    end

    @search.search(query)
  end
end
