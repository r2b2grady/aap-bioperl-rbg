#!/usr/bin/perl

use strict;
use warnings;

use Bio::Perl;
use Bio::SearchIO;
use Bio::SearchIO::Writer::TextResultWriter;
use Data::Dumper;
use POSIX qw(strftime);

# Created on: Jul 30, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

my $fastafile = "";

# Variable for storing output mode information.  'f' indicates file output,
# 'p' indicates print to terminal.  Can indicate both.
my $outmode = 'p';

for (@ARGV) {
    if (-f $_) {
        $fastafile = $_;
    }
}

# Array for number-based retrieval.
my @seqa = ();

# Hash for ID-based retrieval.
my %seqh = ();

# Open and read through file.
my $fsh = Bio::SeqIO->new(-file     => $fastafile,
                          -format   => 'fasta');

while (my $s = $fsh->next_seq()) {
    push @seqa, $s;
    $seqh{$s->display_id()} = \$seqa[-1];
    my $id = $s->display_id();
    
    # If there's a RefSeq ID in the display_id, add a hash key for the RefSeq
    # ID that points to the actual value.
    if ($id =~ m/ref\|([^\|\n]*)/) {
        $seqh{$1} = $seqh{$s->display_id()};
    }
    
    # If there's a GI ID in the display_id, add a hash key for the GI ID that
    # points to the actual value.
    if ($id =~ m/gi\|([^\|\n]*)/) {
        $seqh{$1} = $seqh{$s->display_id()};
    }
}

# Print out the names and first 60 nucleotides of the sequences.
for (my $i = 0; $i < scalar(@seqa); $i++) {
    print "-" x 79;
    print "\n";
    printf('%3d:  ', $i + 1);
    print $seqa[$i]->display_id();
    print ", " . $seqa[$i]->length();
    print($seqa[$i]->alphabet() eq 'protein' ? 'aa' : 'nt');
    print "\n";
    print " " x 6;
    print $seqa[$i]->trunc(1, 60)->seq() . "...\n\n";
}

print "Enter number(s) or ID(s) to BLAST (separate with commas or spaces).  " .
      "RefSeq\nand GI IDs are supported IF they were present in the " .
      "original FASTA file.\n";

my $resp = <STDIN>;

chomp($resp);

my @blast_seqs = split(/[, ]+/, $resp);

# Exit if no sequences were provided for BLAST.
unless (@blast_seqs) {
    print "No sequences selected for BLAST, exiting....";
    exit;
}

my @results;

# BLAST the selected sequences and store their results in the array of results.
for (@blast_seqs) {
    my $s;     # Sequence to pass to BLAST.
    
    if (exists $seqh{$_}) {
        # Given an ID, run a BLAST with the corresponding sequence or its
        # translation.
        $s = ${$seqh{$_}};
    } elsif (m// && $_ > 0 && $_ <= scalar(@seqa)) {
        # Given an index number, run a BLAST with the corresponding sequence
        # or its translation.
        $s = $seqa[$_ - 1];
    } else {
        die "Invalid ID or number $_ given: $!";
    }
    
    # Put the sequence in the appropriate array of sequences for BLAST.
    if ($s->alphabet ne 'protein') {
        $s = $s->translate();
    }
    
    push @results, blast_sequence($s);
}

for my $r (@results) {
    my $t = strftime('%Y-%m-%d %H%M%S', localtime);
    
    my $qid = $r->query_name();
    $qid =~ s/gi\|/GI_/g;
    $qid =~ s/ref\|/Ref_/g;
    $qid =~ s/\|/ /g;
    
    my $outpath = "$qid BLAST Report_$t.txt";
    
    open my $fh, '>', $outpath;
    close $fh;
    
    write_blast($outpath, $r);
    
    # my $writer = new Bio::SearchIO::Writer::TextResultWriter();
    
    # my $rpth = Bio::SearchIO->new(-writer   => $writer,
                                  # -file     => $outpath);
    
    # $rpth->write_report($r);
    
#    my %paths = (rpt => "$qid BLAST Report_$t.txt",
#                 res => "$qid BLAST Result_$t.txt");
#    
#    my $writer = new Bio::SearchIO::Writer::TextResultWriter();
#    
#    for (keys %paths) {
#    	open my $fh, '>', $paths{$_};
#    	close $fh;
#    }
#    
#    my $w_rpt = Bio::SearchIO->new(-writer  => $writer,
#                                   -file    => $paths{rpt});
#    
#    my $w_res = Bio::SearchIO->new(-writer  => $writer,
#                                   -file    => $paths{res});
#    
#    $w_rpt->write_report($r);
#    
#    $w_res->write_result($r);
}

print "-" x 79;
print "\n";
print scalar(@blast_seqs) . " sequence" .
      (scalar(@blast_seqs) > 1 ? "s" : "") . " sent to BLAST.\n";
