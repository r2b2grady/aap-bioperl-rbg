#!/usr/bin/perl
use strict;
use warnings;

use Storable;

my @nt = qw(A C G T);

# Returns a reference to a hash that represents all runs of a given length
# (2nd arg) found in the given sequence (1st arg).
sub runcount($$) {
	my ($seq, $n) = @_;
	
	while (ref($seq) =~ m/^REF/) {
		$seq = $$seq;
	}
	
	my @r = $seq =~ m/([ACGT])\1{3}(?!\1)/g;
	
	my %runs = ();
	
	for (@r) {
		for my $b (@nt) {
			$runs{$b}++ if m/$b/;
		}
	}
	
	return \%runs;
}

my $data = retrieve('./q2_randseqs.txt');

for (@$data) {
	my $r = runcount($_->{seq}, 4);
	
	print "-" x 79 . "\n";
	print "    $_->{name}\n";
	print "Seq:    " . $_->{seq} . "\n";
	for my $b (@nt) {
		print "$b Runs: " . (exists $$r{$b} ? $$r{$b} : 0) . "\n";
	}
}