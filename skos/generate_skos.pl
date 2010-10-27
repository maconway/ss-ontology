# generate_skos.pl
# 25th October 2010
# Mike Conway

# SVN Keywords:
# $Id$


# Script generates SKOS from Excel spreadsheet


use strict;
use RDF::Helper;
use Perl6::Slurp;
use Spreadsheet::ParseExcel;
use diagnostics;
use warnings;

my @subconcepts;
my @definitions;

# Create RDF store
my $rdf = RDF::Helper->new();

# Open spreadsheet...
my $parser = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse("../spreadsheet/ESSO.xls");
my $conceptlist_worksheet = $workbook->worksheet("sub_concept_list");


#get list of and assert them as skos concepts
for (my $i = 1; $i < 280; $i++)  {
    my $cell = $conceptlist_worksheet->get_cell($i,0);
    my $value = $cell->unformatted();
    # generate concepts in RDF
    $rdf->assert_resource(
        "http://www.extended_sso.org/resource#$value",
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
        "http://www.w3.org/2004/02/skos/core#"
        );
    push(@subconcepts, $value);
}

#associate definitons with each concept


# Serialize...
$rdf->serialize( my $filename => 'out.xml', format => "rdfxml");

 
