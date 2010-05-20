# populate_ili.pl May 2010
# Mike Conway, DBMI Pittsburgh

# Perl script populates the ILI ontology
# SVN Version Info:
# $Id$

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

    #lowercase first letter of subconcept
    $subconcept = lcfirst($subconcept);

    # ADD DIAGNOSIS INSTANCES
    if (($diagnosis == 1) || ($syndrome == 1)) {
        $rdf->assert_resource("http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept","http://www.w3.org/1999/02/22-rdf-syntax-ns#type","http://www.owl-ontologies.com/Ontology1274288723.owl#Disease");
    }

    # ADD SIGNS AND PHYSICAL FINDING INSTANCES
    if (($sign == 1) || ($physical_finding == 1)) {
       $rdf->assert_resource("http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept","http://www.w3.org/1999/02/22-rdf-syntax-ns#type","http://www.owl-ontologies.com/Ontology1274288723.owl#Finding");
   }

    # ADD SYMPTOM INSTANCES
    if ($symptom == 1) {
        $rdf->assert_resource("http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept","http://www.w3.org/1999/02/22-rdf-syntax-ns#type","http://www.owl-ontologies.com/Ontology1274288723.owl#Symptom");
    }

    # ADD LABEL
    my $label_subconcept = $subconcept;
    $label_subconcept =~ s/([A-Z])/ $1/g;
    $label_subconcept = lc($label_subconcept);
    $label_subconcept = trim($label_subconcept);
    my $label_literal = $rdf->new_literal($label_subconcept, "en");
    $rdf->assert_literal("http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept","http://www.owl-ontologies.com/Ontology1274288723.owl#label", $label_literal);
    print "$label_subconcept" . "\n";
    
}



$rdf->serialize(filename => 'out.owl', format => 'rdfxml');


sub trim() {
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}
