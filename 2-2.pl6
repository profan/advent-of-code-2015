#!/usr/bin/env perl6

sub smallest-surface-perimeter(@array [$l, $w, $h]) {

	my $perimeter = sub (@ [$w, $h]) { $w*2 + $h*2 };
	my &smallest-perimeter = sub ($cur, $last) { $perimeter($cur) < $perimeter($last) ?? $cur !! $last };
	my @sides = [[$l, $w], [$w, $h], [$l, $h]];
	my $smallest = [[&smallest-perimeter]] @sides;

	$perimeter($smallest)

}

sub package-ribbon-length(@array [$l, $w, $h]) {

	($l * $w * $h) + smallest-surface-perimeter @array

}

sub match-line ($cur, $line) {

	my $rgx = / (\d+) x (\d+) x (\d+) /;
	my @matches = ($line ~~ $rgx).list;

	$cur + package-ribbon-length @matches;

}

my $input = open "2.input";
my $feet-of-ribbon = reduce &match-line, 0, |$input.lines;
say "Part 2 - Feet of Ribbon: $feet-of-ribbon";
