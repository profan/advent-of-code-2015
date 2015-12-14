#!/usr/bin/env io
Regex

file := File with("12.input")
file openForReading
file contents allMatchesOfRegex("-?[0-9]+") reduce(res, m, res + m at(0) asNumber, 0) print
file close
