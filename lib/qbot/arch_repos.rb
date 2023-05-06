# frozen_string_literal: true

require 'zlib'
require 'rubygems/package'
require 'singleton'
require 'delegate'
require 'fileutils'

module ArchRepos
  ##
  # Global Tantiny index of packages
  class Index < SimpleDelegator
    include Singleton

    def self.mk_index(path)
      ngram = Tantiny::Tokenizer.new(:ngram, min: 3, max: 8)
      en_stemmer = Tantiny::Tokenizer.new(:stemmer)

      Tantiny::Index.new(path) do
        string :name
        text :name_tok, tokenizer: ngram
        text :description, tokenizer: en_stemmer
      end
    end

    def initialize
      @path = File.join(QBot.options.state_dir, 'arch-repo-index')
      @index = self.class.mk_index(@path)

      super(@index)
    end

    def pkg_names_query(str)
      q_name = smart_query(:name, str, boost: 5.0, prefix: false)
      q_name_tok = smart_query(:name_tok, str, boost: 1.0, prefix: false)
      q_desc = smart_query(:description, str, boost: 1.1)

      search(q_name | q_name_tok | q_desc)
    end

    def pkg_query(...)
      res = pkg_names_query(...)

      c = ArchRepos::DBCache.instance
      res.map { c.package(_1) }.compact
    end

    def populate_from_db(db)
      transaction do
        db.packages.each do |name, pkg|
          self << IndexEntry.new(name:, description: pkg.desc)
        end
      end

      reload
    end

    def populate_from_global_cache
      c = ArchRepos::DBCache.instance

      c.cache.each { |_, db| populate_from_db(db) }
    end

    def clear
      @index.send(:synchronize) do
        FileUtils.rm_rf(@path)
        @index = self.class.mk_index(@path)
      end

      __setobj__(@index)
      @index.reload
    end
  end

  IndexEntry = Data.define(:name, :description) do
    alias_method :id, :name
    alias_method :name_tok, :name
  end

  Package = Struct.new(
    'Package',
    *%i[
      repo name filename base version desc url packager
      arch builddate
      md5sum sha256sum pgpsig isize csize
      license groups
      depends optdepends checkdepends makedepends
      conflicts provides replaces
    ],
    keyword_init: true
  ) do
    attr_accessor :size

    private def split_arrays
      %i[
        license
        depends optdepends checkdepends makedepends
        conflicts provides replaces
      ].each do |sym|
        val = send(sym)
        send("#{sym}=", val.lines.map(&:strip)) if val
      end
    end

    def initialize(...)
      super

      self.isize = Integer(isize)
      self.csize = Integer(csize)
      self.builddate = Time.at(Integer(builddate))

      split_arrays
    end

    def web_url
      "https://archlinux.org/packages/#{repo}/#{arch}/#{name}"
    end
  end

  ##
  # Arch package database
  class DB
    private def parse_desc(desc)
      field_re = /(?>%(\w+)%\n)((?:[^\n]+\n)+)/m

      options = \
        desc
        .enum_for(:scan, field_re)
        .each_with_object({}) { |(k, v), pkg|
          pkg[k.downcase.to_sym] = v.strip
        }

      Package.new(**options, repo:)
    end

    private def tar_entry_pred(entry)
      # typeflag 0 indicates a regular file
      entry.header.typeflag == '0' \
        && entry.header.name.end_with?('/desc')
    end

    private def parse_tar(tar)
      tar
        .lazy
        .filter { tar_entry_pred _1 }
        .map { parse_desc(_1.read) }
        .force
    end

    def populate_data(io)
      Zlib::GzipReader.wrap(io) do |gz|
        Gem::Package::TarReader.new(gz) do |tar|
          @data = parse_tar(tar)
        end
      end

      @packages = @data.to_h { |pkg| [pkg.name, pkg] }
    end

    attr_accessor :packages, :repo

    def initialize(repo)
      @repo = repo
      @packages = nil
    end
  end

  ##
  # Package database backed by an on-disk cache
  class CachedDB < DB
    def initialize(mirror, repo)
      super(repo)

      @uri = URI.join(mirror, "#{repo}/os/x86_64/#{repo}.db")

      @path = File.join(QBot.options.state_dir, "#{repo}.db")
      update unless File.exist?(@path)
      read_data unless @packages
    end

    def read_data
      File.open(@path) do |f|
        populate_data(f)
      end
    end

    def update
      File.write(@path, @uri.open.read)
      read_data
    end

    def created_at
      File.birthtime(@path)
    end

    def updated_at
      File.mtime(@path)
    end
  end

  ##
  # Global cache for package databases
  class DBCache
    include Singleton

    attr_accessor :repos, :cache

    # prevent output spam
    def inspect
      '[DBCache]'
    end

    def initialize
      @repos = QBot.config.arch.repos

      populate
    end

    def populate
      @cache ||= {}

      mirror = QBot.config.arch.mirror

      @repos.each do |name|
        @cache[name.to_sym] = CachedDB.new(mirror, name)
      end
    end

    def update_all
      @cache.each { |_, db| db.update }
    end

    def package(name)
      repo = @cache.values.find { _1.packages.key?(name) }
      return nil unless repo

      repo.packages[name]
    end
  end
end
