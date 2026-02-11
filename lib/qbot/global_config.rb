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

    def self.format_errors(errors)
      errors.reduce(String.new) { |acc, e|
        ptr = e.instance_ptr.pointer
        ptr.insert(0, '/') unless ptr.start_with?('/')

        acc << "(#{ptr})"
        acc << " #{e.message}"

        sp = e.schema[e.keyword]

        if sp.respond_to?(:to_ary)
          acc << ': ' << e.instance_ptr.evaluate(e.instance_document).inspect
          acc << ' (' << sp.to_a.join(', ') << ')'
        end

        acc << "\n"
      }
    end

    def self.parse_from_hash(hash)
      instance = SchemaModule.new_jsi(hash.with_indifferent_access)

      val_res = instance.jsi_validate

      unless val_res.valid?
        msg = format_errors(val_res.validation_errors)
        warn msg
        raise ArgumentError, 'Could not parse configuration'
      end

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
