#!/usr/bin/perl

# Mike Conway, University of Pittsburgh, DBMI, May 2010

# matrix.pl
# generates a list of relations from an appropriately
# formatted Excel spreadsheet.

# Use:
#          perl matrix.pl > matrix.txt

# Note that it is important that the output file is named "matrix.txt"
# as the ILI population ontology script is expecting to see it.

# SVN Versioning Info:
# $Id$


use strict;

my $previous_subconcept;
my $line_number = 1;
while (<>) {
    if ($line_number == 1) {$line_number++; next;}
    my @fields = split(/\t/, $_);
    if ($line_number == 2) { $previous_subconcept = $fields[16]; $line_number++; next; }
    my $concept = $fields[15];
    my $subconcept = $fields[16];
    my $relation = $fields[17];
    
    if ($relation =~ /RelatedConcept/) {
        my $lc_subconcept = lcfirst($subconcept);
        my $lc_previous_subconcept = lcfirst($previous_subconcept);
	print "$lc_subconcept RELATED_TO $lc_previous_subconcept\n";
    }
    
    if ($relation =~ /Synonym/) {
        my $lc_subconcept = lcfirst($subconcept);
        my $lc_previous_subconcept = lcfirst($previous_subconcept);
	print "$lc_subconcept SYN $lc_previous_subconcept\n";
    }
	
    if ($relation =~ /ConceptName/) {
	$previous_subconcept = $subconcept;      
    }
    $line_number++;

}


