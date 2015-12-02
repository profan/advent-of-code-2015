#!/usr/bin/env perl6

sub smallest-side-area(@array [$l, $w, $h]) {

	my $area = sub (@arr [$w, $h]) { $w * $h };
	my &smallest-area = sub ($cur, $last) { $area($cur) < $area($last) ?? $cur !! $last };
	my @sides = [[$l, $w], [$w, $h], [$l, $h]];
	my $smallest = [[&smallest-area]] @sides;

	$area($smallest)

}

sub get-surface-area(@array [$l, $w, $h]) {
	2*$l*$w + 2*$w*$h + 2*$h*$l + smallest-side-area @array
}

my $rgx = / (\d+) x (\d+) x (\d+) /;

sub match-line ($cur, $line) { 
	my @matches = ($line ~~ $rgx).list;
	$cur + get-surface-area @matches;
}

my $input = open "2.input";
my $feet-of-paper = reduce &match-line, 0, |$input.lines;
say "Part 1 - Feet of Paper: $feet-of-paper";
