
use RDF::Helper;



my $rdf = RDF::Helper->new();
$rdf->include_rdfxml(filename => "ili.owl");

while (<>) {
    if ($. == 1) {next}
    chomp;
    s/"//g;
    my @field = split(/\t/, $_);
    if ($. == 60) {last}

    
    my $subconcept = $field[16];  $subconcept = trim($subconcept);
    my $relation   = $field[17];  $relation = trim($relation);    
    my $umls       = $field[18];  $umls = trim($umls);
    my $diagnosis  = $field[19];  $diagnosis = trim($diagnosis);
    my $syndrome   = $field[20];  $syndrome = trim($syndrome);
    my $phys_find  = $field[21];  $syndrome = trim($phys_find);
    my $symptom    = $field[22];  $symptom = trim($symptom);
    my $sign       = $field[23];  $sign = trim($sign);

    if ($diagnosis == 1) {
        $rdf->assert_resource("http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept","http://www.w3.org/1999/02/22-rdf-syntax-ns#type","http://www.owl-ontologies.com/Ontology1274288723.owl#Disease");
    }
    
}




sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
