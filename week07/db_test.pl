#!/usr/bin/perl
use strict;
use warnings;

# Created on: Jul 17, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

use DBI;

my $dbf = "D:/wamp/www/q10_data.db";

my $dbh = DBI->connect("DBI:SQLite:dbname=$dbf", "", "",
                       {PrintError => 0, RaiseError => 1});

my $sql = "WITH T1 AS (SELECT genes.g_id, genes.g_name, organisms.sci_name, genes.tissue, genes.exp_level, genes.orf_start, genes.orf_stop, genes.seq FROM genes INNER JOIN organisms ON organisms.o_id = genes.organism ) SELECT T1.g_id AS id, T1.g_name AS gene, T1.sci_name AS org, tissues.t_name AS tiss, T1.exp_level AS expr, T1.orf_start AS orf_start, T1.orf_stop AS orf_stop, T1.seq AS seq FROM T1 INNER JOIN tissues ON tissues.t_id = T1.tissue WHERE (gene LIKE ?);";

my $get = $dbh->prepare($sql);

#$get->execute("gene REGEXP '.*RPE65.*'");
$get->execute('RPE65');

my $out = $get->fetchall_hashref('id');

my $org = $dbh->selectall_hashref("SELECT * FROM organisms", 'o_id');

my $tiss = $dbh->selectall_hashref("SELECT * FROM tissues", 't_id');

print "";