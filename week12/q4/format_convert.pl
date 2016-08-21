#!/usr/bin/perl
use strict;
use warnings;

# Created on: Aug 20, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

=pod

=head1 format_convert
Takes a sequence file in any BioPerl-supported format and converts it to any
other supported format.

=head1 USAGE
format_convert FILE FORMAT

C<FORMAT> can be any of 'ab1', 'abi', 'alf', 'ctf', 'embl', 'entrezgene',
'exp', 'fasta', 'fastq', 'gcg', 'genbank', 'pir', 'pln', 'scf', 'ztr', 'ace',
'game', 'locuslink', 'phd', 'qual', 'raw', 'swiss' (case-insensitive).

=cut

use Bio::SeqIO;

# Hash of extensions to use for each possible output format.
my %exts = (abi         => 'abi',
            ab1         => 'ab1',
            ace         => 'ace',
            alf         => 'alf',
            bsml        => 'bsml',
            ctf         => 'ctf',
            embl        => 'embl',
            entrezgene  => 'asn',
            'exp'       => 'exp',
            fasta       => 'fasta',
            fastq       => 'fastq',
            gcg         => 'gcg',
            genbank     => 'gb',
            phd         => 'phd',
            pir         => 'pir',
            pln         => 'pln',
            qual        => 'qual',
            raw         => 'txt',
            scf         => 'scf',
            strider     => {dna         => 'xdna',
            	            rna         => 'xrna',
            	            protein     => 'xprt'},
            swiss       => 'swiss',
            ztr         => 'ztr');

# If no arguments were specified, print out the POD and exit.
unless (@ARGV) {
	print `perldoc $0`;
	exit;
}

# If there are insufficient parameters, die with an error.
die "No format argument provided: $!" unless scalar(@ARGV) > 1;

# Assign file and output format values.
my ($f_in, $outfmt) = @ARGV;

# Convert output format to lowercase for ease of use in hashes.
$outfmt = lc($outfmt);

# Die if invalid parameters were provided.
die "File $f_in does not exist: $!" unless -f $f_in;
die "Invalid file format \"$outfmt\": $!" unless (exists $exts{$outfmt});

# Load in the sequence(s).
my $io_in = Bio::SeqIO->new($f_in);

my @seq;

while (my $s = $io_in->next_seq()) {
	push @seq, $s;
}

die "No sequences found in file $f_in: $!" unless @seq;

my $f_out = $f_in;
my $ext = $exts{$outfmt};

# If the output format is Strider, guess the necessary file extension based on
# the first input sequence's alphabet.
if ($outfmt eq 'strider') {
	$ext = $ext->{$seq[0]->alphabet};
}

$f_out =~ s/\.[^\.]*$/\.$ext;/;
my $io_out = Bio::SeqIO->new(">$f_out", $outfmt);

$io_out->write_seq(@seq);

print "Successfully wrote $f_out\n";