#!/usr/bin/env rdmd
module five_two;

import std.stdio;
import std.range;
import std.algorithm;

void main() {

	auto input = File("5.input");
	auto data = input.byLine;

	bool isNice(in char[] line) {

		int[const(dchar[])] pairs;
		auto has_repeater = false;

		foreach (i, c; line) {

			auto chars = line[i..$].take(3).array;

			if (chars.length > 2 && chars[0] == chars[2]) {
				has_repeater = true;
			}

			if (chars.length > 1) {
				if (!(chars.length > 2 && chars[0] == chars[1] && (i != 0 && line[i-1] == chars[0]))) {
					pairs[chars[0..2].idup] += 1;
				}
			}

		}

		auto two_pairs = pairs.values.filter!(v => v >= 2);
		return !two_pairs.empty && has_repeater;

	} //isNice

	auto nice_words = data.filter!isNice();
	writefln("Day 5: Nice Words: %d", nice_words.walkLength); 
}
