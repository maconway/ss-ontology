# populate_ili.pl May 2010
# Mike Conway, DBMI Pittsburgh

# Perl script populates the ILI ontology
# SVN Version Info:
# $Id$

# The script uses relatively low level RDF to populate the "ili.owl"
# ontology. The script is used:

#    perl populate_ili.pl data.txt

# where data is a tab delimited file.  Note that the default input file is
# "ili.owl" (which contains the skeletal classes and relations) and the
# default output serialization is "out.owl"


#THINGS TO DO:
#    1.  Script would benefit from refactoring (May 2010)
        

use RDF::Helper;
use Perl6::Slurp;

my $rdf = RDF::Helper->new();    #main rdf object

#import rdf from ili.owl
$rdf->include_rdfxml( filename => "ili.owl" );

#main loop
my $cui_counter     = 1;
my $keyword_counter = 1;
my $regexp_counter  = 1;
while (<>) {
    chomp;

    #deals with excel text output double quote issue
    s/"//g;
    my @field = split( /\t/, $_ );
    if ( $field[14] ne "1" ) { next }

    my $subconcept = $field[16];
    $subconcept = trim($subconcept);
    my $relation = $field[17];
    $relation = trim($relation);
    my $umls = $field[18];
    $umls = trim($umls);
    my $diagnosis = $field[19];
    $diagnosis = trim($diagnosis);
    my $syndrome = $field[20];
    $syndrome = trim($syndrome);
    my $phys_find = $field[21];
    $syndrome = trim($phys_find);
    my $symptom = $field[22];
    $symptom = trim($symptom);
    my $sign = $field[23];
    $sign = trim($sign);
    my $triple_string = $field[34];
    $triple_string = trim($triple_string);

    #lowercase first letter of subconcept
    $subconcept = lcfirst($subconcept);

    # ADD DIAGNOSIS INSTANCES
    if ( ( $diagnosis == 1 ) || ( $syndrome == 1 ) ) {
        $rdf->assert_resource(
            "http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept",
            "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
            "http://www.owl-ontologies.com/Ontology1274288723.owl#Disease"
        );
    }

    # ADD SIGNS AND PHYSICAL FINDING INSTANCES
    if ( ( $sign == 1 ) || ( $physical_finding == 1 ) ) {
        $rdf->assert_resource(
            "http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept",
            "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
            "http://www.owl-ontologies.com/Ontology1274288723.owl#Finding"
        );
    }

    # ADD SYMPTOM INSTANCES
    if ( $symptom == 1 ) {
        $rdf->assert_resource(
            "http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept",
            "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
            "http://www.owl-ontologies.com/Ontology1274288723.owl#Symptom"
        );
    }

    # ADD LABEL TO CLINCAL CONCEPT INSTANCES
    my $label_subconcept = $subconcept;
    $label_subconcept =~ s/([A-Z])/ $1/g;
    $label_subconcept = lc($label_subconcept);
    $label_subconcept = trim($label_subconcept);
    my $label_literal = $rdf->new_literal( $label_subconcept, "en" );
    $rdf->assert_literal(
        "http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept",
        "http://www.owl-ontologies.com/Ontology1274288723.owl#label",
        $label_literal
    );

    # ADD UMLS Codes and Instances
    $cui_counter = formatt($cui_counter);
    $rdf->assert_resource(
"http://www.owl-ontologies.com/Ontology1274288723.owl#umls_$cui_counter",
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
        "http://www.owl-ontologies.com/Ontology1274288723.owl#UmlsLink"
    );
    $cui_counter++;

    $umls = trim($umls);

    my $cui;
    my $cui_text;
    if ( $umls =~ /^(.*?):(.*)/ ) {
        $cui      = $1;
        $cui_text = $2;
        $cui_text = lc($cui_text);
    }
    else {
        $cui = $umls;
    }

    my $umls_label_literal = $rdf->new_literal( $cui_text, "en" );
    $rdf->assert_literal(
"http://www.owl-ontologies.com/Ontology1274288723.owl#umls_$cui_counter",
        "http://www.owl-ontologies.com/Ontology1274288723.owl#hasCodeString",
        $umls_label_literal
    );

    my $umls_cui_literal = $rdf->new_literal( $cui, "en" );
    $rdf->assert_literal(
"http://www.owl-ontologies.com/Ontology1274288723.owl#umls_$cui_counter",
        "http://www.owl-ontologies.com/Ontology1274288723.owl#code",
        $umls_cui_literal
    );

    #links CUI with Clinical Concept instance
    $rdf->assert_resource(
"http://www.owl-ontologies.com/Ontology1274288723.owl#umls_$cui_counter",
"http://www.owl-ontologies.com/Ontology1274288723.owl#isLinkAssociatedWithClinicalConcept",
        "http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept"
    );

    # links Clinical Concept instance with CUI
    $rdf->assert_resource(
        "http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept",
        "http://www.owl-ontologies.com/Ontology1274288723.owl#hasLink",
        "http://www.owl-ontologies.com/Ontology1274288723.owl#umls_$cui_counter"
    );

    # POPULATE REGULAREXPRESSIONS
    my @square_brackets = $triple_string =~ /\[.*?]/g;
    my @regexps;
    foreach $item (@square_brackets) {
        if ( $item =~ /\\/ ) {
            push( @regexps, $item );
        }
    }

    # extract keywords if triple string
    # note that entries from the consensus SSO ontology use
    # the "keyword [regexp] [cui]" format, wheras those
    # added by JD just list keywords (comma sep). So we
    # need to do extra work here identifying which is which.
    my @keywords;
    if ( $triple_string =~ /\[/ ) {
        my @sts = split( /:::/, $triple_string );
        foreach my $string (@sts) {
            if ( $string =~ /^(.*?)\s\[.*?\]\s*\[.*?\]/g ) {
                my $key = $1;
                $key = trim($key);
                push( @keywords, $key );
            }    #endif
        }    #endforeach
    }
    else {    # then in those separated by commas
        my @sts = split( /,/, $triple_string );
        foreach my $string (@sts) {
            my $key = $string;
            $key = trim($key);
            push( @keywords, $key );
        }
    }

    foreach my $regexp (@regexps) {
        $regexp =~ s/\[//g;
        $regexp =~ s/\]//g;    #removes enclosing square brackets
        $regexp_counter = formatt($regexp_counter);
        $rdf->assert_resource(
"http://www.owl-ontologies.com/Ontology1274288723.owl#enRegularExpression_$regexp_counter",
            "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
"http://www.owl-ontologies.com/Ontology1274288723.owl#EnglishRegularExpression"
        );

        my $regexp_label = $rdf->new_literal( $regexp, "en" );
        $rdf->assert_literal(
"http://www.owl-ontologies.com/Ontology1274288723.owl#enRegularExpression_$regexp_counter",
"http://www.owl-ontologies.com/Ontology1274288723.owl#hasRegularExpressionString",
            $regexp_label
        );

        #links regular expression to clinical concept
        $rdf->assert_resource(
"http://www.owl-ontologies.com/Ontology1274288723.owl#enRegularExpression_$regexp_counter",
"http://www.owl-ontologies.com/Ontology1274288723.owl#isRegularExpressionAssociatedWithConcept",
            "http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept"
        );

        #links clinical concept to regular expression
        $rdf->assert_resource(
            "http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept",
"http://www.owl-ontologies.com/Ontology1274288723.owl#hasRegularExpression",
"http://www.owl-ontologies.com/Ontology1274288723.owl#enRegularExpression_$regexp_counter"
        );
        $regexp_counter++;
    }    #end regexp  foreach loop

    foreach my $keyword (@keywords) {
        $keyword_counter = formatt($keyword_counter);
        $rdf->assert_resource(
"http://www.owl-ontologies.com/Ontology1274288723.owl#enKeyword_$keyword_counter",
            "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
"http://www.owl-ontologies.com/Ontology1274288723.owl#EnglishKeyword"
        );
        my $keyword_label = $rdf->new_literal( $keyword, "en" );
        $rdf->assert_literal(
"http://www.owl-ontologies.com/Ontology1274288723.owl#enKeyword_$keyword_counter",
"http://www.owl-ontologies.com/Ontology1274288723.owl#hasKeywordString",
            $keyword_label
        );

        #links keyword to clincal concept
        $rdf->assert_resource(
"http://www.owl-ontologies.com/Ontology1274288723.owl#enKeyword_$keyword_counter",
"http://www.owl-ontologies.com/Ontology1274288723.owl#isKeywordAssociatedWithConcept",
            "http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept"
        );

        #links clinical concept to keyword
        $rdf->assert_resource(
            "http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept",
            "http://www.owl-ontologies.com/Ontology1274288723.owl#hasKeyword",
"http://www.owl-ontologies.com/Ontology1274288723.owl#enKeyword_$keyword_counter"
        );

        $keyword_counter++;
    }    #end keywords foreach loop

    populate_hasAssociatedSyndrome($subconcept);    #also handles inverse
    populate_hasStatus($subconcept);                # defaults to "accepted"

    #Deal with RelatedConcept and Synonym using file "matrix.txt"
    #using the "related_to" subroutine.
    related_to();

}    #end main while loop

# Serialize...
$rdf->serialize( filename => 'out.owl', format => 'rdfxml' );

########################################
# SUBROUTINES
########################################

sub trim() {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

sub formatt() {
    my $string = shift;
    chomp $string;
    $string = sprintf( "%06d", $string );
    return $string;
}

sub populate_hasAssociatedSyndrome() {
    my $subconcept = shift;

    #All clinical concepts have ILI as their
    #associated syndrome as this is the ILI Biosurveillance
    #ontology.  Also handles inverse relationship.
    $rdf->assert_resource(
        "http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept",
"http://www.owl-ontologies.com/Ontology1274288723.owl#hasAssociatedSyndrome",
        "http://www.owl-ontologies.com/Ontology1274288723.owl#syndrome_1"
    );

    # Inverse...
    $rdf->assert_resource(
        "http://www.owl-ontologies.com/Ontology1274288723.owl#syndrome_1",
"http://www.owl-ontologies.com/Ontology1274288723.owl#isSyndromeAssociatedWithClinicalConcept",
        "http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept"
    );

}

sub populate_hasStatus() {
    my $subconcept = shift;

    #All clinical concepts have a status (eg. "accepted", "candidate")
    #Initially, they have all been assumed to have been accepted.
    $rdf->assert_resource(
        "http://www.owl-ontologies.com/Ontology1274288723.owl#$subconcept",
        "http://www.owl-ontologies.com/Ontology1274288723.owl#hasStatus",
        "http://www.owl-ontologies.com/Ontology1274288723.owl#accepted"
    );
}

sub related_to() {

    #uses external file "matrix.txt" which contains all the related_to and synonym
    #relations from the spreadsheet, generated by script matrix.pl
    my @lines = slurp("matrix.txt");
    foreach my $line (@lines) {
        chomp $line;
        if ( $line =~ /RELATED_TO/ ) {
            my ( $first, $second, $third ) = split( /\s+/, $line );
            $rdf->assert_resource(
                "http://www.owl-ontologies.com/Ontology1274288723.owl#$first",
"http://www.owl-ontologies.com/Ontology1274288723.owl#isRelatedTo",
                "http://www.owl-ontologies.com/Ontology1274288723.owl#$third"
            );

            #inverse
            $rdf->assert_resource(
                "http://www.owl-ontologies.com/Ontology1274288723.owl#$third",
"http://www.owl-ontologies.com/Ontology1274288723.owl#isRelatedTo",
                "http://www.owl-ontologies.com/Ontology1274288723.owl#$first"
            );

        }
        if ( $line =~ /SYN/ ) {
            my ( $first, $second, $third ) = split( /\s+/, $line );
            $rdf->assert_resource(
                "http://www.owl-ontologies.com/Ontology1274288723.owl#$first",
"http://www.owl-ontologies.com/Ontology1274288723.owl#isSynonymousWith",
                "http://www.owl-ontologies.com/Ontology1274288723.owl#$third"
            );

            #inverse
            $rdf->assert_resource(
                "http://www.owl-ontologies.com/Ontology1274288723.owl#$third",
"http://www.owl-ontologies.com/Ontology1274288723.owl#isSynonymousWith",
                "http://www.owl-ontologies.com/Ontology1274288723.owl#$first"
            );
        }
    }
}

