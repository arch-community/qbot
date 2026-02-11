# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/qbot/helpers'

class TestHelpers < Minitest::Test
  def test_to_word_known_numbers
    assert_equal 'zero', to_word(0)
    assert_equal 'one', to_word(1)
    assert_equal 'five', to_word(5)
    assert_equal 'ten', to_word(10)
  end

  def test_to_word_unknown_numbers
    assert_equal 11, to_word(11)
    assert_equal(-1, to_word(-1))
    assert_equal 100, to_word(100)
  end

  def test_to_emoji_single_digits
    10.times do |n|
      emoji = to_emoji(n)
      assert_includes emoji, n.to_s
    end
  end

  def test_to_emoji_ten
    assert_equal "\u{1F51F}", to_emoji(10)
  end

  def test_to_emoji_out_of_range
    assert_raises(ArgumentError) do
      to_emoji(11)
    end
    assert_raises(ArgumentError) { to_emoji(-1) }
  end

  def test_parse_int_valid
    assert_equal 42, parse_int('42')
    assert_equal(-1, parse_int('-1'))
    assert_equal 0, parse_int('0')
  end

  def test_parse_int_invalid
    assert_nil parse_int('abc')
    assert_nil parse_int('')
    assert_nil parse_int(nil)
  end

  def test_after_nth_word_basic
    assert_equal 'world', after_nth_word(1, 'hello world')
    assert_equal 'b c', after_nth_word(1, 'a b c')
    assert_equal 'c', after_nth_word(2, 'a b c')
  end

  def test_after_nth_word_no_match
    assert_nil after_nth_word(3, 'a b')
    assert_nil after_nth_word(1, 'single')
  end

  def test_after_nth_word_preserves_spaces
    assert_equal 'c  d', after_nth_word(2, 'a b c  d')
  end
end
