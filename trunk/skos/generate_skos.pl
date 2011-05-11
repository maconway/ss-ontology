# generate_skos.pl
# 25th October 2010
# Mike Conway

# SVN Keywords:
# $Id$

# Script generates SKOS from Excel spreadsheet.  Uses a series of indices as
# a basis

use strict;
use RDF::Helper;
use Perl6::Slurp;
use Spreadsheet::ParseExcel;

my @subconcepts;
my @definitions;

# Create RDF store
my $rdf = RDF::Helper->new();#BaseURI => "http://www.extended_sso.org");

# Open spreadsheet...
my $parser = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse("../spreadsheet/ESSO.xls");
my $conceptlist_worksheet = $workbook->worksheet("sub_concept_list");

setup_ontology_names();
setup_syndromeSkos();


#get list of and assert them as skos concepts
for (my $i = 1; $i < 280; $i++)  {
    my $cell = $conceptlist_worksheet->get_cell($i,0);
    my $value = $cell->unformatted();
    $value = lcfirst($value);
    # generate concepts in RDF
    $rdf->assert_resource(
        "http://www.extended_sso.org/resource#$value",
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
        "http://www.w3.org/2004/02/skos/core#Concept"
        );
    push(@subconcepts, $value);
}

#associate definitons with each concept
my $definitions_worksheet = $workbook->worksheet("definitions");
for (my $i = 1; $i < 280; $i++) {
    my $cell = $definitions_worksheet->get_cell($i,1);
    my $definition = $cell->unformatted();
    my $definition = trim($definition);
    $rdf->assert_literal(
       "http://www.extended_sso.org/resource#$subconcepts[$i-1]",
       "http://www.w3.org/2004/02/skos/core#definition",
       "$definition"
       );
    push(@definitions, $definition);
}

# Related to... Use this to relate subconcepts to concepts
# Need to open index file: related_index.txt
my @relations_index_lines = slurp("related_index.txt");
foreach my $relation (@relations_index_lines) {
    chomp($relation);
    my @parsed = split(/\s+/,$relation);
    my $field1 = $parsed[0]; print $field1;
    my $field2 = $parsed[2]; print $field2 . "\n";
    my $relation_field = $parsed[1];

    if ($relation_field eq "RELATED_TO") {
        $rdf->assert_resource(
            "http://www.extended_sso.org/resource#$field1",
            "http://www.w3.org/2004/02/skos/core#related",
            "http://www.extended_sso.org/resource#$field2"
        );
        #Although the related skos relation is symmetrical, we will
        #assert it anyway
        $rdf->assert_resource(
            "http://www.extended_sso.org/resource#$field2",
            "http://www.w3.org/2004/02/skos/core#related",
            "http://www.extended_sso.org/resource#$field1"
        );
    }

    if ($relation_field eq "BROADER_THAN") {
        $rdf->assert_resource(
            "http://www.extended_sso.org/resource#$field1",
            "http://www.w3.org/2004/02/skos/core#related",
            "http://www.extended_sso.org/resource#$field2"
         );
          $rdf->assert_resource(
             "http://www.extended_sso.org/resource#$field2",
             "http://www.w3.org/2004/02/skos/core#related",
             "http://www.extended_sso.org/resource#$field1"
          );        
    }

    # This is an owl relation that will add extra hierarchy not covered
    # by the skos vocabulary
        if ($relation_field eq "BROADER_THAN") {
        $rdf->assert_resource(
            "http://www.extended_sso.org/resource#$field1",
            "#isSuperordinateConceptOf",
            "http://www.extended_sso.org/resource#$field2"
         );
          $rdf->assert_resource(
             "http://www.extended_sso.org/resource#$field2",
             "#hasSuperordinateConcept",
             "http://www.extended_sso.org/resource#$field1"
          );        
    }
}

populate_syndromes();
link_to_conceptscheme();
add_notes();
populate_prefLabels();
populate_altLabels();
generate_notes();
generate_umls_prefLabel();

generate_regexp();
generate_altUMLS();
generate_icd_prefLabel();
generate_mesh_prefLabel();
generate_indicators();
generate_diagnosis();
generate_biocaster_label();
generate_dc_source();
generate_sso();

# Serialize...
$rdf->serialize( filename => 'esso.xml', format => "rdfxml");



############################################################
# SUBROUTINES
############################################################
#Set up ontology name and top concepts
sub setup_ontology_names {
    #Name concept scheme
    $rdf->assert_resource(
         "http://www.extended_sso.org/#extended_sso",
         "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
         "http://www.w3.org/2004/02/skos/core#ConceptScheme"         
        );

    #DUBLIN CORE DOCUMENT LEVEL
    #title
     $rdf->assert_literal(
         "http://www.extended_sso.org/#extended_sso",
         "http://purl.org/dc/terms/title",
         "Extended syndromic surveillance ontology"
         );
    #audience
    $rdf->assert_literal(
      "http://www.extended_sso.org/#extended_sso",
     "http://purl.org/dc/terms/audience",
      "We aim to appeal to two groups of users.  First, those seeking a reference for standard syndrome definitions.  Second, those seeking to automate syndromic surveillance");

    #alternative
     $rdf->assert_literal(
      "http://www.extended_sso.org/#extended_sso",
     "http://purl.org/dc/terms/alternative",
      "Extended SSO"
     );
        #alternative
     $rdf->assert_literal(
      "http://www.extended_sso.org/#extended_sso",
     "http://purl.org/dc/terms/alternative",
      "ESSO"
     );
    
    #created
    $rdf->assert_literal(
        "http://www.extended_sso.org/#extended_sso",
     "http://purl.org/dc/terms/created",
      "2011-03-31"
    );

   #creator
   $rdf->assert_literal(
       "http://www.extended_sso.org/#extended_sso",
     "http://purl.org/dc/terms/creator",
      "M.Conway"
  );
     $rdf->assert_literal(
       "http://www.extended_sso.org/#extended_sso",
     "http://purl.org/dc/terms/creator",
      "J.Dowling"
       );
     $rdf->assert_literal(
       "http://www.extended_sso.org/#extended_sso",
     "http://purl.org/dc/terms/creator",
      "W.Chapman"
       );

    #format
    $rdf->assert_literal(
        "http://www.extended_sso.org/#extended_sso",
     "http://purl.org/dc/terms/format",
      "SKOS"
       );
        

    #description
      $rdf->assert_literal(
       "http://www.extended_sso.org/#extended_sso",
     "http://purl.org/dc/terms/description",
     "The Extended Syndromic Surveillance Ontology is a terminological ontology/application ontology designed to facilitate NLP for syndromic surveillance.  The ontology uses data from the Syndromic Surveillance Ontology"
       );

      #hasVersion
   $rdf->assert_literal(
       "http://www.extended_sso.org/#extended_sso",
     "http://purl.org/dc/terms/hasVersion",
      "SVN:  \$Revision\$"
       );

    #language
    $rdf->assert_literal(
         "http://www.extended_sso.org/#extended_sso",
     "http://purl.org/dc/terms/language",
      "English"
       );

       #modified
   $rdf->assert_literal(
       "http://www.extended_sso.org/#extended_sso",
     "http://purl.org/dc/terms/modfied",
      "SVN:  \$Date\$"
       );

       #subject
    $rdf->assert_literal(
         "http://www.extended_sso.org/#extended_sso",
     "http://purl.org/dc/terms/subject",
      "Syndromic surveillance"
       );
        
        
    
    #Assert top concepts
    my @syndromes = qw(rashSyndrome
                       hemorrhagicSyndrome
                       botulismSyndrome
                       neurologicalSyndrome
                       constitutionalSyndrome
                       respiratorySyndrome
                       gastrointestinalSyndrome
                       influenzaLikeIllnessSyndrome);
    foreach my $syndrome (@syndromes) {
        $rdf->assert_resource(
             "http://www.extended_sso.org/#extended_sso",
             "http://www.w3.org/2004/02/skos/core#hasTopConcept",
              "http://www.extended_sso.org/resource#$syndrome"     
             );
        $rdf->assert_resource(
             "http://www.extended_sso.org/resource#$syndrome",
             "http://www.w3.org/2004/02/skos/core#topConceptOf",
              "http://www.extended_sso.org/#extended_sso"
             );
    
   }         
   
}

# Set up Syndrome classes forSyndromic relations
sub setup_syndromeSkos {
    my @syndromes = qw(rashSyndrome
                       hemorrhagicSyndrome
                       botulismSyndrome
                       neurologicalSyndrome
                       constitutionalSyndrome
                       respiratorySyndrome
                       gastrointestinalSyndrome
                       influenzaLikeIllnessSyndrome
                       sensitiveGastrointestinalSyndrome
                       specificGastrointestinalSyndrome
                       sensitiveRespiratorySyndrome
                       specificRespiratorySyndrome);

    foreach my $syndrome (@syndromes) {
        $rdf->assert_resource(
            "http://www.extended_sso.org/resource#$syndrome",
            "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
            "http://www.w3.org/2004/02/skos/core#Concept"     
             );
    }

    #create taxonmic relations for specific and sensitive syndromes
    $rdf->assert_resource(
        "http://www.extended_sso.org/resource#sensitiveGastrointestinalSyndrome",
        "http://www.w3.org/2004/02/skos/core#broader",
        "http://www.extended_sso.org/resource#gastrointestinalSyndrome",
        );
    $rdf->assert_resource(
        "http://www.extended_sso.org/resource#gastrointestinalSyndrome",
        "http://www.w3.org/2004/02/skos/core#narrower",
        "http://www.extended_sso.org/resource#sensitiveGastrointestinalSyndrome",
        );
        $rdf->assert_resource(
        "http://www.extended_sso.org/resource#specificGastrointestinalSyndrome",
        "http://www.w3.org/2004/02/skos/core#broader",
        "http://www.extended_sso.org/resource#gastrointestinalSyndrome",
        );
    $rdf->assert_resource(
        "http://www.extended_sso.org/resource#gastrointestinalSyndrome",
        "http://www.w3.org/2004/02/skos/core#narrower",
        "http://www.extended_sso.org/resource#specificGastrointestinalSyndrome",
        );
     $rdf->assert_resource(
        "http://www.extended_sso.org/resource#sensitiveRespiratorySyndrome",
        "http://www.w3.org/2004/02/skos/core#broader",
        "http://www.extended_sso.org/resource#respiratorySyndrome",
        );
    $rdf->assert_resource(
        "http://www.extended_sso.org/resource#respiratorySyndrome",
        "http://www.w3.org/2004/02/skos/core#narrower",
        "http://www.extended_sso.org/resource#sensitiveRespiratorySyndrome",
        );
     $rdf->assert_resource(
        "http://www.extended_sso.org/resource#specificRespiratorySyndrome",
        "http://www.w3.org/2004/02/skos/core#broader",
        "http://www.extended_sso.org/resource#respiratorySyndrome",
        );
    $rdf->assert_resource(
        "http://www.extended_sso.org/resource#respiratorySyndrome",
        "http://www.w3.org/2004/02/skos/core#narrower",
        "http://www.extended_sso.org/resource#specificRespiratorySyndrome",
        );
}

sub populate_syndromes {
    my @syndrome_lines = slurp("syndrome_index.txt");
    foreach my $syndrome_line (@syndrome_lines) {
        chomp($syndrome_line);
        my ($concept, $ignore, $syndrome) = split(/\s+/, $syndrome_line);
        $rdf->assert_resource(
        "http://www.extended_sso.org/resource#$concept",
        "http://www.w3.org/2004/02/skos/core#broader",
        "http://www.extended_sso.org/resource#$syndrome"
     );
         $rdf->assert_resource(
        "http://www.extended_sso.org/resource#$syndrome",
        "http://www.w3.org/2004/02/skos/core#narrower",
        "http://www.extended_sso.org/resource#$concept"
     );
        
    }
}


sub link_to_conceptscheme {
    foreach my $concept (@subconcepts) {
        $rdf->assert_resource(
            "http://www.extended_sso.org/resource#$concept",
            "http://www.w3.org/2004/02/skos/core#inScheme",
            "http://www.extended_sso.org/#extended_sso"
            );
    }
}

sub add_notes {
    foreach my $concept (@subconcepts) {
        # DC:CREATED
        $rdf->assert_literal(
             "http://www.extended_sso.org/resource#$concept",
             "http://purl.org/dc/terms/created",
             "2011-03-31"
            );
        # DC:MODIFIED
             $rdf->assert_literal(
             "http://www.extended_sso.org/resource#$concept",
             "http://purl.org/dc/terms/modified",
             "2011-03-31"
            );
         
        # DC:CREATOR
           $rdf->assert_literal(
             "http://www.extended_sso.org/resource#$concept",
             "http://purl.org/dc/terms/creator",
             "MC"
            );
        # SKOS:ChangeNote
          $rdf->assert_literal(
              "http://www.extended_sso.org/resource#$concept",
              "http://www.w3.org/2004/02/skos/core#changeNote",
              ""
              );
        # SKOS: editorialNote
        $rdf->assert_literal(
              "http://www.extended_sso.org/resource#$concept",
              "http://www.w3.org/2004/02/skos/core#editorialNote",
              ""
              );
    }
}

sub populate_prefLabels {
    foreach my $concept (@subconcepts) {
        
        my $preflabel = $concept;
        $preflabel =~ s/([A-Z])/ $1/g;
        $preflabel = lc($preflabel);
        $preflabel =~ lc($preflabel);
        $preflabel =~ s/x ray/x-ray/g;
        $preflabel = trim($preflabel);
        my $prefLabel_obj = $rdf->new_literal($preflabel, "en");
        $rdf->assert_literal(
             "http://www.extended_sso.org/resource#$concept",
             "http://www.w3.org/2004/02/skos/core#prefLabel",
             $prefLabel_obj
            );
    }

}

sub trim {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

sub populate_altLabels {
    my @keyword_lines = slurp("keyword_index.txt");
    foreach my $keyword_line (@keyword_lines) {
        chomp($keyword_line);
        my $concept;
        my $keyword;
        if ($keyword_line =~ /^(.*?)\s+HAS_KEYWORD\s+(.*)/) {
            $concept = $1;
            $keyword = $2;
        }
        $concept = trim($concept);
        $keyword = trim($keyword);
        my $altLabel_obj = $rdf->new_literal($keyword, "en");
        $rdf->assert_literal(
             "http://www.extended_sso.org/resource#$concept",
             "http://www.w3.org/2004/02/skos/core#altLabel",
             $altLabel_obj
            );
        
    }
}

sub generate_notes {
    my @notes_lines = slurp("note_index.txt");
    foreach my $notes_line (@notes_lines) {
        chomp($notes_line);
        my $concept;
        my $note;
        if ($notes_line =~ /^(.*?)\s+HAS_NOTE\s+(.*)/) {
            $concept = $1;
            $note = $2;
        }
        $concept = trim($concept);
        $note = trim($note);
        #my $note_obj = $rdf->new_literal($note, "en");
        my $note_obj = $rdf->new_literal($note, ""); #"http://www.extended_sso.org/resource#dataCategory");
        $rdf->assert_literal(
             "http://www.extended_sso.org/resource#$concept",
             "http://www.extended_sso.org/resource#dataCategory",
             $note_obj
            );
        
    }
    
}

sub generate_umls_prefLabel {
    my $parser = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse("../spreadsheet/ESSO.xls");
    my $worksheet = $workbook->worksheet("concept_data");

    for (my $i = 1; $i < 280; $i++) {
        my $concept_cell = $worksheet->get_cell($i,16);
        my $concept = $concept_cell->unformatted();
        $concept = lcfirst($concept);
        print $concept . "\n";
        my $umls_cell = $worksheet->get_cell($i, 18);
        my $umls      = $umls_cell->unformatted();
        if ($umls eq "0") {next;}
        $umls = trim($umls);
        $umls =~ s/\[//s;
        $umls =~ s/\]//s;
        my $umls_obj = $rdf->new_literal($umls, "", "http://www.extended_sso.org/resource#umlsPrefLabel");
        $rdf->assert_literal(
            "http://www.extended_sso.org/resource#$concept",
            "http://www.w3.org/2004/02/skos/core#notation",
            $umls_obj        
            );
    }
}

sub generate_icd_prefLabel {
    my $parser = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse("../spreadsheet/ESSO.xls");
    my $worksheet = $workbook->worksheet("concept_data");
    for (my $i = 1; $i < 280; $i++) {
        my $concept_cell = $worksheet->get_cell($i,16);
        my $concept = $concept_cell->unformatted();
        $concept = lcfirst($concept);
       
        my $icd9_cell = $worksheet->get_cell($i, 31);
        if (!(defined $icd9_cell)) {next;}

        my $icd9      = $icd9_cell->unformatted();
        print $icd9 . "\n";print $concept . "\n";
        $icd9 = trim($icd9);
        #standardize with other vocabs (i.e code followed by colon, then text
        # eg 83838.383:Some text)
        $icd9 =~ s/\s+/:/;       
        my $icd9_obj = $rdf->new_literal($icd9, "", "http://www.extended_sso.org/resource#icd9PrefLabel");
        $rdf->assert_literal(
            "http://www.extended_sso.org/resource#$concept",
            "http://www.w3.org/2004/02/skos/core#notation",
            $icd9_obj        
        );
    }
}

sub generate_mesh_prefLabel {
    my $parser = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse("../spreadsheet/ESSO.xls");
    my $worksheet = $workbook->worksheet("concept_data");
    for (my $i = 1; $i < 280; $i++) {
        my $concept_cell = $worksheet->get_cell($i,16);
        my $concept = $concept_cell->unformatted();
        $concept = lcfirst($concept);
       
        my $mesh_cell = $worksheet->get_cell($i, 30);
        if (!(defined $mesh_cell)) {next;}

        my $mesh      = $mesh_cell->unformatted();
      #  print $mesh . "\n";print $concept . "\n";
        $mesh = trim($mesh);
        # swap round so bracketed code is followed by text
        $mesh =~ s/(.*?)\s+\[(.*?)\]/$2:$1/g;
        $mesh =~ s/\[//g;
        $mesh =~ s/\]//g;
        
        my $mesh_obj = $rdf->new_literal($mesh, "", "http://www.extended_sso.org/resource#meshPrefLabel");
        $rdf->assert_literal(
            "http://www.extended_sso.org/resource#$concept",
            "http://www.w3.org/2004/02/skos/core#notation",
            $mesh_obj        
        );
    }
}

sub generate_sso {
    my $parser = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse("../spreadsheet/ESSO.xls");
    my $worksheet = $workbook->worksheet("concept_data");
    for (my $i = 1; $i < 280; $i++) {
        my $concept_cell = $worksheet->get_cell($i,16);
        my $concept = $concept_cell->unformatted();
        $concept = lcfirst($concept);

        my $sso_cell = $worksheet->get_cell($i,2);
        my $sso = $sso_cell->unformatted();
        $sso = trim($sso);
        if ($sso == 0) { next; }
     
        $rdf->assert_literal(
            "http://www.extended_sso.org/resource#$concept",
            "http://purl.org/dc/terms/source",
            "sso"    
        );        
    }    
}

sub generate_biocaster_label {
    my $parser = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse("../spreadsheet/ESSO.xls");
    my $worksheet = $workbook->worksheet("concept_data");
    for (my $i = 1; $i < 280; $i++) {
        my $concept_cell = $worksheet->get_cell($i,16);
        my $concept = $concept_cell->unformatted();
        $concept = lcfirst($concept);

        
        my $prov_label = $worksheet->get_cell($i,0);
         if (!(defined $prov_label)) {next;}
        my $prov_text  = $prov_label->unformatted();
        print "Biocaster $prov_text\t$concept\n";
        my $code_text;
        if ($prov_text =~ /biocaster/i) {
            my $code_label = $worksheet->get_cell($i,1);
            $code_text = $code_label->unformatted();
        
        my $biocaster_obj = $rdf->new_literal($code_text, "", "http://www.extended_sso.org/resource#biocasterPrefLabel");
        $rdf->assert_literal(
            "http://www.extended_sso.org/resource#$concept",
            "http://www.w3.org/2004/02/skos/core#notation",
            $biocaster_obj
        );
        }
    }
}

sub generate_dc_source {
    my $parser = Spreadsheet::ParseExcel->new();
    my $workbook = $parser->parse("../spreadsheet/ESSO.xls");
    my $worksheet = $workbook->worksheet("concept_data");
    for (my $i = 1; $i < 280; $i++) {
        my $concept_cell = $worksheet->get_cell($i,16);
        my $concept = $concept_cell->unformatted();
        $concept = lcfirst($concept);

        
        my $source_label = $worksheet->get_cell($i,0);
        if (!(defined $source_label)) {
            next;
        }
        my $source_text  = $source_label->unformatted();

        if ($source_text =~ /respiratory/i) {
            $rdf->assert_literal(
                "http://www.extended_sso.org/resource#$concept",
                "http://purl.org/dc/terms/source",
                "respiratory"
            );
        }

        if ($source_text =~ /icd/i) {
            $rdf->assert_literal(
                "http://www.extended_sso.org/resource#$concept",
                "http://purl.org/dc/terms/source",
                "icd"
            );
        }

        if ($source_text =~ /biocaster/i) {
            $rdf->assert_literal(
                "http://www.extended_sso.org/resource#$concept",
                "http://purl.org/dc/terms/source",
                "biocaster"
            );
        }
        
        if ($source_text =~ /rod/i) {
            $rdf->assert_literal(
                "http://www.extended_sso.org/resource#$concept",
                "http://purl.org/dc/terms/source",
                "rods"
            );
        }

        if ($source_text eq /bn/i) {
            $rdf->assert_literal(
                "http://www.extended_sso.org/resource#$concept",
                "http://purl.org/dc/terms/source",
                "bn_flu"
            );
        }

        if ($source_text =~ /flu/i) {
            $rdf->assert_literal(
                "http://www.extended_sso.org/resource#$concept",
                "http://purl.org/dc/terms/source",
                "bn_flu"
            );
        }

        if ($source_text =~ /measles/i) {
            $rdf->assert_literal(
                "http://www.extended_sso.org/resource#$concept",
                "http://purl.org/dc/terms/source",
                "bn_measles"
            );
        }

        if ($source_text =~ /syndrome/i) {
            $rdf->assert_literal(
                "http://www.extended_sso.org/resource#$concept",
                "http://purl.org/dc/terms/source",
                "syndrome_cc"
            );
        }

        if ($source_text =~ /ontology/i) {
            $rdf->assert_literal(
                "http://www.extended_sso.org/resource#$concept",
                "http://purl.org/dc/terms/source",
                "cc_ontology"
            );
        }       
    }
}

sub generate_regexp {
    my @regexp_lines = slurp("regexp_index.txt");
    foreach my $regexp_line (@regexp_lines) {
        chomp($regexp_line);
        my $concept;
        my $regexp;
        if ($regexp_line =~ /^(.*?)\s+HAS_REGEXP\s+(.*)/) {
            $concept = $1;
            $regexp = $2;
        }
        $regexp = trim($regexp); print "INTEREST " . $regexp . " $concept" . "\n";
        $concept = trim($concept);

        my $regexp_obj = $rdf->new_literal($regexp, "", "http://www.extended_sso.org/resource#englishRegExp");
        $rdf->assert_literal(
            "http://www.extended_sso.org/resource#$concept",
            "http://www.w3.org/2004/02/skos/core#notation",
            $regexp_obj        
            );
        
    }
}

sub generate_altUMLS {
    my @altUMLS_lines_all = slurp("altUMLS_index.txt");
    use List::Uniq ':all';
    my @altUMLS_lines = uniq(@altUMLS_lines_all);
    foreach my $altUMLS_line (@altUMLS_lines) {
        chomp($altUMLS_line);
        my $concept;
        my $umls;
        if ($altUMLS_line =~ /^(.*?)\s+HAS_ALT_UMLS\s+(.*)/) {
            $concept = $1;
            $umls = $2;
        }
        $umls = trim($umls);
        $concept = trim($concept);
        $umls =~ s/\[//s;
        $umls =~ s/\]//s;

        my $umls_obj = $rdf->new_literal($umls, "", "http://www.extended_sso.org/resource#umlsAltLabel");
        $rdf->assert_literal(
            "http://www.extended_sso.org/resource#$concept",
            "http://www.w3.org/2004/02/skos/core#notation",
            $umls_obj       
            );
        
    }
    
}

sub generate_indicators {
    my @lines = slurp("indicates_index.txt");
    foreach my $line (@lines) {
        chomp($line);
        my $concept;
        my $sign;
        if ($line =~ /^(.*?)\s+HAS_INDICATOR\s+(.*)/) {
            $concept = $1;
            $sign = $2;
        }
        $concept = trim($concept);
        $sign = trim($sign);
               $rdf->assert_resource(
             "http://www.extended_sso.org/resource#$concept",
            "http://www.extended_sso.org/resource#isAssociatedWithSymptom",
             "http://www.extended_sso.org/resource#$sign"
            )
    
    }
}

sub generate_diagnosis {
     my @lines = slurp("indicates_index.txt");
    foreach my $line (@lines) {
        chomp($line);
        my $concept;
        my $sign;
        if ($line =~ /^(.*?)\s+HAS_INDICATOR\s+(.*)/) {
            $concept = $1;
            $sign = $2;
        }
        $concept = trim($concept);
        $sign = trim($sign);

        $rdf->assert_resource(
             "http://www.extended_sso.org/resource#$sign",
            "http://www.extended_sso.org/resource#isAssociatedWithDisease",
             "http://www.extended_sso.org/resource#$concept"
            )
    }
}
