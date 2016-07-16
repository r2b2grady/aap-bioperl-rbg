#!/usr/bin/perl
use strict;
use warnings;

# Created on: Jul 16, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

# Array of nucleotides.
my @nt = qw(A C G T);

# Returns statistics on the given DNA sequence.  The statistics are returned as
# a reference to a hash.  The key 'seq' contains the DNA sequence passed to the
# function, while all other keys contain hashes.  These sub-hashes are:
#   KEY     CONTENTS
# runs      Number of runs of 2 or more nucleotides.  Each key is a nucleotide
#           abbreviation and each value is the number of runs for that
#           nucleotide.
# count     The number of occurrences of the nucleotides in the DNA sequence.
#           Each key is a nucleotide abbreviation and each value is the number
#           of occurrences for that nucleotide.
# pct       The percent of the original sequence that is made up of each
#           nucleotide.  Each key is a nucleotide abbreviation and each value
#           is the percent value (in decimal format) of the initial sequence
#           for that nucleotide.
sub seqstats($) {
    my ($dna) = @_;
    
    my %st = (seq   => $dna,
              runs  => {},
              count => {},
              pct   => {});
    
    for (@nt) {
        $st{count}{$_} = scalar($dna =~ m/$_/g);
        $st{runs}{$_} = scalar($dna =~ m/(?:$_){2,}/g);
        $st{pct}{$_} = $st{count}{$_} / length($dna);
    }
    
    return \%st;
}

# Random DNA sequence function
sub randseq($;$) {
    my ($len, $randlen) = @_;
    
    # Randomize the length parameter if a second parameter was given.
    $len = int(rand $len) + 1 if $randlen;
    
    my $seq = "";
    
    for (1..$len) {
        $seq .= $nt[int(rand(scalar(@nt)))];
    }
    
    return $seq;
}

# Dispatch table of functions.
my %f = (st => \&seqstats,
         rs => \&randseq);

# Get a sequence and analyze it.
my $seq = $f{rs}->(200);

my $stats = $f{st}->($seq);

# Print out the analysis results in a table.
#   Header title
my $hdr = " DNA ANALYSIS ";
#   Row separator string
my $rsep = "|" . "-" x 14 . ("+" . "-" x 9) x 4 . "+\n";
#   Output configuration for the different keys.  'lbl' indicates the output
#   label, while 'fmt' indicates the printf format string.
my %cfg = (count    => {lbl     => 'Counts',
	                    fmt     => '| %6d  '},
           runs     => {lbl     => 'Runs',
                        fmt     => '| %6d  '},
           pct      => {lbl     => 'Percent Comp',
                        fmt     => '| %6.2f%% '});

my $n = (78 - length($hdr)) / 2;

#   Header row of output table.
print "=" x int($n) . $hdr . "=" x int($n + 0.5) . "\n";
print "Sequence:  " . join("\n" . " " x 11, split('[ACGT]{60}\K', $seq));
print "\n\n";
print "Statistics:\n";

#   Nucleotide row.
print "." . "-" x 54 . ".\n";
print "| Nucleotide   ";
for (sort(@nt)) {
	print "|" . " " x 4 . $_ . " " x 4;
}
print "|\n";
print $rsep;

#   Print out rows.
for my $r (qw(count runs pct)) {
	# Print row name.
	printf("| %13s", $cfg{$r}{lbl});
	
	# Print row values.
	for (sort @nt) {
		printf($cfg{$r}{fmt}, $stats->{$r}{$_} * ($r eq 'pct' ? 100 : 1));
	}
	print "|\n";
}

#   Print out the bottom edge of the table.
print "*" . "-" x 54 . "*\n";