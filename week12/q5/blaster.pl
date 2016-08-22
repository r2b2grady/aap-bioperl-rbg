#!/usr/bin/perl
use strict;
use warnings;

# Created on: Aug 21, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

use Bio::DB::GenBank;
use Bio::DB::GenPept;
use Bio::SearchIO;
use Bio::Tools::Run::RemoteBlast;
use POSIX qw(strftime);

=pod

=head1 BLASTER

Uses the specified BLAST algorithm and input type to perform a BLAST on the
specified accession number and outputs the result to the current directory in
a file named for the algorithm and query sequence, with a timestamp.



=head1 USAGE

blaster ALGORITHM INPUT_TYPE

blaster ALGORITHM INPUT_TYPE ACCN

=over

=item ALGORITHM

The BLAST algorithm to use for performing the query. Can be any of "blastn",
"blastp", "blastx", "tblastn", "tblastp", "tblastx".

=item INPUT_TYPE

The type of input. Must be "dna" or "protein".

=item ACCN

The accession number to use for the query. If it is not specified in the
command line, the tool will prompt the user.

=back

=cut

# Print the help and close if less than two arguments were provided.
unless (scalar(@ARGV) > 1) {
    print `perldoc $0`;
    exit;
}

# Get command-line arguments.
my ($alg, $type, $accn) = @ARGV;

# Convert algorithm and type to lowercase.
$alg = lc($alg);
$type = lc($type);

# Make sure the inputs are valid.
die "Invalid algorithm \"$alg\": $!" unless $alg =~ m/^t?blast[npx]/;
die "Invalid input type \"$type\": $!" unless ($type eq 'dna' ||
                                               $type eq 'protein');

# Make sure the specified input type and algorithm are compatible.
die "$alg requires protein input: $!" if ($type eq 'dna' &&
                                      $alg =~ m/p$|tblastn/);
die "$alg requires DNA input: $!" if ($type eq 'protein' &&
                                      $alg !~ m/p$|tblastn/);

# If no accession number was provided, prompt the user for one.
unless ($accn) {
    print "Enter accession number:  ";
    $accn = <STDIN>;
    chomp $accn;
}

# Database handler.
my $gbh;

if ($type eq 'dna') {
    $gbh = Bio::DB::GenBank->new();
} else {
    $gbh = Bio::DB::GenPept->new();
}

# Get the sequence.
my $seq = $gbh->get_Seq_by_acc($accn);

# Generate the output file path.
my $outfile = "$accn $alg" . strftime('_%Y-%m-%d %H%M', localtime) . '.blast';

# Perform the BLAST.
my $blaster = Bio::Tools::Run::RemoteBlast->new(-prog         => $alg,
                                                -expect       => '1e-10',
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

my $out = Bio::SearchIO->new(-output_format => 'blast',
                             -file          => ">$outfile");

$out->write_result($res);

print "Successfully wrote $alg result for [$accn] to $outfile.\n";