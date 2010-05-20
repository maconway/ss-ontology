#!/usr/bin/python


# 19th May 2010
# populate_ili.py
# Mike Conway, University of Pittsburgh, DBMI

# SVN versioning info:
# $Id$

# This python script reads from a spreadsheet containing terms, relations, links,
# etc.  to populate a skeleton OWL file produced by Protege.  Currently we are
# only interested in ILI (Influenza like Illness).  The data was produced by
# Mike Conway and John Dowling (infectious disease physician)

import fileinput
import sys
import re
import pdb
from rdflib import *
import warnings


#load up local owl file containing relations and classes
graph = ConjunctiveGraph()
graph.commit()
graph.parse("ili.owl")




loop_counter = 0

for record in fileinput.input():
    #Skip headers line
    #Process those records only relevant to ILI (lns 2->59)
    if loop_counter == 0:
        loop_counter = loop_counter + 1
        continue
    if loop_counter == 60:
        break
    
    # First, remove all double quotation marks introduced
    # by the Excel "save to tab format"
    record = re.sub("\"", "", record)
    #pdb.set_trace()

    # FORMAT INPUT RECORD
    field = record.split('\t')
    subconcept = field[16]; subconcept.strip(); subconcept = unicode(subconcept)
    relation   = field[17]; relation.strip()
    umls       = field[18]; umls.strip()
    diagnosis  = field[19]; diagnosis.strip()
    syndrome   = field[20]; syndrome.strip()
    phys_find  = field[21]; phys_find.strip()
    symptom    = field[22]; symptom.strip()
    sign       = field[23]; sign.strip()

  
    
    if diagnosis == "1":
        graph.add((u"http://www.owl-ontologies.com/Ontology1274288723.owl#" + subconcept,u"http://www.w3.org/1999/02/22-rdf-syntax-ns#type", u"http://www.owl-ontologies.com/Ontology1274288723.owl#Disease"))
    

  
    
   
    loop_counter = loop_counter + 1

    #ADD subroutine to Add subconcepts (first diagnosis, then others)
    #                      UMLS code
    #                      keywords
    #                      regular expressions

graph.serialize(destination="output.owl", format="xml")

