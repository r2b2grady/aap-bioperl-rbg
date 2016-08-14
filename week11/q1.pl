#!usr/bin/perl
use strict;
use warnings;

# Created on: Aug 14, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

use LWP::Simple;
use CGI qw(:standard);
use CGI::Log;

# Declare & prototype functions.
sub get_cells(%);
sub result_hash($);

# List of DB categories.
my @categories = qw(Literature Health Genomes Genes Proteins Chemicals Other);

# Hash of DB categories. Each key corresponds to a DB name and each value
# contains the category name.
my %db_cats = ('pubmed'             => 'Literature',
               'pmc'                => 'Literature',
               'mesh'               => 'Literature',
               'books'              => 'Literature',
               'pubmedhealth'       => 'Health',
               'omim'               => 'Health',
               'ncbisearch'         => 'Other',
               'nuccore'            => 'Genomes',
               'nucgss'             => 'Genomes',
               'nucest'             => 'Genes',
               'protein'            => 'Proteins',
               'genome'             => 'Genomes',
               'structure'          => 'Proteins',
               'taxonomy'           => 'Genomes',
               'snp'                => 'Genomes',
               'dbvar'              => 'Genomes',
               'gene'               => 'Genes',
               'sra'                => 'Genomes',
               'biosystems'         => 'Chemicals',
               'unigene'            => 'Genes',
               'cdd'                => 'Proteins',
               'clone'              => 'Genomes',
               'popset'             => 'Genes',
               'geoprofiles'        => 'Genes',
               'gds'                => 'Genes',
               'homologene'         => 'Genes',
               'pccompound'         => 'Chemicals',
               'pcsubstance'        => 'Chemicals',
               'pcassay'            => 'Chemicals',
               'nlmcatalog'         => 'Literature',
               'probe'              => 'Genomes',
               'gap'                => 'Health',
               'proteinclusters'    => 'Proteins',
               'bioproject'         => 'Genomes',
               'biosample'          => 'Genomes');

my $title = 'Custom Entrez GQuery';

my $url = url();
my $eurl = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/egquery.fcgi";
my $db_url = "http://www.ncbi.nlm.nih.gov";

my %data = (term => '');

# Load data if this was called as a form submission.
if (param('submit')) {
	$data{term} = param('term');
}

print header,
      start_html(-title => $title,
                 -style => {'src' => 'q1_style.css'}),
      h1($title);

# Put the query line at the top of the form.
print start_form(-method => 'POST', -action => $url),
      p("Entrez Global Query:"),
      textfield(-name   => 'term',
                -value => $data{term}),
      p(submit(-name => 'submit', -value => 'Search')),
      end_form();

# Handle processing of form if this was called as a form submission.
if (param('submit')) {
	my %results = result_hash(get("$eurl?term=$data{term}"));
	
	# Print results table.
	print table({-border => 0}, get_cells(%results))
}

print end_html();


# Parses the given result hash and generates a string for output for use in the
# CGI::Tr() function.
sub get_cells(%) {
    my (%res) = @_;
    
    my @cells = ('', '');
    
    # Loop through categories for the first column of the meta-table.
    for (qw(Literature Health Genomes)) {
    	my @results = sort { $a->{disp} cmp $b->{disp} } @{$res{$_}};
    	
    	# Add a table with a row for each database in the current category. 
    	$cells[0] .= table({-cellpadding => 0},
                           th({-colspan => 2}, [$_]),
    	                   Tr([map {td([a( {-href     => "$db_url/$_->{db}/" .
                                                         "?term=$data{term}",
                                            -target   => "_blank"},
                                          $_->{disp}),
                                        $_->{count} . " hits"])} @results]));
    }
    
    # Loop through categories for the second column of the meta-table.
    for (qw(Genes Proteins Chemicals Other)) {
    	my @results = sort { $a->{disp} cmp $b->{disp} } @{$res{$_}};
    	
    	# Add a table with a row for each database in the current category.
    	$cells[1] .= table({-cellpadding => 0},
                           th({-colspan => 2}, [$_]),
                           Tr([map {td([a( {-href     => "$db_url/$_->{db}/" .
                                                         "?term=$data{term}",
                                            -target   => "_blank"},
                                          $_->{disp}),
                                        sprintf($_->{count}) . " hits"])} @results]));
    }
    
    return td(\@cells);
}

# Parses the given XML input string and returns a hash of hashes representing
# the results. The first level of hashes represents a category of databases,
# while the second level represents the individual databases from within the
# corresponding category.
sub result_hash($) {
    my ($xml) = @_;
    
    my @r_items = ($xml =~ m{<ResultItem>([\s\S]*?)</ResultItem>}g);
    
    my %out;
    
    for (@categories) {
    	$out{$_} = [];
    }
    
    for (@r_items) {
    	m|<DbName>(.*)</DbName>\s*?<MenuName>(.*)</MenuName>\s*<Count>(\d+)</Count>\s*<Status>(.*)</Status>|;
    	my %h = (db        => $1,
    	         disp      => $2,
    	         count     => $3,
    	         status    => $4);
        push @{$out{$db_cats{$h{db}}}}, {%h};
    }
    
    return %out;
}
