package ProteinFactory;

use Exporter 'import';
use Moose;

# Created on: Aug 19, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

my @aa = qw(A R N D C E Q G H I L K M F P S T W Y V);

=pod

=head1 q3
A C<Moose> class that represents a random protein sequence generator.

=head1 PARAMS
The available parameters are C<len>, C<random>, and C<min>, which correspond to
the length, a boolean value indicating whether the length will be randomized,
and the minimum length for random sequences, respectively.

=head1 FUNCTIONS
The C<ProteinFactory> class has only one function: C<getseq()>. This function
returns a randomized sequence with the parameters specified in the
C<ProteinFactory> object.

=cut

# 'len' attribute
has len => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1
);

# 'random' attribute
has random => (
    is          => 'rw',
    isa         => 'Int',
    default     => 0
);

# 'min' attribute
has min => (
    is          => 'rw',
    isa         => 'Int',
    default     => 1
);

sub getseq() {
	my $self = shift;
	
	my $len = $self->len;
	
	if ($self->random) {
		$len = int(rand($len - $self->min + 1)) + $self->min;
	}
	
	# Generate protein
	my $seq = "";
	
	for (1..$len) {
		$seq .= $aa[int(rand scalar(@aa))];
	}
}

1;