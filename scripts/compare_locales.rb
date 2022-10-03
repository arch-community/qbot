#!/usr/bin/env ruby

# frozen_string_literal: true

require 'pathname'
require 'shellwords'
require 'yaml'

require 'paint'
require 'tty/progressbar'

require 'parser/current'
require 'unparser'

# configure ast format
Parser::Builders::Default.emit_lambda              = true
Parser::Builders::Default.emit_procarg0            = true
Parser::Builders::Default.emit_encoding            = true
Parser::Builders::Default.emit_index               = true
Parser::Builders::Default.emit_arg_inside_procarg0 = true
Parser::Builders::Default.emit_forward_arg         = true
Parser::Builders::Default.emit_kwargs              = true
Parser::Builders::Default.emit_match_pattern       = true

# helper methods

def flatten_keys_impl(hash, pfx = nil)
  hash.map { |k, v|
    if v.is_a? Hash
      flatten_keys_impl(v, "#{pfx}#{k}.")
    else
      ["#{pfx}#{k}", v]
    end
  }.flatten
end

def flatten_keys(hash)
  flatten_keys_impl(hash).each_slice(2).to_h
end

def find_prj_root(start = __dir__)
  if File.dirname(start) == start
    nil
  elsif File.exist?(File.join(start, 'qbot'))
    start
  else
    find_prj_root(File.dirname(start))
  end
end

def prj_root
  @prj_root ||= find_prj_root || (raise 'Project root could not be found')
end

# load the translation files.

raise "Usage: #{$PROGRAM_NAME} <base> <cmp>" unless ARGV.size == 2

def load_locale(name, root = prj_root)
  path_base = File.join(root, 'lib', 'locales', '%s.yml')
  YAML.unsafe_load_file format(path_base, name)
rescue Errno::ENOENT => e
  puts Paint["Locale not found: #{name}", :bright]
  puts e
  exit
end

(base_name, base_flat), (cmp_name, cmp_flat) = \
  ARGV.map { load_locale(_1).first.then { |k, v| [k, flatten_keys(v)] } }

def find_all_ruby(root = prj_root)
  Dir
    .glob(File.join(root, '**/*.rb'))
    .reject { |path|
      File.fnmatch(
        '{.,**}/{vendor,.bundle,lib/resources,scripts}/**',
        path,
        File::FNM_EXTGLOB
      )
    }
end

# parser helpers

def dfs(node, &)
  return unless node

  yield node
  return if node.children.empty?

  node.children.filter { _1.respond_to? :children }.each { dfs(_1, &) }
end

def iter_dfs(tree)
  Enumerator.new { |y| dfs(tree) { y << _1 } }
end

KeyLoc = Struct.new(:path, :line, :col, :key, keyword_init: true) do
  def location
    "#{path}:#{line}:#{col + 1}"
  end
end

def val(node)
  YAML.load Unparser.unparse(node)
end

# find all translation keys used in the code

bar = TTY::ProgressBar.new(
  "#{Paint['parsing', :yellow]} [:current/:total] [:bar]",
  complete: '*'
)

key_matches = bar.iterate(find_all_ruby).map { |abs_path|
  path = Pathname.new(abs_path).relative_path_from(Pathname.new(prj_root)).to_s

  text = File.read abs_path
  ast = Parser::CurrentRuby.parse(text)

  iter_dfs(ast).each_with_object([]) { |node, list|
    # Filter for method calls
    next unless node.type == :send

    line = node.loc.line
    col = node.loc.column

    case node.children
    # Find invocations of t()
    in [_, :t, key, *]
      list << KeyLoc.new(path:, line:, col:, key: val(key))

    # Find config help descriptions
    in [[:const, *, :Config], :help_msg, pfx, [_, *subcmds]]
      subcmds.map { val _1 }.each do |sub|
        key = "#{val(pfx).tr(' ', '.')}.help.#{sub}"
        list << KeyLoc.new(path:, line:, col:, key:)
      end

    # Find all bot commands
    in [_, :command, name, *]
      list << KeyLoc.new(path:, line:, col:, key: "descriptions.#{val name}")

    # Find list of locales
    in [[[:const, _, :I18n], :config], :available_locales=, [*, locales]]
      list << KeyLoc.new(path:, line:, col:, key: "locales.#{val name}")

    else next
    end
  }
}.inject(:+)

# print translations used in code, but not present in the base file.

puts Paint["Translations missing from #{base_name}:", :yellow, :bright]

key_groups = \
  key_matches
  .reject { base_flat.keys.include? _1.key }
  .group_by(&:key)

key_groups.each do |key, matches|
  print "\n#{Paint[key, :red]}"
  print Paint[' (template)', :yellow] if key.include? '#'
  print "\n"

  matches.each { puts "\t#{_1.location}" }
end

# print translations present in the base file, but not the compare file.

puts Paint[
  "\nTranslations present in #{base_name} but not in #{cmp_name}:",
  :yellow, :bright
]

(base_flat.keys - cmp_flat.keys).each do |key|
  puts "\n#{Paint[key, :red]}"
  puts %(\t(#{base_name}: "#{base_flat[key]}"))
end
