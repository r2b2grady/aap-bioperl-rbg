package RestrictionEnzyme;

use Exporter 'import';
use Moose;
use Moose::Util::TypeConstraints;

# Created on: Jul 23, 2016
# Written by: Robert Grady

=pod

=head1 RestrictionEnzyme
A C<Moose> class that represents a Restriction Enzyme.

=head1 Attributes
=head2 C<name>
The C<name> attribute stores the name of the Restriction Enzyme.  If no value
is specified, the class will throw an error and exit.

=head2 C<mfr>
The C<mfr> attribute stores the name of the Restriction Enzyme's manufacturer.
If no value is specified, the default value of 'Unknown' will be used.

=head2 C<recseq>
The C<recseq> attribute stores the Restriction Enzyme's recognition sequence.
If no value is specified, the class will throw an error and exit.

In addition to the standard "ACGT" abbreviations, C<recseq> supports the
following abbreviations:
    - C<R>:  G or A
    - C<Y>:  C or T
    - C<M>:  A or C
    - C<K>:  G or T
    - C<S>:  G or C
    - C<W>:  A or T
    - C<B>:  C, G, or T
    - C<D>:  A, G, or T
    - C<H>:  A, C, or T
    - C<V>:  A, C, or G
    - C<N>:  A, C, G, or T
    - C<^>:  Cleavage site.

If no cleavage site is specified, the class assumes that the site is one base
away from the end of the sequence.  For example, the recognition sequence
"ACCG^GT" would be split into "ACCG  GT", but "ACCGGT" would be split into
"ACCGG  T".

=head1 Functions
=head2 C<rs_patt>
The C<rs_patt> function returns a string containing a Regexp pattern that
describes the recognition sequence for use in the C<split> function.  For
example, the recognition sequence "ACCG^GT" would produce the pattern
"ACCG\K(?=GT)", while the recognition sequence "ACCNNNN^GGT" would produce the
pattern "AC{2}[ACGT]{4}".

=head2 C<cut_dna>
The C<cut_dna> function takes a DNA sequence and returns a list of DNA digests
cut by the Restriction Enzyme.  For example, passing the sequence
"CTGGAATTCAACGGGAGAATTCAG" to an EcoRI Restriction Enzyme object (Recognition
Sequence "G^AATTC") would return the list ["CTGG", "AATTCAACGGG", "AG",
"AATTCAG"].

=head1 Interactions with Other Programs
Because this is a Moose object, it will work well with most other Perl programs
with a minimum of fuss.  It does, however, have a tendency to byte dentists.
And as I'm sure you're aware, Moose bytes can be pretty nasty. 

=cut

my $Version = 1.0.0;

# Prototype functions.
sub cut_dna($);
sub rs_patt();

# Recognition Sequence subtype.
subtype 'RecSeq'
    => as 'Str'
    => where { $_ =~ m/^[ACGTRYMKSWBDHVN]*\^?[ACGTRYMKSWBDHVN]*$/i &&
    	       $_ !~ m/^\^$/};

# Name attribute.
has name => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1
);

# Manufacturer attribute.
has mfr => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'Unknown'
);

# Recognition sequence attribute,
has recseq => (
    is          => 'rw',
    isa         => 'RecSeq',
    required    => 1
);

# Returns a Regexp pattern that describes the recognition sequence for the
# purpose of splitting the sequence.
sub rs_patt() {
    my $self = shift;
	
    my $rs = $self->recseq();
	
    my $n = length($rs);
	
    # Hash of ambiguity abbreviations.  Abbreviations taken from
    # http://www.bioinformatics.nl/molbi/SCLResources/sequence_notation.htm,
    # section 'Restriction Enzymes'.
    my %abbr = (R => '[GA]',
                Y => '[CT]',
                M => '[AC]',
                K => '[GT]',
                S => '[GC]',
                W => '[AT]',
                B => '[CGT]',
                D => '[AGT]',
                H => '[ACT]',
                V => '[ACG]',
                N => '[ACGT]');
    
    # Shorten repeated base expressions (e.g., 'AAAA' becomes 'A{4}')
    my $dups = join '', keys(%abbr);
    $dups = "(([ACGT$dups])\\2+)";
    if ($rs !~ m/\^/) {
    	$dups .= "(?=.+?\$)"
    }
    
    print "--------\n$dups\n--------\n";
    
    while ($rs =~ m/$dups/i) {
        # Get the exact string to match.
        my $s = $1;
    	# Get the base that's being repeated.
    	my $b = $2;
    	# Get the number of times it's repeated.
    	my $x = length($s);
    	# Replace the current run with the compacted version.
    	$rs =~ s/$s/$b\{$x\}/;
    }
    
    # Convert all ambiguity abbreviations to Regexp syntax.
    for (keys %abbr) {
    	$rs =~ s/$_/$abbr{$_}/gi;
    }
    
    # List of the two portions of the recognition site sequence.
    my @rs = ();
    
    # Check if the sequence has the specific cleavage site specified.
    if ($rs =~ m/\^/) {
    	# Specific site specified, split by the marker.
    	@rs = ($rs =~ m/^(.*)\^(.*)$/);
    } else {
    	# No specific site specified, assume it cuts one base away from the 3'
    	# end of the recognition sequence.
    	@rs = ($rs =~ m/^(.*)(.)$/);
    }
    
    # Assemble and return the pattern, making sure to handle items where the
    # site is cut at the beginning or end of the sequence.
    return (($rs[0] ? "$rs[0]\\K" : "") . ($rs[1] ? "(?=$rs[1])" : ""));
}

# Returns an array of digests, given a specific DNA sequence.
sub cut_dna($) {
	my ($self, $seq) = @_;
	
	# Get a Regex pattern for the recognition site.
	my $patt = $self->rs_patt();
	
	# Split and return the input sequence.
	return split($patt, $seq);
}

1;