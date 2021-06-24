# frozen_string_literal: true

require 'matrix'

# Library for working with RGB, XYZ, and LAB colorspaces
module ColorLib
  # rubocop: disable Layout/SpaceInsideArrayLiteralBrackets
  RGB_XYZ_MATRIX = Matrix[
    [  0.4124564,  0.3575761,  0.1804375  ],
    [  0.2126729,  0.7151522,  0.0721750  ],
    [  0.0193339,  0.1191920,  0.9503041  ]
  ]

  XYZ_RGB_MATRIX = Matrix[
    [  3.2404542, -1.5371385, -0.4985314  ],
    [ -0.9692660,  1.8760108,  0.0415560  ],
    [  0.0556434, -0.2040259,  1.0572252  ]
  ]

  D65 = [ 95.047, 100, 108.883 ].freeze
  # rubocop: enable Layout/SpaceInsideArrayLiteralBrackets

  def self.hex_to_rgb(hex) =
    hex.chars.last(6).each_slice(2).map { _1.join.to_i(16) }

  def self.rgb_to_hex(rgb) =
    rgb.map { _1.round.clamp(0, 255).to_s(16).rjust(2, '0') }.join

  def self.rgb_to_xyz(rgb)
    r, g, b = rgb.map { _1 / 256.0 }
    (RGB_XYZ_MATRIX * Matrix[[r], [g], [b]]).to_a.flatten
  end

  def self.xyz_to_rgb(xyz)
    x, y, z = xyz
    ary = (XYZ_RGB_MATRIX * Matrix[[x], [y], [z]]).to_a.flatten
    ary.map { _1 * 256.0 }
  end

  def self.scale_f(val)
    delta = 6.0 / 29
    t = val

    if t > delta**3
      t**(1.0 / 3)
    else
      t / (3 * delta**2) + 4.0 / 29
    end
  end

  # rubocop: disable Metrics/AbcSize
  def self.xyz_to_lab(xyz)
    x, y, z = xyz.map { _1 * 100 }
    xn, yn, zn = D65

    l = 116 *  scale_f(y / yn) - 16
    a = 500 * (scale_f(x / xn) - scale_f(y / yn))
    b = 200 * (scale_f(y / yn) - scale_f(z / zn))

    [l, a, b]
  end

  def self.lab_to_xyz(lab)
    l, a, b = lab
    xn, yn, zn = D65

    p = (l + 16) / 116.0

    x = xn * (p + a / 500.0)**3
    y = yn *  p**3
    z = zn * (p - b / 200.0)**3

    [x, y, z].map { _1 / 100.0 }
  end
  # rubocop: enable Metrics/AbcSize

  def self.cie76(lab1, lab2)
    l1, a1, b1 = lab1
    l2, a2, b2 = lab2

    ((l2 - l1)**2 + (a2 - a1)**2 + (b2 - b1)**2)**0.5
  end

  def self.ciede2000(lab1, lab2)
    # TODO: write this
    cie76(lab1, lab2)
  end

  def self.hex_to_lab(hex) = xyz_to_lab(rgb_to_xyz(hex_to_rgb(hex)))

  def self.lab_to_hex(lab) = rgb_to_hex(xyz_to_rgb(lab_to_xyz(lab)))
end
