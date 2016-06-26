package week04::q2;

use strict;
use warnings;

use Exporter 'import';

our @EXPORT = qw(randseq);
our @EXPORT_OK = qw(randseq);

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