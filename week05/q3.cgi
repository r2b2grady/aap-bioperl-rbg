#!/usr/bin/perl
use strict;
use warnings;

use CGI qw(:standard);

# Hash of different 
my %pieces = (dna   => qw(A C G T),
              aa    => qw(A C D E F G H I K L M N P Q R S T V W Y));

my %type_name = (dna => 'DNA Nucleotide',
                 aa  => 'Amino Acid');

# Takes a sequence type (1st arg; aa = amino acid, dna = DNA nucleotide) and
# length (2nd arg), generates a random sequence of the specified type and
# length, and returns the sequence.
sub getrand($$) {
	my ($type, $len) = @_;
	
	# Convert type to lower-case.
	$type =~ s/^(.*)$/\L$1\E/;
	
	die "Invalid type parameter '$type'" unless exists $pieces{$type};
	
	my $seq = "";
	
	for (1..$len) {
		my $x = int(rand(scalar(@{$pieces{$type}})));
		$seq .= $pieces{$type}[$x];
	}
}

my $title = 'DNA/Amino Acid Randomizer';
print header, start_html($title), h1($title);

# Handle processing of form if this was called as a form submission.
if (param('submit')) {
	my $type   = param('type');
	my $seq    = getrand($type, 50);
	
	print p("Your random sequence of 50 $type_name{$type}s is:"),
	      p("$seq"), hr();;
}

my $url = url();

print start_form(-method => 'GET', action => $url),
      p("Select sequence type: " .
        popup_menu(-name => 'type',
                   -values => [sort keys(%type_name)],
                   -labels => \%type_name)),
      p(submit(-name => 'submit', -value => 'Generate 50mer')),
      end_form(),
      end_html();