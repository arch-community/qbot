# frozen_string_literal: true

module QBot
  # Library for working with RGB, XYZ, and LAB colorspaces
  module ColorLib
    def self.matrix_dim(mx)
      raise('argument is not a matrix') \
        if mx.empty? || mx.first&.empty?

      raise('argument is not a matrix') \
        unless mx.map(&:size).then { |sizes| sizes.all?(sizes.first) }

      mfirst = mx.first || []

      [mx.size, mfirst.size]
    end

    def self.mul_compat?(mx1, mx2)
      _, c1 = matrix_dim(mx1)
      r2, = matrix_dim(mx2)

      c1 == r2
    end

    def self.dot_product(ary1, ary2)
      ary1.zip(ary2).map { |a, b| a * (b || 0.0) }.sum
    end

    def self.matmul(mx1, mx2)
      raise('matrices have incompatible dimensions') \
        unless mul_compat?(mx1, mx2)

      mx2t = mx2.transpose

      mx1.map { |row| mx2t.zip(row).map { |c, _| dot_product(row, c) } }
    end

    # rubocop: disable Layout/SpaceInsideArrayLiteralBrackets
    # rubocop: disable Layout/ExtraSpacing
    RGB_XYZ_MATRIX = [
      [  0.4124564,  0.3575761,  0.1804375  ],
      [  0.2126729,  0.7151522,  0.0721750  ],
      [  0.0193339,  0.1191920,  0.9503041  ]
    ].freeze

    XYZ_RGB_MATRIX = [
      [  3.2404542, -1.5371385, -0.4985314  ],
      [ -0.9692660,  1.8760108,  0.0415560  ],
      [  0.0556434, -0.2040259,  1.0572252  ]
    ].freeze
    # rubocop: enable Layout/ExtraSpacing
    # rubocop: enable Layout/SpaceInsideArrayLiteralBrackets

    ##
    # A tristimulus value in the CIE 1931 space.
    class XYZTristimulus < Data.define(:x, :y, :z)
      def to_srgb_linear
        r, g, b = ColorLib.matmul(XYZ_RGB_MATRIX, [[x], [y], [z]]).flatten

        SRGBLinearColor.new(r:, g:, b:)
      end

      def to_srgb
        to_srgb_linear.gamma_compress
      end

      private def scale_f(val)
        delta = 6.0 / 29
        t = val

        if t > delta**3
          t**(1.0 / 3)
        else
          (t / (3 * (delta**2))) + (4.0 / 29)
        end
      end

      # rubocop: disable Metrics/AbcSize
      def to_cielab(illuminant: D65)
        x_, y_, z_ = x * 100, y * 100, z * 100
        xn, yn, zn = illuminant.x, illuminant.y, illuminant.z

        l = (116 * scale_f(y_ / yn)) - 16
        a = 500 * (scale_f(x_ / xn) - scale_f(y_ / yn))
        b = 200 * (scale_f(y_ / yn) - scale_f(z_ / zn))

        CIELABColor.new(l:, a:, b:)
      end
      # rubocop: enable Metrics/AbcSize

      def to_ary = [x, y, z]
      def to_a = to_ary
    end

    D65 = XYZTristimulus.new(x: 95.047, y: 100.0, z: 108.883)
    D50 = XYZTristimulus.new(x: 96.42, y: 100.0, z: 82.51)

    ##
    # An RGB value in the sRGB colorspace.
    class SRGBColor < Data.define(:r, :g, :b)
      def self.from_hex(hex)
        r, g, b = hex.chars.last(6).each_slice(2)
          .map { |c| c.join.to_i(16) / 255.0 }

        new(r: r || 0.0, g: g || 0.0, b: b || 0.0)
      end

      def to_hex
        [r, g, b].map { |val|
          (val * 255).round.clamp(0, 255).to_s(16).rjust(2, '0')
        }.join
      end

      private def gamma_expand_one(val)
        if val <= 0.04045
          val / 12.92
        else
          ((val + 0.055) / 1.055)**2.4
        end
      end

      def to_xyz
        gamma_expand.to_xyz
      end

      def gamma_expand
        SRGBLinearColor.new(
          r: gamma_expand_one(r),
          g: gamma_expand_one(g),
          b: gamma_expand_one(b)
        )
      end

      def to_ary = [r, g, b]
      def to_a = to_ary
    end

    ##
    # A gamma-expanded ("linear light") RGB value in the sRGB colorspace.
    class SRGBLinearColor < Data.define(:r, :g, :b)
      def to_xyz
        x, y, z = ColorLib.matmul(RGB_XYZ_MATRIX, [[r], [g], [b]]).flatten
        XYZTristimulus.new(x:, y:, z:)
      end

      private def gamma_compress_one(val)
        if val <= 0.0031308
          12.92 * val
        else
          (1.055 * (val**(1.0 / 2.4))) - 0.055
        end
      end

      def gamma_compress
        SRGBColor.new(
          r: gamma_compress_one(r),
          g: gamma_compress_one(g),
          b: gamma_compress_one(b)
        )
      end

      def to_ary = [r, g, b]
      def to_a = to_ary
    end

    ##
    # A color in the CIE LAB color space.
    class CIELABColor < Data.define(:l, :a, :b)
      def self.from_hex(...)
        SRGBColor.from_hex(...).to_xyz.to_cielab
      end

      def to_hex
        to_xyz.to_srgb.to_hex
      end

      # rubocop: disable Metrics/AbcSize
      def to_xyz(illuminant: D65)
        xn, yn, zn = illuminant.x, illuminant.y, illuminant.z

        p = (l + 16) / 116.0

        x = xn * ((p + (a / 500.0))**3) / 100.0
        y = yn * (p**3) / 100.0
        z = zn * ((p - (b / 200.0))**3) / 100.0

        XYZTristimulus.new(x:, y:, z:)
      end
      # rubocop: enable Metrics/AbcSize

      def cie76(other)
        (((other.l - l)**2) + ((other.a - a)**2) + ((other.b - b)**2))**0.5
      end

      def ciede2000(other)
        # TODO: write this
        cie76(other)
      end

      def to_ary = [l, a, b]
      def to_a = to_ary
    end
  end
end
