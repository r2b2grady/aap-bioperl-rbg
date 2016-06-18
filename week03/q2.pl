#!/usr/bin/perl
use v5.10.1;

use strict;
use warnings;

# Prints the multiplication table from 1 to the given limit. If no value is
# specified, the default variable '$_' will be used.
sub mult_table(_) {
	my ($lim) = @_;
	my $s = "";
	
	for my $a (1..$lim) {
		# Loop through the values of factor B and print the value "A x B".
		for my $b (1..$lim) {
			$s .= sprintf("% 4d", $a * $b);
		}
		
		# Start a new line.
		$s .= "\n";
	}
}

# Run five examples of the mult_table() function.
my @ex = qw(3 17 5 22 7);

for (@ex) {
	print mult_table();
	print(("-" x 16) . "\n");
}