package week07::q7;

use Exporter 'import';

# Created on: Jul 16, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

our @EXPORT = qw(transtable);
our @EXPORT_OK = qw(transtable);

sub parseln($);

=pod

=head1 week07::q7
Contains the C<transtable()> function, which reads a two-dimensional array in
from a plain text table and returns the transposed version of said table.

=head1 transtable()
Takes an input file, a string containing a table with whitespace-delimited
data, or a reference to two-dimensional list, reads the input into a two-
dimensional array, and returns the transposition of the resulting array.  For
example, the input

        one     two     three
        four    five    six
        seven   eight   nine

would return:

        one     four    seven
        two     five    eight
        three   six     nine

=cut

# Read and transpose a table.
sub transtable($) {
	my ($in) = @_;
	
	# Original table.
	my @orig = ();
	# Max number of columns in the input table.
	my $maxcol = 0;
	
	# Dig through nested references.
	$in = $$in while ref($in) =~ m/^(?:REF|SCALAR)/;
	
	# Interpret the input and form the original two-dimensional array.
	if (ref($in) eq 'ARRAY') {
		# A reference to an array was given: Assign the array to @orig
		@orig = @$in;
		
	} elsif (-f $in) {
		# A file path was given: 
		open my $fh, "<", $in || die "Cannot open file $in: $!";
		
		while (<$fh>) {
			s/\s*$//;
			if (length($_)) {
				push @orig, parseln($_);
			}
		}
		
		close $fh;
	} elsif (ref($in) eq '') {
		# A string was given: split it up and assign each line to the array.
		for (split('\r?\n', $in)) {
            s/\s*$//;
            if (length($_)) {
                push @orig, parseln($_);
			}
		}
	} else {
		# Input unrecognized: exit with error
		die "Invalid argument passed to transtable(): $!";
	}
	
	# Calculate the length of the longest sub-array and assign the value to
	# $maxcol.
	$maxcol = (sort {$b <=> $a} map { scalar(@{$_}) } @orig)[0];
	
	# Assemble the output list.
	my @out = ();
	
	for my $i (0..$maxcol - 1) {
		my @row = ();
		
		for my $j (0..$#orig) {
			push @row, $orig[$j][$i];
		}
		
		push @out, [@row];
	}
	
	# Return the output list.
	return @out;
}

# Private function for parsing lines of files/strings.
sub parseln($) {
	my ($ln) = @_;
	return [split('[^\S\r\n]+', $ln)];
}

1;