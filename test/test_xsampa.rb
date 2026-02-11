# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/qbot/xsampa'

class TestXSConverter < Minitest::Test
  def test_basic_consonants
    assert_equal 'ʃ', XSConverter.convert('S'.dup)
    assert_equal 'ʒ', XSConverter.convert('Z'.dup)
    assert_equal 'θ', XSConverter.convert('T'.dup)
    assert_equal 'ð', XSConverter.convert('D'.dup)
    assert_equal 'ŋ', XSConverter.convert('N'.dup)
  end

  def test_vowels
    assert_equal 'ɑ', XSConverter.convert('A'.dup)
    assert_equal 'ɛ', XSConverter.convert('E'.dup)
    assert_equal 'ɪ', XSConverter.convert('I'.dup)
    assert_equal 'ɔ', XSConverter.convert('O'.dup)
    assert_equal 'ʊ', XSConverter.convert('U'.dup)
  end

  def test_diacritics
    assert_equal 'ə', XSConverter.convert('@'.dup)
    assert_equal 'ː', XSConverter.convert(':'.dup)
  end

  def test_multi_char_sequences
    assert_equal 'ɓ', XSConverter.convert('b_<'.dup)
    assert_equal 'ɖ', XSConverter.convert('d`'.dup)
    assert_equal 'ɦ', XSConverter.convert('h\\'.dup)
  end

  def test_combined_input
    input = 'D@'.dup
    result = XSConverter.convert(input)
    assert_equal 'ðə', result
  end

  def test_plain_text_preserved
    assert_equal 'hello', XSConverter.convert('hello'.dup)
  end
end
