#!/usr/bin/env ruby

# Color Ring

require './colorlib'

l = ARGV[0].to_f
size = ARGV[1].to_f
num = ARGV[2].to_i

angle = 2 * Math::PI / num

colors = (0..num).map do
  this_angle = angle * _1
  a = size * Math.cos(this_angle)
  b = size * Math.sin(this_angle)

  [l, a, b].dup
end

colors.each { puts lab_to_hex _1 }
