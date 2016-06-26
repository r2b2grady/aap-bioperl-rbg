#!/usr/bin/perl
use strict;
use warnings;

use lib "~/proj/";

use Test::Simple tests => 8;
use week04::q3 qw(randseq);

my @len;

for (1..4) {
	push @len, int(rand(100) + 1) + 50;
}

$, = "\n";
print (@dna, "");

ok(length($dna[0]) == $len[0], "randseq(num): String Length OK.");
ok($dna[0] !~ m/[^ACGT]/, "randseq(num): String Composition OK.");
ok(length($dna[1]) == $len[1], "randseq(num, 0): String Length OK.");
ok($dna[1] !~ m/[^ACGT]/, "randseq(num, 0): String Composition OK.");
ok($len[2] >= length($dna[2]) && length($dna[2]),
        "randseq(num, str): String Length OK.");
ok($dna[2] !~ m/[^ACGT]/, "randseq(num, str): String Composition OK.");
ok($len[3] >= length($dna[3]) && length($dna[3]),
        "randseq(num, 1): String Length OK.");
ok($dna[3] !~ m/[^ACGT]/, "randseq(num, 1): String Composition OK.");
