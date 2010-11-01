# concept_relation_index.pl
# Mike Conway Oct 2010
# generates "related" relations for skos vocab
    
use strict;
use Spreadsheet::ParseExcel;

my $parser = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse("../spreadsheet/ESSO.xls");
my $worksheet = $workbook->worksheet("concept_data");

my @relation_store;
my $previous_subconcept;
my $row_number = 0;
while ($row_number< 280) {
    if ($row_number == 0) {$row_number++; next;}
    
    my $concept_cell = $worksheet->get_cell($row_number,15);
    my $concept = $concept_cell->unformatted();

    my $subconcept_cell = $worksheet->get_cell($row_number,16);
    my $subconcept = $subconcept_cell->unformatted();

    my $relation_cell = $worksheet->get_cell($row_number, 17);
    my $relation = $relation_cell->unformatted();

    if ($relation =~ /RelatedConcept/) {
        my $lc_subconcept = lcfirst($subconcept);
        push(@relation_store, $lc_subconcept);
        my $lc_previous_subconcept = lcfirst($previous_subconcept);
        print "$lc_subconcept RELATED_TO $lc_previous_subconcept\n";
    }

    if ($relation =~ /Synonym/) {
        my $lc_subconcept = lcfirst($subconcept);
        push(@relation_store, $lc_subconcept);
        my $lc_previous_subconcept = lcfirst($previous_subconcept);
        print "$lc_subconcept RELATED_TO $lc_previous_subconcept\n";
    }

     if ($relation =~ /ConceptName/) {
        $previous_subconcept = $subconcept;
        for(my $i = 0; $i < scalar(@relation_store);$i++) {
            
            for (my $j= $i + 1; $j < @relation_store; $j++) {
                print $relation_store[$i] . " RELATED_TO " . $relation_store[$j] . "\n";
            }
        }
        undef @relation_store;
    }
    $row_number++;

}
    
    
