# concept_relation_index.pl
# Mike Conway Oct 2010
# generates "related" relations for skos vocab
    
use strict;
use Spreadsheet::ParseExcel;

my $parser = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse("../spreadsheet/ESSO.xls");
my $worksheet = $workbook->worksheet("concept_data");

my @relation_store;
my $previous_concept;
my $previous_subconcept;
my $row_number = 0;
while ($row_number< 280) {
    if ($row_number == 0) {$row_number++; next;}
    
    my $concept_cell = $worksheet->get_cell($row_number,15);
    my $concept = $concept_cell->unformatted();
    $concept = lcfirst($concept);

    my $subconcept_cell = $worksheet->get_cell($row_number,16);
    my $subconcept = $subconcept_cell->unformatted();

    my $relation_cell = $worksheet->get_cell($row_number, 17);
    my $relation = $relation_cell->unformatted();

    if ($relation =~ /RelatedConcept/) {
        my $lc_subconcept = lcfirst($subconcept);
        push(@relation_store, $lc_subconcept);
    }

    if ($relation =~ /Synonym/) {
        my $lc_subconcept = lcfirst($subconcept);
        push(@relation_store, $lc_subconcept);
    }

     if ($relation =~ /ConceptName/) {
        
        for(my $i = 0; $i < scalar(@relation_store);$i++) {
            
            for (my $j= $i + 1; $j < @relation_store; $j++) {
                print $relation_store[$i] . " RELATED_TO " . $relation_store[$j] . "\n";
            }
        }

        unless (scalar(@relation_store) == 1) {
            for(my $i = 0; $i < scalar(@relation_store); $i++) {
                print $previous_concept . " BROADER_THAN " . $relation_store[$i] . "\n";
            }
        }
        undef @relation_store;
        $previous_concept = $concept;
    }
    $row_number++;

}
    
    
