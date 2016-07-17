#!/usr/bin/perl
use strict;
use warnings;

# Created on: Jul 17, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

use CGI qw(:standard);
use CGI::Log;
use DBI;

my $dir = $0;

$dir =~ s{/[^/]*\.cgi}{};

chdir $dir;

my $dbf = './q10_data.db';

my $dbh = DBI->connect("DBI:SQLite:dbname=$dbf", "", "",
                       {PrintError => 0, RaiseError => 1}) ||
                       die "Unable to connect to $dbf: " . DBI->errstr();

# Prepare statement for retrieving data.
my $sql = "WITH T1 AS (\n" .
          "  SELECT genes.g_id,\n" .
          "    genes.g_name,\n" .
          "    organisms.sci_name,\n" .
          "    genes.tissue,\n" .
          "    genes.exp_level,\n" .
          "    genes.orf_start,\n" .
          "    genes.orf_stop,\n" .
          "    genes.seq\n" .
          "  FROM genes\n" .
          "    INNER JOIN\n" .
          "    organisms ON organisms.o_id = genes.organism\n" .
          ")\n" .
          "SELECT T1.g_id AS id,\n" .
          "  T1.g_name AS gene,\n" .
          "  T1.sci_name AS org,\n" .
          "  tissues.t_name AS tiss,\n" .
          "  T1.exp_level AS expr,\n" .
          "  T1.orf_start AS orf_start,\n" .
          "  T1.orf_stop AS orf_stop,\n" .
          "  T1.seq AS seq\n" .
          "FROM T1\n" .
          "  INNER JOIN\n" .
          "  tissues ON tissues.t_id = T1.tissue\n" .
          "WHERE (;";

my $title = 'Gene Database Search';
print header,
      start_html(-title => $title,
                 -style => {'src' => 'q10_style.css'}),
      h1($title);

# Hash of data used for the search.
my %data = (gene    => '',
            org     => '',
            tiss    => '',
            expr    => '');

# Handle processing of form if this was called as a form submission.
if (param('submit')) {
    my @sqlparams = (); # Array of parameters for the SQL query.
    
    # Get the data from the params and assign them to the conditions/etc.
    for (keys %data) {
    	$data{$_} = param($_);
    	# Add any non-blank conditions to the SQL query.
    	if ($data{$_}) {
    		$sql .= ($sql =~ m/[^\)]$/ ? " AND " : "") . "$_ LIKE ?";
    		push @sqlparams, $data{$_}
    	}
    }
    
    $sql .= ")";
    $sql =~ s/ WHERE \(\)$//;       # Remove "WHERE" statement if it's empty
    
    Log->debug($sql);
    
    my $get = $dbh->prepare($sql);
    
    # Make a SQL condition string out of the conditions hash and execute the
    # SQL query.
    $get->execute(@sqlparams);
    
    # Retrieve data values from SQL query.
    my $vals = $get->fetchall_hashref('id');
    
    print table({-border => 1, -cellpadding => 0},
                caption('Search Results'),
                Tr(
                   [
                    th(["Gene", "Organism", "Tissue", "Expression", "ORF",
                        "Sequence"]),
                    map {
                    	td([$$vals{$_}{gene},
                    	    $$vals{$_}{org},
                    	    $$vals{$_}{tiss},
                    	    $$vals{$_}{expr},
                    	    $$vals{$_}{orf_start} .
                    	        '-' . $$vals{$_}{orf_stop},
                    	    join("<br/>", split(/[ACGT]{60}\K/,
                    	                        $$vals{$_}{seq}))
                    	    ])
                    } keys(%$vals)
                    ]
                   ));
}

my $url = url();

print start_form(-method => 'POST', action => $url),
      p("(Blank entries will NOT be used for searching)"),
      table({-border => 0},
            caption('Search Criteria'),
            Tr(
            [
            td(["Gene Name:",           textfield(-name     => 'gene',
                                                  -value    => $data{gene},
                                                  -size     => 80)]),
            td(["Organism:",            textfield(-name     => 'org',
                                                  -value    => $data{org},
                                                  -size     => 80)]),
            td(["Tissue:",              textfield(-name     => 'tiss',
                                                  -value    => $data{tiss},
                                                  -size     => 80)]),
            td(["Expression Level:",    textfield(-name     => 'expr',
                                                  -value    => $data{expr},
                                                  -size     => 80)])
            ])),
      p(submit(-name => 'submit', -value => 'Search')),
      end_form(),
      end_html();