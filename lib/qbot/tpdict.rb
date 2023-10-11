# frozen_string_literal: true

require 'singleton'

##
# Toki Pona dictionary
class TPDict
  include Singleton

  attr_accessor :tp_inli, :pu

  SOURCES = [
    'http://tokipona.org/compounds.txt',
    'http://tokipona.org/nimi_pi_pu_ala.txt',
    'http://tokipona.org/nimi_pu.txt'
  ].freeze

  FREQ_MAP = {
    81..100 => '⁵',
    61..80 => '⁴',
    41..60 => '³',
    21..40 => '²',
    11..20 => '¹',
    0..10 => '⁰'
  }.freeze

  def sourcelist = SOURCES.join(', ')

  # rubocop: disable Security/Open
  def get_all(urls) = urls.map { YAML.safe_load(URI.open(_1)) }
  # rubocop: enable Security/Open

  def merge_defs(yamls) = yamls.each_with_object({}) { |l, r| r.merge!(l) }

  def process_tp_inli(input)
    input.transform_values do |v|
      v.map do |usage|
        *w, c = usage.split
        [w.join(' '), c.to_i]
      end
    end
  end

  def load_tp_inli = process_tp_inli(merge_defs(get_all(SOURCES)))

  def load_pu
    YAML
      .unsafe_load_file(File.join(__dir__, *%w[.. .. share tokipona pu.yml]))
      .transform_values(&:symbolize_keys)
  end

  def initialize
    @tp_inli = load_tp_inli
    @pu = load_pu
  end

  def freq_char(freq) = FREQ_MAP.select { _1.include? freq }.values.first

  def freqlist(vals) = vals.map { |k, v| "#{k}#{freq_char(v)}" }.join(', ')

  def query_tp_inli(query, limit: 0, overflow_text: '[...]')
    data = @tp_inli[query] || (return nil)

    if limit.zero? || data.size <= limit
      freqlist(data)
    else
      "#{freqlist(data.first(8))}, #{overflow_text}"
    end
  end

  def query_pu(query)
    data = @pu[query] || (return nil)

    data.map { |(type, desc)|
      "*~#{type}~* #{desc}"
    }.join("\n")
  end
end
