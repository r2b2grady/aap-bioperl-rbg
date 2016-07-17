package week07::q8;

use Exporter 'import';

# Created on: Jul 16, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

our @EXPORT = qw(translate_dna);
our @EXPORT_OK = qw(translate_dna);

=pod

=head1 week07::q8
Contains the C<translate_dna> function, which takes a DNA sequence, finds the
start of the ORF, and translates the DNA sequence to a protein sequence.

=cut

# Hash of codons.
my %dna_map = (GCT => 'A',    GCC => 'A',    GCA => 'A',    GCG => 'A',
               TTA => 'L',    TTG => 'L',    CTT => 'L',    CTC => 'L',
               CTA => 'L',    CTG => 'L',    CGT => 'R',    CGC => 'R',
               CGA => 'R',    CGG => 'R',    AGA => 'R',    AGG => 'R',
               AAA => 'K',    AAG => 'K',    AAT => 'N',    AAC => 'N',
               ATG => 'M',    GAT => 'D',    GAC => 'D',    TTT => 'F',
               TTC => 'F',    TGT => 'C',    TGC => 'C',    CCT => 'P',
               CCC => 'P',    CCA => 'P',    CCG => 'P',    CAA => 'Q',
               CAG => 'Q',    TCT => 'S',    TCC => 'S',    TCA => 'S',
               TCG => 'S',    AGT => 'S',    AGC => 'S',    GAA => 'E',
               GAG => 'E',    ACT => 'T',    ACC => 'T',    ACA => 'T',
               ACG => 'T',    GGT => 'G',    GGC => 'G',    GGA => 'G',
               GGG => 'G',    TGG => 'W',    CAT => 'H',    CAC => 'H',
               TAT => 'Y',    TAC => 'Y',    ATT => 'I',    ATC => 'I',
               ATA => 'I',    GTT => 'V',    GTC => 'V',    GTA => 'V',
               GTG => 'V',    TAA => '!',    TGA => '!',    TAG => '!');

sub translate_dna($) {
	my ($seq) = @_;
	
	# Dig down through any nested references.
	$seq = $$seq while ref($seq) =~ m/^(?:REF|SCALAR)/;
	
	# Handle a non-scalar value input.
	die "Non-scalar value passed to translate_dna: " unless ref($seq) eq '';
	
	# Convert to all uppercase.
	$seq = uc($seq);
	
	# Handle invalid DNA sequence.
	die "Invalid DNA sequence $seq passed to translate_dna: "
	       if $seq =~ m/[^ACGT]/;
    
    # Find the ORF.  Return an empty string if no start codon was found.
    $seq =~ m/(ATG(?:[ACGT]{3})+)/;
    my $orf = $1;
    
    unless ($orf) {
    	return;
    }
    
    # Interpret the ORF.
    my @codons = ($orf =~ m/([ACGT]{3})/g);
    my $out = "";
    
    for (@codons) {
    	if ($dna_map{$_} eq '!') {
    		# Stop codon:  Exit loop and return AA sequence.
    		last;
    	} else {
    		$out .= $dna_map{$_};
    	}
    }
    
    return $out;
}
