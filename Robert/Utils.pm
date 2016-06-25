package Robert::Utils;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(mult_table randseq);

# Prints the multiplication table from 1 to the given limit. If no value is
# specified, the default variable '$_' will be used.
sub mult_table(_) {
    my ($lim) = @_;
    my $s = "";
    
    for my $a (1..$lim) {
        # Loop through the values of factor B and print the value "A x B".
        for my $b (1..$lim) {
            $s .= sprintf("% 4d", $a * $b);
        }
        
        # Start a new line.
        $s .= "\n";
    }
}

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

1;