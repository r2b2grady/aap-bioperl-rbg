#!/usr/bin/perl

# Uses a nested loop construct to print out the multiplication tables up to the
# number 12.
use strict;
use warnings;

use v5.10.1;

# For these comments, the factors will be referred to as factor A and factor B.
# Each ROW will correspond to a value of factor A and each COLUMN to a value of
# factor B.

# Loop through the values of factor A.
for my $a (1..12) {
	# Loop through the values of factor B and print the value "A x B".
	for my $b (1..12) {
		print sprintf("% 4d", $a * $b);
	}
	
	# Start a new line.
	print "\n";
}
