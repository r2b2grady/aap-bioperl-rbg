#!/usr/bin/perl

use v5.10.1;

use strict;
use warnings;

while (1) {
	print "Enter regex:  ";
	my $re = <STDIN>;
	chomp $re;
	print "Enter string, or 'exit' to exit:  ";
	my $str = <STDIN>;
	chomp $str;
	if ($str eq 'exit') {
		print "So long, and thanks for all the fish!\n";
		exit;
	} else {
		if ($str =~ m/$re/) {
			print "Match!\n";
		} else {
			print "No match!\n";
		}
	}
}
