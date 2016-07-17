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

use Test::Simple tests => 7;
use week07::q8;

sub transtest($);

=pod

Tests the operation of the week7::q8 function C<translate_dna>.  Includes tests
for synonymous codons (e.g. making sure ATT, ATC, and ATA all map to I), input
that lacks a start codon, input that lacks a stop codon, case insensitivity,
and input that has non-DNA characters.

=cut

# Assemble an array of the tests to make.  Each element of the array is a hash
# containing the keys 'seq' (DNA sequence to test), 'exp' (expected amino acid
# output sequence), and 'name' (name of the test being performed).
my @tests = ({seq      => 'ATGCTCTCTTCCATGTCTATTTGTGAAACTCTCGCACGTCAATTCGTATAG',
	          expect   => 'MLSSMSICETLARQFV',
              name     => "Synonyms 1"},
	         {seq      => 'AATGCTCAGGTCTAGACGCAAGACAACGAAGACCCCTGTGCGTCGCGC' .
	         	          'ACGCGGTAACGGTCTCCCGCCGCTGGAGTTTCAAGCTTCATGTTTGCT' .
	         	          'ATTCTTGACACGCGCTACACAACAGTTGCAACGCATCGCACCATACTG' .
	         	          'TGCGTTTAAAGTGCACCACTGTAACACGCGCCGAATGTGTACTACGCT' .
	         	          'GGGCATCATGCTCGCGCGCCCATACGAGATGGGGGTCAACGCTTTTGT' .
	         	          'TTCGCCCAGACGCACGCCCTGGAGGGCGATGGTAGCCGGGGACGGCTG' .
	         	          'GATCCTGCTGTTGAGGGATGTGGAAAGAAAAGAGTTCAGGGCAAGTCC' .
	         	          'GATTGTTGTCAGCTTGTCGACCGATCCGTCTGCAGACAGTTGTCCCCC' .
	         	          'GATGTACGGGAGCGCGCGTCTTACTGACTTGTATAGTGGATGGGTCGC' .
	         	          'GTACGTTGCAGAACAGCTTCTGCCGCCCCCTCTAATGGTCAGGAGGAT' .
	         	          'AGCGGGTACCATATCTGACCGCGGGTCAAAGTGA',
              expect   => 'MLRSRRKTTKTPVRRARGNGLPPLEFQASCLLFLTRATQQLQRIAPYC' .
                          'AFKVHHCNTRRMCTTLGIMLARPYEMGVNAFVSPRRTPWRAMVAGDGW' .
                          'ILLLRDVERKEFRASPIVVSLSTDPSADSCPPMYGSARLTDLYSGWVA' .
                          'YVAEQLLPPPLMVRRIAGTISDRGSK',
              name     => "Synonyms 2"},
             {seq      => 'AGTAAGCGATGGCAACTACTTCAAGTAATCCCGGGGACATGCCCTACAT' .
             	          'ACTGATTAATAAAACCGGTAGAGGTGCCTAA',
              expect   => 'MATTSSNPGDMPYILINKTGRGA',
              name     => "Synonyms 3"},
             {seq      => 'GATTTGCACTGTCCATAGTCGTATCTTAGTGAACGAATCTTCCGGTCGA' .
             	          'CGGTGCAATTTTACCGGTCGCGCTGCGCGCTGAGCAAACAATACTGT',
              expect   => '',
              name     => "No Start Codon"},
             {seq      => 'AAGAGATGAATGAACTCGCCCCGACAACGCTATGGGTACTTAATGTCGC' .
             	          'TGGTGGTGTGGGAATCGGGACCGCGTGGCCCCAGATATTATTATGGTTA' .
             	          'CTCGTCTGGGTA',
              expect   => 'MNELAPTTLWVLNVAGGVGIGTAWPQILLWLLVWV',
              name     => "No Stop Codon"},
             {seq      => 'GATgATtCACgGCGCcGTaTCACtGGTTGGAATGTTCAAACTGCGAcTa' .
             	          'GCCTCGTGGcACGcATCGGTACAtCAAAAAAcCTGGCCTCCCTGGCCGc' .
             	          'CTAAGTTGATAGGGTTTCGTAGCGCAACGGAgCACCCGCaagTCCtGtA' .
             	          'TGGTGGTTGtTCAaAACGGTAG',
              expect   => 'MIHGAVSLVGMFKLRLASWHASVHQKTWPPWPPKLIGFRSATEHPQVLY' .
                          'GGCSKR',
              name     => "Upper- and Lower-case Chars"},
             {seq      => '',
              expect   => '!!DIE!!',
              name     => "Non-DNA characters"});

# Loop through the tests, using a wrapper function that traps any 'die'
# messages.
for my $t (@tests) {
	my $res;
	$res = eval { translate_dna($t->{seq}) };
	
	if ($t->{expect} eq '!!DIE!!') {
		ok(! defined $res, $t->{name});
	} else {
		ok($res eq $t->{expect}, $t->{name});
	}
}


# Function to test a DNA translation.  Wraps the translate_dna() call in an
# 'eval' statement and returns the printed output.
sub transtest($) {
	my ($seq) = @_;
	
	my $result = "";
	
	eval {
		$result = translate_dna($seq);
	};
	
	$result = 'Invalid DNA sequence' unless defined $result || $@ eq '';
	
	return $result;
}