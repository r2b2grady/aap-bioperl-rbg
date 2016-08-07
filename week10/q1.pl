#!/usr/bin/perl
use strict;
use warnings;

# Created on: Aug 7, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

use Bio::DB::GenBank;
use Bio::DB::GenPept;
use Bio::SearchIO;
use Bio::Tools::Run::RemoteBlast;
use List::Util qw(max);

sub ns_blast($);
sub hdr($$$);

=pod

=head1 Double-BLAST
q1.pl - Takes an Accession Number, BLASTs the corresponding sequence (BLASTn if
given a nucleotide ACC #, BLASTp if given a protein ACC #), takes the first
non-self match, BLASTs that sequence, and returns the first non-self match of
the second BLAST.

=head1 Usage
q1.pl [OPTIONS]

The program supports the following option flags:
    -h, -?, --help      Print this help text.
    -a [ACCN]           Specify the Accession Number to use.  Program prompts
                        user by default.
    -q, --quiet         Run in Quiet Mode--do not print anything between
                        receiving the Accession Number to BLAST and printing
                        the output.

=cut

my $accn;       # Accession Number.
my $quiet;      # If TRUE, run in Quiet Mode.

# Process command-line arguments.
while (@ARGV) {
	my $a = shift;
	
	if ($a =~ m/^-/) {
        $a =~ s/^-//;
        if ($a =~ m/^a$/) {
            # Specify Accession # with '-a' flag.  Subsequent Accession definitions
            # are ignored.
            $accn = shift unless $accn;
        } elsif ($a =~ m/^(?:-help|h|\?)$/) {
            # Print help text with '--help', '-h', or '-?' flag, then exit.
            print `perldoc $0`;
            print "\n";
            exit;
        } elsif ($a =~ m/^q$/) {
        	$quiet = 1;
        }
    }
}

# If no Accession Number was specified, prompt the user for one.
unless ($accn) {
    print "Enter Accession Number to BLAST:  ";
    $accn = <STDIN>;
    chomp $accn;
}

# Declare GenBank database handler.
my $gbh = Bio::DB::GenBank->new();

# Get the sequence for the corresponding Accession Number.
my $seq = $gbh->get_Seq_by_acc($accn);

# Set up BLAST factory.
my %params = (-expect       => '1e-10',
              -readmethod   => 'SearchIO');

$params{-prog} = ($seq->alphabet eq 'protein' ? 'blastp' : 'blastn');

my $blaster = Bio::Tools::Run::RemoteBlast->new(%params);

my $outseq = ns_blast($seq);

unless (defined $outseq) {
	# Exit if the first BLAST doesn't return any data.
	print '+' x 8 . " No matches found for accession $accn " . '+' x 8 . "\n";
	exit;
}

print hdr(" Results For $accn ", 79, '=') . "\n";

unless (defined $outseq) {
	# Exit if we didn't find a sequence.
	print '+' x 8;
	print hdr(" No sequence found", 63, ['', ' ']);
	print '+' x 8 . "\n";
	exit;
}

if ($seq->accession eq $outseq->accession || $seq->id eq $outseq->id) {
	print '+' x 8;
	print hdr(" Result sequence matches initial search sequence", 63,
	          ['', ' ']);
	print '+' x 8 . "\n";
}

# Get the type of sequence (i.e. alphabet) and apply standard capitalization.
my $type = $outseq->alphabet;
$type =~ s/(^p(?=rot)|[rd]na)/\U$1/;

# Get the species object for the output sequence.
my $spec = $outseq->species;

print "Accession:  " . $outseq->accession . "\n";
print "Name:       " . $outseq->display_id . "\n";
print "GI:         " . $outseq->primary_id . "\n";
print "Type:       $type";
print "Desc:       " . $outseq->desc . "\n";
print "Species:    " . $spec->common_name . "\n";
print '' x  12 . "(" . $spec->genus . " " . $spec->species;
print " " . $spec->sub_species if $spec->sub_species;
print ")\n";
print "[variant " . $spec->variant . "]\n" if $spec->variant;


# Using the '$blaster' BLAST factory variable, runs a BLAST on the given
# sequence and returns the first non-self match as a SeqI object.  The given
# sequence must be a Bio::SeqI object OR undefined.  If the input sequence is
# undefined, the function returns undef.  If no match is found, the function
# returns undefined.
sub ns_blast($) {
    my ($seq) = @_;
    
    return undef unless defined $seq;
    
    # Handle invalid inputs and other error conditions.
    die "GenBank DB handler not yet defined: $!" unless defined $gbh;
    die "BLAST factory not yet defined: $!" unless defined $blaster;
    die "Invalid sequence parameter passed to ns_blast: $!"
            unless $seq->isa("Bio::SeqI");
    
    my $r = $blaster->submit_blast($seq);
    
    unless ($quiet) {
        print STDERR "BLAST submitted for ";
        if ($seq->accession()) {
        	print STDERR "Accn [" . $seq->accession;
        } else {
    	   print STDERR "ID [" . $seq->id;
        }
        print STDERR "] ";
    }
    
    sleep 5;
    
    my $res;
    
    BLAST :
    while (my @rids = $blaster->each_rid) {
        for my $rid (@rids) {
            my $rc = $blaster->retrieve_blast($rid);
            
            if (ref $rc) {
                $res = $rc->next_result();
                $blaster->remove_rid($rid);
                last BLAST;
            } elsif (0 > $rc) {
                $blaster->remove_rid($rid);
            } else {
                print STDERR "." unless $quiet;
                sleep 5;
            }
        }
    }
    
    print STDERR "\n" unless $quiet;
    
    my $hit = $res->next_hit();
    
    # Loop through hits until the first non-self hit is found.
    while (defined $hit && ($hit->accession() eq $accn ||
                            $hit->name() eq $seq->display_id())) {
        $hit = $res->next_hit();
    }
    
    # If no non-self hit was found, return an undefined value.
    if (!defined $hit) {
        return undef;
    }
    
    # Find the SeqI object from GenBank for the current hit.
    if ($hit->accession) {
        # If the Accession Number is defined for the hit, find the sequence by
        # Accession #.
        return $gbh->get_Seq_by_acc($hit->accession);
    } else {
        # If the Accession Number is not defined for the hit, find the sequence
        # by ID/Name.
        return $gbh->get_Seq_by_id($hit->name);
    }
}

# Formats the given string as a header line with the given width and padding
# characters.  The first argument must contain the string to print OR an array
# of strings to print.  The second argument is the width of the total string.
# The third argument is the character to use for padding the string out to
# the total width OR a reference to a two-member list of characters to use
# for the left and right padding, respectively.
sub hdr($$$) {
	my ($str, $w, $p) = @_;
	
	my $n;
	
	$str = $$str while ref($str) eq 'REF';
	
	if (ref($str) eq 'ARRAY') {
		my @out = ();
		for (@$str) {
			push @out, hdr($_, $w, $p);
		}
		return [@out];
	} elsif (ref($str) eq '') {
        my @pad;
        
        # Set up left & right padding characters.
        if (ref($p) eq 'ARRAY') {
            @pad = @{$p}[0..1];
        } else {
            @pad = ($p, $p);
        }
    
		$n = max($w - length($str));
		my $out = $pad[0] x int($n / 2);
		$out .= $str;
		$out .= $pad[1] x int(($n / 2) + 0.5);
		return $out;
	} else {
		die "Invalid string passed to hdr: $!";
	}
}
