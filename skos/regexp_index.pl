# regexp_index.pl
# Mike Conway Oct 2010
# generates regular expression labels for skos

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
            $w =~ s/^.*?\[(.*?)\].*/$1/g;
            $w = trim($w);
            if ($w eq "") { next ;}
            print ("$concept HAS_REGEXP $w\n");
        }
        next;
    }
    #############################################
    foreach my $triple (@first_split) {
        my $w = $triple;
        $w =~ s/^.*?\[(.*?)\].*/$1/g;
        $w = trim($w);
         print ("$concept HAS_REGEXP $w\n");
    }

   
}


sub trim {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

