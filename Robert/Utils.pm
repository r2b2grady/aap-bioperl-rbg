package Robert::Utils;

use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(mult_table randseq arrstohash printhoa digref);

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

# Digs down through a recursive reference to return a reference to the ultimate
# referent.
sub digref($) {
	my ($r) = @_;
	
	while (ref($r) =~ m/^REF/) {
		$r = $$r;
	}
	
	return $r;
}

# Takes two arrays and returns a hash with the first array's items as the keys
# and the second array's items as the values.  If the key array is longer than
# the value array, then empty strings will be provided for the missing values.
# If the key array is shorter than the value array, the function dies.
sub arrstohash($$) {
	my ($k, $v) = @_;
	my %h;
	
	# Dig down through recursive references.
	$k = digref($k);
	$v = digref($v);
	
	# Make sure we have arrays.
	die "Non-array ref passed as key array." unless ref($k) =~ m/^ARRAY/;
	die "Non-array ref passed as value array." unless ref($k) =~ m/^ARRAY/;
	
	# Make sure the key array is at least as long as the value array.
	die "Arrays are of unequal lengths." unless scalar(@$k) == scalar(@$v);
	
	# Loop through indices of key array.
	for (my $i = 0; $i < scalar(@$k); $i++) {
		# If the current index is greater than the final index of the value
		# array, add an empty value, otherwise add the corresponding value of
		# the value array.
		$h{$$k[$i]} = ($#$v < $i ? '' : $$v[$i]);
	}
	
	return %h;
}

# Prints a hash of arrays.
sub printhoa($) {
	my ($hoa) = @_;
	
	$hoa = digref(\$hoa);
	
	die "Non-hash ref passed!" unless ref($hoa) =~ m/^HASH/;
	
	# Loop through keys.
	for (sort keys(%$hoa)) {
		print "$_:\n";
		for (my $i = 0; $i < scalar(@{$hoa->{$_}}); $i++) {
			print "\t$i:\t$hoa->{$_}[$i]\n";
		}
	}
}

1;