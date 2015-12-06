#!/usr/bin/env rdmd
module five_one;

import std.stdio;
import std.range;
import std.algorithm;

void main() {

	bool[dchar[]] disallowed_strings = ["ab" : true, "cd" : true, "pq" : true, "xy" : true];
	auto input = File("5.input");
	auto data = input.byLine;

	bool isNice(in char[] line) {

		auto vowels = 0;
		auto has_double = false;

		foreach (i, c1, c2; lockstep(line.chunks(2), line[1..$].chunks(2))) {

			auto chunk1 = c1.array();
			auto chunk2 = c2.array();
			has_double = ((chunk1.length > 1 && chunk1[0] == chunk1[1]) ||
					chunk2.length > 1 && chunk2[0] == chunk2[1]) || has_double;

			if (chunk1 in disallowed_strings || chunk2 in disallowed_strings) {
				return false;
			}

			foreach (c; chunk1) {
				switch (c) {
					case 'a','e','i','o','u':
						vowels += 1;
						break;
					default: break;
				}
			}

		}

		return vowels >= 3 && has_double;

	} //isNice

	auto nice_words = data.filter!isNice().walkLength;
	writefln("Day 5: Nice Words: %d", nice_words);

}
