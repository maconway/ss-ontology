# indicates_index.pl
# Mike Conway Oct 2010
# Generates symptoms index for SKOS vocabulary

use strict;
use Spreadsheet::ParseExcel;
use Perl6::Slurp;

my $parser =              Spreadsheet::ParseExcel->new();
my $workbook =            $parser->parse("../spreadsheet/ESSO.xls");
my $worksheet_signs =     $workbook->worksheet("signs");
my $worksheet_symptoms =  $workbook->worksheet("symptoms");


for (my $i = 1; $i < 84; $i++) {
    my $concept_cell = $worksheet_symptoms->get_cell($i,0);
    my $concept = $concept_cell->unformatted();
    $concept = lcfirst($concept);
    my ($col_min, $col_max) = $worksheet_symptoms->col_range();
    my @hold;
    for (my $j = $col_min; $j < $col_max; $j++) {
        my $indicates_cell = $worksheet_symptoms->get_cell($i,$j+1);
        if (!(defined $indicates_cell)) {next;}
        my $indicates = $indicates_cell->unformatted();
        $indicates = lcfirst($indicates);
        push(@hold, $indicates)
    }

    foreach my $item (@hold) {
        print $concept . " HAS_INDICATOR " . "$item\n";
    }
    
}

for (my $i = 1; $i < 84; $i++) {
    my $concept_cell = $worksheet_signs->get_cell($i,0);
    my $concept = $concept_cell->unformatted();
    $concept = lcfirst($concept);
    my ($col_min, $col_max) = $worksheet_signs->col_range();
    my @hold;
    for (my $j = $col_min; $j < $col_max; $j++) {
        my $indicates_cell = $worksheet_signs->get_cell($i,$j+1);
        if (!(defined $indicates_cell)) {next;}
        my $indicates = $indicates_cell->unformatted();
        $indicates = lcfirst($indicates);
        push(@hold, $indicates)
    }

    foreach my $item (@hold) {
        print $concept . " HAS_INDICATOR " . "$item\n";
    }
    
}
