package week07::q6;

use Exporter 'import';

# Created on: Jul 16, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

our @EXPORT = qw(max_num min_num);
our @EXPORT_OK = qw(max_num min_num);

=pod

=head1 week07::q6
Contains the C<max_num()> and C<min_num()> functions.

=head1 Function Definitions
=head2 max_num()
Takes a list of numbers and returns the largest item provided.

=head2 min_num()
Takes a list of numbers and returns the smallest item provided.

=cut

# Return the largest number from the given list.
sub max_num(@) {
	my @n = sort { $b <=> $a } @_;
	return $n[0];
}

# Return the smallest number from the given list.
sub min_num(@) {
	my @n = sort { $a <=> $b } @_;
	return $n[0];
}

1;