# frozen_string_literal: true

require_relative 'test_helper'

# Minimal QBot module stub for breaking_word_wrap
module QBot; end

# Minimal shim for extract_options! used by breaking_word_wrap
class Array
  def extract_options!
    if last.is_a?(Hash)
      pop
    else
      {}
    end
  end

  def blank?
    empty?
  end
end

class Hash
  def reverse_merge!(other)
    other.each do |k, v|
      self[k] = v unless key?(k)
    end
    self
  end
end

require_relative '../lib/qbot/breaking_wrap'

class TestBreakingWrap < Minitest::Test
  def test_short_text_unchanged
    text = 'hello world'
    result = QBot.breaking_word_wrap(text, line_width: 80)
    assert_equal text, result
  end

  def test_wraps_at_line_width
    text = 'a ' * 50
    result = QBot.breaking_word_wrap(text.strip, line_width: 20)
    result.split("\n").each do |line|
      assert line.length <= 20,
        "Line '#{line}' exceeds 20 chars (#{line.length})"
    end
  end

  def test_breaks_long_words
    text = 'a' * 100
    result = QBot.breaking_word_wrap(text, line_width: 20)
    assert result.include?(' ') || result.include?("\n"),
      'Expected long word to be broken'
  end

  def test_preserves_explicit_newlines
    text = "line one is quite a bit long\nline two is also long"
    result = QBot.breaking_word_wrap(text, line_width: 30)
    assert result.include?("\n"),
      'Expected result to contain newlines'
  end
end
