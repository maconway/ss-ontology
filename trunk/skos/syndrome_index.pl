# syndrome_index.pl
# Mike Conway Oct 2010
# generates syndrome index for SKOS vocab

use strict;
use Spreadsheet::ParseExcel;

my $parser = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse("../spreadsheet/ESSO.xls");
my $worksheet = $workbook->worksheet("concept_data");



for(my $i = 1; $i < 280; $i++) {
    
    my @syndromes;
    my $concept_cell = $worksheet->get_cell($i,16);
    my $concept = $concept_cell->unformatted();
    $concept = lcfirst($concept);

    my $rash        = get_syndrome($i,3);
    if ($rash == 1) {push(@syndromes, "rashSyndrome")};
                       
    my $hem         = get_syndrome($i,4);
    if ($hem == 1) {push(@syndromes, "hemorrhagicSyndrome")};                   
    
    my $botulism    = get_syndrome($i,5);
    if ($botulism == 1) {push(@syndromes, "botulismSyndrome")};
                      
    my $neuro       = get_syndrome($i,6);
    if ($neuro == 1) {push(@syndromes, "neurologicalSyndrome")};                       
                           
    my $const       = get_syndrome($i,7);
    if ($const == 1) {push(@syndromes, "constitutionalSyndrome")};
     
    my $sens_resp   = get_syndrome($i,8);
    if ($sens_resp == 1) {push(@syndromes, "sensitiveRespiratorySyndrome")};
                        
    my $spec_resp   = get_syndrome($i,9);
    if ($spec_resp == 1) {push(@syndromes, "specificRespiratorySyndrome")};
                            
    my $resp        = get_syndrome($i,10); # not neccesary
                            
    my $sens_gi     = get_syndrome($i, 11);
    if ($sens_gi == 1) {push(@syndromes, "sensitiveGastrointestinalSyndrome")};
                          
    my $spec_gi     = get_syndrome($i, 12);
    if ($spec_gi == 1) {push(@syndromes, "specificGastrointestinalSyndrome")};
    my $gi          = get_syndrome($i, 13); # not necessary
                          
    my $ili         = get_syndrome($i, 14);
    if ($ili == 1) {push(@syndromes, "influenzaLikeIllnessSyndrome")};


    foreach my $syndrome (@syndromes) {
      
            print $concept . " HAS_SYNDROME " . $syndrome . "\n";
        
    }
    #print "$concept LINE $i\n"; debug
}



sub get_syndrome{
    my ($row, $col) = @_;
    my $cell = $worksheet->get_cell($row,$col);
    my $value = $cell->unformatted();
   # print $value . "\n"; debug
    return $value;
}
