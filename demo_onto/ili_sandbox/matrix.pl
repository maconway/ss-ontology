use strict;

my $previous_subconcept;
my $line_number = 1;
while (<>) {
    if ($line_number == 1) {$line_number++; next;}
    my @fields = split(/\t/, $_);
    if ($line_number == 2) { $previous_subconcept = $fields[16]; $line_number++; next; }
    my $concept = $fields[15];
    my $subconcept = $fields[16];
    my $relation = $fields[17];
    
    if ($relation =~ /RelatedConcept/) {
        my $lc_subconcept = lcfirst($subconcept);
        my $lc_previous_subconcept = lcfirst($previous_subconcept);
	print "$lc_subconcept RELATED_TO $lc_previous_subconcept\n";
    }
    
    if ($relation =~ /Synonym/) {
        my $lc_subconcept = lcfirst($subconcept);
        my $lc_previous_subconcept = lcfirst($previous_subconcept);
        
	print "$lc_subconcept SYN $lc_previous_subconcept\n";
    }
	
    if ($relation =~ /ConceptName/) {
	$previous_subconcept = $subconcept;
        
    }
    $line_number++;

}


