#!/usr/bin/perl

use v5.10.1;

use Cwd;

use strict;
use warnings;

my $verbose = 0;        # If true, lists ALL runs in each file.

opendir(my $dh, getcwd());

# Get a list of all "seq#" and "seq#.#" files in the current directory.
my @files = grep { $_ =~ m/^seq\d+(?:\.\d+)?$/ && -f "./$_" } readdir $dh;

closedir $dh;

for (@ARGV) {
	if (m/^-v/) {
		$verbose = 1
	} elsif (m/^-[h\?]/) {
		print "Searches all files with names in the formats 'seq#' and " .
		      "'seq#.#' for runs of 4 or more of the same nucleotide. If " .
		      "given the flag '-v', prints output in VERBOSE mode (i.e. " .
		      "lists ALL runs and the lengths of the runs).";
		exit;
	}
}

# Loop through the files, processing them one line at a time.
for (@files) {
	open my $fh, "<:utf8", "./$_";
	
	while (<$fh>) {
		if (m/(([ACGT])\2{3+})/) {
			if ($verbose) {
				print "$2 run of " . length($1) . " nt found in ./$_.\n"
			} else {
				print "$2 run found in ./$_.\n";
				last;
			}
		}
	}
	
	close $fh;
}
