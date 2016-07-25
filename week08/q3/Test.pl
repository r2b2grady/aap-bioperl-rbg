#!/usr/bin/perl
use strict;
use warnings;

# Created on: Jul 16, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

my $dir = $0;
$dir =~ s{/[^/]*\.pl$}{};

chdir $dir;

use lib ".";

use Test::Simple tests => 9;
use RestrictionEnzyme;

my @re = (RestrictionEnzyme->new(name   => 'EcoRI',
                                 mfr    => 'Many',
                                 recseq => 'G^AATTC'),
          RestrictionEnzyme->new(name   => 'EcoRII',
                                 recseq => '^CCWGG'),
          RestrictionEnzyme->new(name   => 'SphI',
                                 mfr    => "Big Bubba's Bait and Enzyme " .
                                           "Emporium",
                                 recseq => 'GCATGC'));


# Read in the test sequence from the text file.
my $seq = "";

open my $fh, '<', './testseq.txt' || die "Unable to open testseq.txt: $!";

while (<$fh>) {
	chomp();
	$seq .= $_ unless m/[^ACGTacgt]/;
}

close $fh;

my @exp = ({name    => 'EcoRI',
	        mfr     => 'Many'},
           {name    => 'EcoRII',
           	mfr     => 'Unknown'},
           {name    => 'SphI',
           	mfr     => "Big Bubba's Bait and Enzyme Emporium"});

# Read in the expected sequence files.
for my $e (@exp) {
	open $fh, '<', "./expseq_" . $e->{name} . ".txt"
	       || die "Unable to open expseq_" . $e->{name} . ".txt: $!";
	
	$e->{cutseq} .= $_ while (<$fh>);
	
	close $fh;
}

# Run the tests.
for (my $i = 0; $i < scalar(@re); $i++) {
	# Test the name.
	ok($re[$i]->get_name() eq $exp[$i]{name},
	       "$i: Name test ($exp[$i]{name}).");
	print $re[$i]->rs_patt() . "\n";
	ok($re[$i]->get_mfr() eq $exp[$i]{mfr},
	       "$i: Mfr test ($exp[$i]{mfr}).");
	my $cut = join("\n", $re[$i]->cut_dna($seq));
	ok($cut eq $exp[$i]{cutseq}, "$i: Cut DNA test.");
}