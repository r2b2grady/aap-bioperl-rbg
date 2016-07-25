package RestrictionEnzyme;

use Exporter 'import';
use Moose;
use Moose::Util::TypeConstraints;

# Created on: Jul 23, 2016
# Written by: Robert Grady

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