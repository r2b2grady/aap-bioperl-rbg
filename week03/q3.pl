#!/usr/bin/perl

use v5.10.1;

use strict;
use warnings;

my $len = 20;

my @nt = qw(A C G T);

my $seq = "";

for (1..$len) {
	$seq .= $nt[int(rand(scalar(@nt)))];
}

print "$seq\n";