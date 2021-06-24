# frozen_string_literal: true

##
# Word wrapping algorithm that breaks words, stolen from Stack Overflow
module BreakingWordWrap
  def self.breaking_word_wrap(text, line_width: 80)
    text = text.split(' ').collect do |word|
      word.length > line_width ? word.gsub(/(.{1,#{line_width}})/, '\\1 ') : word
    end * ' '

    text.split("\n").collect do |line|
      line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip : line
    end * "\n"
  end
end
