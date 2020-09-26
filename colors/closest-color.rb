# Closest Color Algorithm

require './colorlib.rb'

colors = File.readlines("colors.txt").map(&:chomp)

labs = colors.map { hex_to_lab(_1) }

compare = hex_to_lab(ARGV[0])

de = labs.map { cie76(compare, _1) }
min = de.each.with_index.min_by { |val, idx| val }

puts colors[min[1]]
