#!/usr/bin/perl
use strict;
use warnings;

# Created on: Jul 16, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

=pod

=encoding utf8

Takes an oligo sequence and computes the annealing temperature and GC content,
assuming 2 degrees C per A or T and 4 degrees C per C or G for annealing temp.

=head2 Usage Examples
C<q5.pl>, C<q5.pl -h>, C<q5.pl --help>
    Display this help text.

C<q5.pl SEQUENCE>
    Compute and print the GC content and estimated annealing temperature of the
    DNA oligo C<SEQUENCE>.

C<q5.pl -s SEQUENCE>, C<q5.pl --simple SEQUENCE>
    Compute and print the GC content and estimated annealing temperature of the
    DNA oligo C<SEQUENCE> as a pair of comma-delimited numbers.  Useful when
    passing the output to another program.  GC content is also provided as a
    decimal representation in this mode.

=cut

# If true, use simple output.
my $simp = 0;

# Contains the sequence to analyze.
my $oligo;

# Process command-line arguments
for (@ARGV) {
	if (m/^-(?:[h\?]|-help)/) {
		# If user asked for help, print perldoc and exit.
		print `perldoc $0`;
		exit;
	} elsif (m/^-(?:s|-simple)/) {
		# If simple mode was requested, turn simple mode on.
		$simp = 1;
	} elsif (m/^-/) {
		# Handle unrecognized option flags.
		warn "Program received unrecognized flag '$_' (flag ignored)"
	} elsif (m/^[ACGT]+$/i) {
		# Parse sequence.  Do NOT overwrite a previous sequence.
		$oligo = $_ unless $oligo;
	} else {
		# Handle non-DNA sequence arguments.
		warn "Program received non-DNA parameter '$_' (parameter ignored)"
	}
}

# If no DNA sequence was provided, print perldoc and exit.
unless ($oligo) {
	if (@ARGV) {
		warn "No DNA sequence provided.  Printing documentation.\n"
	}
	print `perldoc $0`;
	exit;
}

# Annealing temperature.
my $gc = scalar(() = $oligo =~ m/([CG])/gi);
my $t = (scalar(() = $oligo =~ m/([AT])/gi) * 2) + ($gc * 4);
$gc = $gc / length($oligo);

# Print output formatting unless in simple mode.
print "Sequence:       $oligo\nAnnealing Temp: " unless $simp;

print $t;

if ($simp) {
	print ",";
} else {
	print " C\nGC Content:     ";
}

if ($simp) {
	print $gc
} else {
    printf("%5.2f", $gc * 100);
}

print ' %' unless $simp;
print "\n";