package week06::q1_Functions;

use strict;
use warnings;

use Exporter 'import';

use DBI;

our @EXPORT = qw(parsefasta loadschema);
our @EXPORT_OK = qw(parsefasta loadschema);

=pod
=head1 Name
week06::Functions - Module containing the C<loadschema> and C<parsefasta>
functions for use in the Week 6 problems.

=head1 Description
This module provides a function to load a schema into a SQLite database and a
function that parses a FASTA file and returns an array of the sequences
contained in the FASTA file (each represented by a hash).

=head2 loadschema
The C<loadschema> function takes two arguments.  The first argument specifies
the database file into which to load the schema.  The second argument specifies
the SQL file that contains the schema.

=head2 parsefasta
The C<parsefasta> function takes a FASTA file path, reads all the sequences
from the file, and returns an array of hashes that describes the sequences.
Each hash will contain the keys C<name>, C<org> (organism name), C<seq>
(sequence), C<tiss> (tissue name), C<expr> (expression level), C<start> (ORF
start), and C<stop> (ORF stop).

=cut

# Load the given schema (arg 2) into the given SQLite database file (arg 1).
sub loadschema($$) {
	my ($dbf, $sqlf) = @_;
	
	die "Unable to find database file: $!" unless -e $dbf;
	die "Unable to find SQL file: $!" unless -e $sqlf;
	
	my $dbh = DBI->connect("DBI:SQLite:dbname=$dbf", "", "",
	                       {PrintError => 0, RaiseError => 1});
    
    # SQL String to run on the SQLite database.
    my $sqlstr = "";
    
    # Load the SQL from the schema file.
    open my $fh, "<", $sqlf;
    $sqlstr .= $_ while <$fh>;
    close $fh;
    
    # Split the SQL by semicolons.
    my @st = split(/;\K\n+/, $sqlstr);
    
    # Apply each separate statement to the database, allowing for a rollback
    # if an error is encountered.
    my $sth = $dbh->prepare("BEGIN TRANSACTION;");
    $sth->execute() || die "Unable to start transaction: " . $sth->errstr();
    
    for (@st) {
    	# Prepare the current statement.
    	$sth = $dbh->prepare($_);
    	# Execute statement.  If an error is encountered, roll back all
    	# applied statements and exit with an error message.
    	unless ($sth->execute()) {
    		$sth = $dbh->prepare("ROLLBACK TRANSACTION;");
    		$sth->execute();
    		
    		die "Error in executing $_: " . $sth->errstr . "\n" .
    		    "Changes not saved."
    	}
    }
    
    $sth = $dbh->prepare("COMMIT TRANSACTION;");
    $sth->execute() || die "Unable to commit changes: " . $sth->errstr();
    
    $dbh->disconnect();
}

# Parse the given FASTA file and return an array of hashes.
sub parsefasta($) {
	my ($fpath) = @_;
	
	die "Unable to find FASTA file: $!" unless -e $fpath;
	
	# Output array.
	my @out;
	
	# Storage variable for the FASTA sequence on which we're currently working.
	my %curr = ();
	
	open my $fh, "<", $fpath;
	
	while (<$fh>) {
		if (m/^>/) {
			# If the current line describes a new FASTA sequence, add %curr to
			# the output array IF $curr{seq} is not blank, then start a new
			# current sequence.
			push @out, {%curr} if $curr{seq};
			# Reset %curr.
			%curr = ();
			
			# Remove the starting ">" along with any whitespace after the angle
			# bracket.
			s/^>\s*//;
			
			# Remove trailing line break.
			chomp();
			
			my @fields = split(/\s*\|\s*/, $_);
			
			$curr{name}  = $fields[0];
			$curr{org}   = $fields[1];
			$curr{tiss}  = $fields[2];
			$curr{start} = $fields[3];
			$curr{stop}  = $fields[4];
			$curr{expr}  = $fields[5];
		} else {
			# The current line does NOT describe a new FASTA sequence.  Chomp it
			# and append it to the current sequence.
			chomp();
			$curr{seq} .= $_;
		}
	}
	
	push @out, {%curr} if $curr{seq};
	
	close $fh;
	
	return @out;
}

1;