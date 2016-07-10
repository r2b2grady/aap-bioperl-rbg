#!/usr/bin/perl
use strict;
use warnings;

# Get parent directory of this file.
my $dir = $0;

$dir =~ s{/[^/]*\.pl}{/};
chdir $dir;

# Include the path for the functions module.
use lib "..";
use DBI;
use week06::q1_Functions;

my $dbf = "q1_data.db";

# Create the database file unless it already exists.
unless (-e $dbf) {
	open my $fh, ">", $dbf || die "Cannot open $dbf: $!";
	close $fh;
}

# Load the schema.
loadschema($dbf, 'schema.sql');

# Load the FASTA data.
my @seq = parsefasta('data.fasta');

# Create database handler.
my $dbh = DBI->connect("DBI:SQLite:dbname=$dbf", "", "",
                       {PrintError => 0, RaiseError => 1});

# Prepare statements for inserting data, retrieving tissue IDs, and retrieving
# organism IDs.
my %ins;
$ins{g} = $dbh->prepare("INSERT INTO genes (g_name, organism, seq, tissue, " .
                        "exp_level, orf_start, orf_stop) VALUES (?, ?, ?, " .
                        "?, ?, ?, ?);");
$ins{o} = $dbh->prepare("INSERT INTO organisms (sci_name) VALUES (?);");
$ins{t} = $dbh->prepare("INSERT INTO tissues (t_name) VALUES (?);");
my %get;
$get{o} = $dbh->prepare("SELECT o_id FROM organisms WHERE (sci_name = ? OR " .
                        "comm_name = ?) LIMIT 1;");
$get{t} = $dbh->prepare("SELECT t_id FROM tissues WHERE (t_name = ?) LIMIT 1;");

# Loop through sequences, adding them and any necessary linked records (such as
# tissues or species) to the database.
for my $s (@seq) {
	# Get the appropriate organism ID.
	if ($s->{org}) {
		$get{o}->execute($s->{org}, $s->{org}) || die $get{o}->errstr();
		my $org = $get{o}->fetchrow_hashref("NAME_lc");
		
        # Add the organism if it doesn't already exist.  Assume its scientific
        # name was given.
        unless ($org->{o_id}) {
        	$ins{o}->execute($s->{org}) || die $ins{o}->errstr();
        	$get{o}->execute($s->{org}) || die $get{o}->errstr();
        	$org = $get{o}->fetchrow_hashref("NAME_lc");
        }
        
        $s->{org_id} = $org->{o_id};
	}
	
	# Get the appropriate tissue ID.
	if ($s->{tiss}) {
		$get{t}->execute($s->{tiss}) || die $get{t}->errstr();
		my $tiss = $get{t}->fetchrow_hashref("NAME_lc");
        
        # Add the tissue if it doesn't already exist.
        unless ($tiss->{t_id}) {
        	$ins{t}->execute($s->{tiss}) || die $ins{t}->errstr();
            $get{t}->execute($s->{tiss}) || die $get{t}->errstr();
        	$tiss = $get{t}->fetchrow_hashref("NAME_lc");
        }
        
        $s->{tiss_id} = $tiss->{t_id};
	}
	
	# Insert the gene record.
    $ins{g}->execute($s->{name}, $s->{org_id}, $s->{seq}, $s->{tiss_id},
                     $s->{expr}, $s->{start}, $s->{stop})
            || die "Unable to insert gene $s->{name}: " . $ins{g}->errstr();
}

for (keys %get) {
	$get{$_}->finish();
}

for (keys %ins) {
	$ins{$_}->finish();
}

$dbh->disconnect();