#!/usr/bin/perl
use strict;
use warnings;

# Created on: Aug 22, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

use Bio::DB::GenBank;
use Bio::SeqIO;
use Bio::Tools::Run::RemoteBlast;
use POSIX qw(strftime);

=pod

q6.pl

=head1 DESCRIPTION

Performs a BLAST on the protein sequence with the given accession number and
outputs all aligned sequences with expected values lower than the specified
cutoff to files in the current directory.

=head1 USAGE

q6 ACCN EXPECT


=head2 ARGUMENTS

=over

=item ACCN

The Accession Number for the protein sequence to retrieve. Program returns an
error if the sequence is not a protein.

=item EXPECT

The non-inclusive cutoff for expected value. Only sequences with an expected
value less than this value will be stored in files.

=back

=cut

my ($accn, $e_val) = @ARGV;

# Print POD and exit if insufficient arguments were provided.
unless (@ARGV > 1) {
	print `perldoc $0`;
	exit;
}

# Retrieve the sequence from the GenBank database.
my $gbh = Bio::DB::GenBank->new();

my $seq = $gbh->get_Seq_by_acc($accn);

# Die if the sequence isn't a protein.
die "[$accn] is not a protein!" unless $seq->alphabet eq 'protein';

# BLAST the sequence.
my $blaster = Bio::Tools::Run::RemoteBlast->new(-prog         => 'blastp',
                                                -expect       => $e_val,
                                                -readmethod   => 'SearchIO');

#   Hash of BLAST errors.
my %blast_err = (1 => 'BLAST returned status error',
                 2 => 'No content returned',
                 4 => 'HTTP request failed',
                 8 => 'BLAST returned non-status error');

my $r = $blaster->submit_blast($seq);

#   Time-tracking variables.
my $start = time;
my @t = ($start, $start);
my $tstr = "";

print STDERR "BLAST submitted for [$accn] ";

sleep 5;

my $res;

BLAST :
while (my @rids = $blaster->each_rid) {
    for my $rid (@rids) {
        my $rc = $blaster->retrieve_blast($rid);
        
        if (ref $rc) {
            $res = $rc->next_result();
            $blaster->remove_rid($rid);
            print STDERR " - Finished\n";
            last BLAST;
        } elsif (0 > $rc) {
            # BLAST returned error, print error code
            $blaster->remove_rid($rid);
            print "BLAST error $rc:\n";
            for (keys %blast_err) {
                if ($_ & $rc) {
                    print "    $blast_err{$_}\n";
               }
            }
        } else {
            $t[1] = time;
            
            if ($t[0] != $start) {
                print STDERR "\b" x length($tstr);
                
                $tstr = strftime('%Hh %Mm %Ss',
                                 gmtime($t[1] - $start));
            }
            
            print STDERR $tstr;
            
            $t[0] = $t[1];
            
            sleep 5;
        }
    }
}

# Number of files written.
my $n;

# Loop through the hits.
while (my $h = $res->next_hit()) {
	my $h_seq;
	my $h_id;
	
	if ($h->accession) {
		$h_seq = $gbh->get_Seq_by_acc($h->accession);
		$h_id = $h->accession;
	} else {
		$h_seq = $gbh->get_Seq_by_id($h->name);
		$h_id = $h->name;
	}
	
	my $out = Bio::SeqIO->new(-file    => ">$h_id.fasta",
	                          -format  => "fasta");
    
    $out->write_seq($h_seq) || die "Unable to write [$h_id] to file: $!";
    
    $n++;
    
    my $str = "$n files written";
    print "\b" x length($str) if $n > 1;
    print "    $str";
}
print "\nBLAST processing complete.";