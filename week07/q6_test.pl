#!/usr/bin/perl
use strict;
use warnings;

# Created on: Jul 16, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

my $dir = $0;
$dir =~ s{/[^/]\.pl$}{};

chdir $dir;

use lib "..";

use Test::Simple tests => 10;
use week07::q6;

my @sets = ([23, 8, 2, 33, 2, 21, 14, 6, 32, 30],
			[24, 33, 8, 32, 15, 23, 22, 12],
			[35, 4, 26, 4, 25, 33, 7, 32, 14, 27, 9, 27, 19, 12],
			[35, 24, 36, 28, 15],
			[10, 39, 25, 26, 9, 8, 28, 27, 27, 32, 28, 21, 36, 1]);

my @max = (33, 33, 35, 36, 39);

my @min = (2, 8, 4, 15, 1);

for (0..4) {
	my $x = max_num(@{$sets[$_]});
	ok($x == $max[$_], "max_num(" . join(',', @{$sets[$_]}) . ") OK:\n" .
	       "Actual:     $x\nExpected:   $max[$_]");
}

print "\n";

for (0..4) {
	my $x = min_num(@{$sets[$_]});
    ok($x == $min[$_], "min_num(" . join(',', @{$sets[$_]}) . ") OK:\n" .
           "Actual:     $x\nExpected:   $min[$_]");
}