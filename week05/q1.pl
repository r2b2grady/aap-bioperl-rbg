#!/usr/bin/perl
use strict;
use warnings;

# Takes two arrays and returns a reference to a nested array containing the
# cross-product of the two arrays.
sub xprod($$) {
	my ($a1, $a2) = @_;
	
	while (ref $a1 =~ m/^REF/) {
		$a1 = $$a1;
	}
	
	while (ref $a2 =~ m/^REF/) {
		$a2 = $$a2;
	}
	
	die "Invalid 1st arg: Not an array reference" unless ref($a1) =~ m/^ARRAY/;
    die "Invalid 2nd arg: Not an array reference" unless ref($a2) =~ m/^ARRAY/;
	
	my $out = [];
	
	for my $i (@$a1) {
		my @row = ();
		for my $j (@$a2) {
			push @row, $i * $j;
		}
		push @$out, [@row];
	}
	
	return $out;
}

my $t1 = [1,3,5,7];
my $t2 = [2,4,6];

my $test = xprod($t1, $t2);

for my $r (@$test) {
	printf '%6d', $_ for (@$r);
	print "\n";
}
