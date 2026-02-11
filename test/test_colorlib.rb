# frozen_string_literal: true

require_relative 'test_helper'
require 'matrix'
require_relative '../lib/qbot/colorlib'

class TestColorLib < Minitest::Test
  include QBot::ColorLib

  def test_srgb_from_hex_black
    color = SRGBColor.from_hex('#000000')
    assert_in_delta 0.0, color.r, 0.001
    assert_in_delta 0.0, color.g, 0.001
    assert_in_delta 0.0, color.b, 0.001
  end

  def test_srgb_from_hex_white
    color = SRGBColor.from_hex('#ffffff')
    assert_in_delta 1.0, color.r, 0.001
    assert_in_delta 1.0, color.g, 0.001
    assert_in_delta 1.0, color.b, 0.001
  end

  def test_srgb_from_hex_red
    color = SRGBColor.from_hex('#ff0000')
    assert_in_delta 1.0, color.r, 0.001
    assert_in_delta 0.0, color.g, 0.001
    assert_in_delta 0.0, color.b, 0.001
  end

  def test_srgb_to_hex_roundtrip
    hex = 'ff8040'
    color = SRGBColor.from_hex(hex)
    assert_equal hex, color.to_hex
  end

  def test_srgb_to_xyz_roundtrip
    original = SRGBColor.new(r: 0.5, g: 0.3, b: 0.7)
    roundtrip = original.to_xyz.to_srgb

    assert_in_delta original.r, roundtrip.r, 0.001
    assert_in_delta original.g, roundtrip.g, 0.001
    assert_in_delta original.b, roundtrip.b, 0.001
  end

  def test_cielab_from_hex
    lab = CIELABColor.from_hex('#ff0000')
    # Red should have high L and positive a
    assert lab.l > 40
    assert lab.a > 50
  end

  def test_cie76_distance_same_color
    color = CIELABColor.new(l: 50.0, a: 20.0, b: -10.0)
    assert_in_delta 0.0, color.cie76(color), 0.001
  end

  def test_cie76_distance_different_colors
    black_lab = CIELABColor.from_hex('#000000')
    white_lab = CIELABColor.from_hex('#ffffff')

    distance = black_lab.cie76(white_lab)
    assert distance > 90, "Expected large distance, got #{distance}"
  end

  def test_to_ary
    color = SRGBColor.new(r: 0.1, g: 0.2, b: 0.3)
    r, g, b = color
    assert_in_delta 0.1, r, 0.001
    assert_in_delta 0.2, g, 0.001
    assert_in_delta 0.3, b, 0.001
  end
end
