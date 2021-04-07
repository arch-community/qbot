# frozen_string_literal: true

require 'optparse'

# CLI options for the bot
module QBot
  # This class holds the definitions and values of the options
  class Options
    attr_accessor :config_path

    def initialize
      @config_path = 'config/global.yml'
    end

    def define_options(parser)
      parser.banner = "Usage: #{$PROGRAM_NAME} [-c <file>]"
      parser.separator ''
      parser.separator 'Options:'

      config_option(parser)
      help_option(parser)
      version_option(parser)
    end

    def config_option(parser)
      parser.on('-c', '--config <file>', String,
                "Specify location of the config file (default #{@config_path})") do |path|
        @config_path = path
      end
    end

    def help_option(parser)
      parser.on_tail('-h', '--help', 'Show this message') do
        puts parser
        exit
      end
    end

    def version_option(parser)
      parser.on_tail('-v', '--version', 'Show version') do
        puts "QBot #{@version}"
        exit
      end
    end
  end

  def self.parse_options(args)
    @options = Options.new
    @args = OptionParser.new do |parser|
      @options.define_options(parser)
      parser.parse!(args)
    end
    @options
  end
end
