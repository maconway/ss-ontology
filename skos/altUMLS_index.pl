# altUMLS_index.pl
# Mike Conway Oct 2010
# Generates an index of altUMLs codes for SKOS

use strict;
use Spreadsheet::ParseExcel;
use Perl6::Slurp;

my $parser = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse("../spreadsheet/ESSO.xls");
my $worksheet = $workbook->worksheet("concept_data");
 

for (my $i = 1; $i < 280; $i++) {
    my $concept_cell = $worksheet->get_cell($i,16);
    my $concept = $concept_cell->unformatted();
    $concept = lcfirst($concept);

    my $keyword_cell = $worksheet->get_cell($i, 34);
    if (!(defined $keyword_cell)) {next;}
    my $keyword = $keyword_cell->unformatted();
    my $keyword = trim($keyword);
    
    my @first_split = split(/:::/, $keyword);
    my @words;

    #deals with vomiting special case
    ###########################################
    if ($concept eq "vomiting") {
        my $vom = slurp("vomit.txt");
        my @first_split = split(/:::/, $vom);
        foreach my $triple (@first_split) {
            my $w = $triple;
            $w =~ s/^.*?\[.*?\]\s*(\[.*?\]).*/$1/g;
            $w = trim($w);
            $w =~ s/(\[|\])//g;
            if ($w eq "") { next ;}
            print ("$concept HAS_ALT_UMLS $w\n");
        }
        next;
    }
    #############################################
    foreach my $triple (@first_split) {
        my $w = $triple;
       $w =~ s/^.*?\[.*?\]\s*(\[.*?\]).*/$1/g;
        $w = trim($w);
         $w =~ s/(\[|\])//g;
        print ("$concept HAS_ALT_UMLS $w\n");
    }

   
}


sub trim {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

