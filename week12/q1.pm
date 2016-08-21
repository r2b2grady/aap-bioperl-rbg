package week12::q1;

use Exporter 'import';

# Created on: Aug 16, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

our @EXPORT = qw(random_protein);
our @EXPORT_OK = qw(random_protein rand_prot rprot);

my @aa = qw(A R N D C E Q G H I L K M F P S T W Y V);

=pod

=head1 week12::q1
Contains the C<random_protein()> function, which generates a random protein.

=head2 Export
By default, only the C<random_protein()> function is exported, but the aliases
C<rand_prot()> and C<rprot()>


=head1 Functions

=cut


=pod

=head2 random_protein
The C<random_protein()> function takes one or two arguments. The first
argument indicates the length of the random protein to generate. If the second
argument evaluates to true, it indicates that the length should be randomized,
using the first argument as the maximum length and the second as the minimum.
If the second argument is non-numeric, then it will be converted to C<1>. 

=cut
sub random_protein($;$) {
	# Get arguments.
	my ($len, $is_rand) = @_;
	
	if ($is_rand) {
		# Handle non-numeric second argument.
		$is_rand = 1 unless $is_rand =~ m/^\d+$/;
		
		# Generate random length.
		$len = int(rand ($len - $is_rand + 1)) + $is_rand;
	}
	
	# Output string.
	my $prot = "";
	
	# Generate protein.
	for (1..$len) {
		$prot .= $aa[int(rand scalar(@aa))];
	}
	
	return $prot;
}


=pod

=head2 rand_prot, rprot
Aliases for C<random_protein()>. Both aliases take the same arguments.

=cut
sub rand_prot($;$) {
	return random_protein(@_);
}

sub rprot($;$) {
	return random_protein(@_);
}

1;