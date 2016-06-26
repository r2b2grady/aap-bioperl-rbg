package week04::q3;

use strict;
use warnings;

use Exporter 'import';

our @EXPORT = qw(randseq);
our @EXPORT_OK = qw(randseq);

=pod
=head1 Name
week04::q3 - Module containing the C<randseq> function.

=head1 Synopsis
C<use week04::q3 qw(randseq);>
C<my $seq1 = randseq(50)>
C<my $seq2 = randseq(50, 1)>

=head1 Description
This module provides a function that generates a random DNA sequence of the
specified length or, if directed to do so, a random DNA sequence with a random
length.

=head2 randseq
The C<randseq> function takes 1 or 2 arguments and returns a random sequence of
DNA nucleotides (as represented by the characters 'A', 'C', 'G', 'T').

When the function is given only one argument I<or> when the second argument
evaluates to B<false>, the first argument is taken as the length of the
sequence to generate.

When the second argument evaluates to B<true>, the function will generate a
random length for the random sequence, using 1 as the lower limit and the first
argument as the upper limit.

=head3 Examples
Generate a sequence of length 117 and store it in the C<$seq> variable.
C<use week04::q3 qw(randseq);>
C<my $seq = randseq(117);>

Generate a sequence with length between 1 and 74 and store it in the C<$seq>
variable.
C<use week04::q3;>
C<my $seq = randseq(74, 1);>

=cut

# Generates a random DNA sequence with the given length (first parameter). If
# the second parameter is true, the function generates a random length between
# 1 and the first parameter.
sub randseq($;$) {
    my ($len, $randlen) = @_;
    
    # Randomize the length parameter if a second parameter was given.
    $len = int(rand $len) + 1 if $randlen;
    
    my @nt = qw(A C G T);
    
    my $seq = "";
    
    for (1..$len) {
        $seq .= $nt[int(rand(scalar(@nt)))];
    }
    
    return $seq;
}