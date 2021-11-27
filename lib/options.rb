# frozen_string_literal: true

require 'optparse'

# CLI options for the bot
module QBot
  # This class holds the definitions and values of the options
  class Options
    attr_accessor :config_path, :state_dir

    def initialize
      @config_path = 'config/global.yml'
      @state_dir = 'var'
    end

    def define_options(parser)
      parser.banner = "Usage: #{$PROGRAM_NAME} [-c <file>]"
      parser.separator ''
      parser.separator 'Options:'

      config_option(parser)
      state_dir_option(parser)
      help_option(parser)
      version_option(parser)
    end

    def config_option(parser)
      parser.on('-c', '--config <file>', String,
                "Specify location of the config file (default #{@config_path})") do |path|
        @config_path = path
      end
    end

    def state_dir_option(parser)
      parser.on('-s', '--state-dir <directory>', String,
                'Set the directory where state, such as databases, will be stored') do |dir|
        @state_dir = dir
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

  def self.options
    @options
  end
end
