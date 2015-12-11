#!/usr/bin/env ruby
require "matrix"

results = File.open("8.input", 'r').reduce(Vector[0, 0]) do |acc, line|
	chomped = line.chomp
	escaped = chomped.scan(/\\((?:[xX][0-9a-fA-F]{2})|(?:\\|"))/).reduce(0) do |sum, m| 
		str = m.first
		sum + str.size
	end
	acc + Vector[chomped.length, (chomped.length-2) - escaped]
end

puts "characters in code #{results[0]} - characters in memory #{results[1]}: #{results[0] - results[1]}"
