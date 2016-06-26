#!/usr/bin/perl
use strict;
use warnings;

my %hoa = (first => ['I', '1st', 'First', 'first'],
           second => ['II', '2nd', 'Second', 'second'],
           third => ['III', '3rd', 'Third', 'third'],
           fourth => ['IV', '4th', 'Fourth', 'fourth'],
           fifth => ['V', '5th', 'Fifth', 'fifth'],
           sixth => ['VI', '6th', 'Sixth', 'sixth'],
           seventh => ['VII', '7th', 'Seventh', 'seventh']);

$, = "\n\t";

for (keys %hoa) {
	print("$_:", @{$hoa{$_}}, "\n")
}