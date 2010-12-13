#!/usr/bin/perl -W

# skos.pl
# mike conway Oct 2010
# A wrapper for organizing indices and ancilliary scripts for the production of ESSO
# SKOS

use strict;

#generate indices - an intermediary perl one liner is used to eliminate
#problematic character encoding (remove all non-ascii characters)

system("perl altUMLS_index.pl | perl  -pe 's/[^[:ascii:]]//g;' > altUMLS_index.txt");
system("perl concept_relation_index.pl | perl concept_post_process.pl | perl -pe 's/[^[:ascii:]]//g;' > related_index.txt");
system("perl indicates_index.pl  | perl -pe 's/[^[:ascii:]]//g;'  > indicates_index.txt");
system("perl keyword_index.pl | perl  -pe 's/[^[:ascii:]]//g;' > keyword_index.txt");
system("perl note_index.pl | perl -pe 's/[^[:ascii:]]//g;'  > note_index.txt");
system("perl regexp_index.pl | perl -pe 's/[^[:ascii:]]//g;'  > regexp_index.txt");
system("perl syndrome_index.pl | perl  -pe 's/[^[:ascii:]]//g;'  > syndrome_index.txt");

#skos generation script
system("perl generate_skos.pl");
