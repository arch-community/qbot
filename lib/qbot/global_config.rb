# frozen_string_literal: true

require 'json'
require 'yaml'
require 'active_support/core_ext/hash/indifferent_access'

module QBot
  ##
  # QBot's global configuration.
  module GlobalConfig
    SCHEMA_PATH = File.join(__dir__, *%w[.. .. share global_config.schema.json])

    def self.mk_schema
      schema = JSON.load_file(SCHEMA_PATH)
      JSI.new_schema(schema)
    end

    SchemaModule = mk_schema

    def self.parse_from_hash(hash)
      instance = SchemaModule.new_jsi(hash.with_indifferent_access)
      raise ArgumentError unless instance.jsi_valid?

      instance
    end

    def self.read_from_file(path)
      yaml = YAML.load_file(
        path,
        aliases: true,
        symbolize_names: true
      )

      raise 'Invalid config path' unless yaml

      parse_from_hash(yaml)
    end
  end
end
