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

use Test::Simple tests => 3;
use week07::q7;

my @input = ([[1, 2, 3],
              [4, 5, 6],
              [7, 8, 9]],
             './q7_input.txt',
             "one   two   three\nfour  five  six   \nseven eight nine");

my @expected = ("1\t4\t7\n2\t5\t8\n3\t6\t9",
                "one\tfive\tnine\ntwo\tsix\tten\n" .
                    "three\tseven\televen\nfour\teight\ttwelve",
                "one\tfour\tseven\ntwo\tfive\teight\nthree\tsix\tnine");

my @types = ("Array input",
             "File input",
             "String input");

for (my $i = 0; $i < scalar(@expected); $i++) {
	my @a = transtable($input[$i]);
	my @out = map { join("\t", @$_) } @a;
	ok(join("\n", @out) eq $expected[$i], $types[$i])
}
