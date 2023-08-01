# frozen_string_literal: true

##
# Index for Arch Linux package repositories
class ArchReposIndex < ApplicationIndex
  def self.path
    File.join(QBot.options.state_dir, 'arch-repo-index')
  end

  def self.instantiate
    ngram = Tantiny::Tokenizer.new(:ngram, min: 3, max: 8)
    en_stemmer = Tantiny::Tokenizer.new(:stemmer)

    Tantiny::Index.new(path) do
      string :name
      text :name_tok, tokenizer: ngram
      text :description, tokenizer: en_stemmer
    end
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

  Entry = Data.define(:name, :description) {
    alias_method :id, :name
    alias_method :name_tok, :name
  }

  def populate_from_db(db)
    transaction do
      db.packages.each do |name, pkg|
        self << Entry.new(name:, description: pkg.desc)
      end
    end

    reload
  end

  def populate_from_global_cache
    c = ArchRepos::DBCache.instance

    c.cache.each { |_, db| populate_from_db(db) }
  end
end
