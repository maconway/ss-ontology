use strict;
use Spreadsheet::ParseExcel;

my $parser = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse("../spreadsheet/ESSO.xls");
my $worksheet = $workbook->worksheet("concept_data");



for(my $i = 1; $i < 280; $i++) {   
    my @cats;
    my $concept_cell = $worksheet->get_cell($i,16);
    my $concept = $concept_cell->unformatted();
    $concept = lcfirst($concept);

    my $diagnosis         = get_value($i, 19);
    if ($diagnosis == 1) {push(@cats, "diagnosis")};

    my $syndrome          = get_value($i, 20);
    if ($syndrome == 1)   {push(@cats, "syndrome")};

    my $sign              = get_value($i, 24);
    if ($sign == 1)       {push(@cats, "sign")};

    my $bioterrorism      = get_value($i, 27);
    if ($bioterrorism == 1) {push(@cats, "bioterrorism")};

    my $chest_radiography = get_value($i, 28);
    if ($chest_radiography == 1) {push(@cats, "chest_radiography")};

    foreach my $item (@cats) {
        print $concept .  " HAS_NOTE " . "$item" . "\n";
    }
}

sub get_value{
    my ($row, $col) = @_;
    my $cell = $worksheet->get_cell($row,$col);
    my $value = $cell->unformatted();
   # print $value . "\n"; debug
    return $value;
}

