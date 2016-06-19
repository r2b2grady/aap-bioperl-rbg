#!/usr/bin/perl

use v5.10.1;

use Cwd;

use strict;
use warnings;

my $verbose = 0;        # If true, lists ALL runs in each file.

opendir(my $dh, getcwd()) || die "Unable to open directory "
                                 . getcwd() . ": $!";

# Get a list of all "seq#" and "seq#.#" files in the current directory.

my @files = sort(grep {
                       $_ =~ m/^seq\d+(?:\.\d+)?$/ && -f "./$_"
                      } readdir $dh);

closedir $dh;

for (@ARGV) {
	if (m/^-[h\?]/) {
		print "Searches all files with names in the formats 'seq#' " .
		      "and 'seq#.#' for runs of 4\nor more of the same " .
		      "nucleotide.\n";
		exit;
	}
}

# Loop through the files, processing them one line at a time.
for my $f (@files) {
    open my $fh, "<:utf8", "./$f" || die "Unable to open file $f: $!";
    
    while (<$fh>) {
	if (m/([ACGT])\1{3}/) {
	    print "$1 run found in ./$f.\n";
	    last;
	}
    }
    
    close $fh;
}
