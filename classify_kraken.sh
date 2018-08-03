#! /bin/bash

###############################################################
### DNANEXUS BATCH PARAMETERS: CLASSIFY_KRAKEN ################
###############################################################
# VERSIONS:
#     v0.1  2018-08-03 sbm    Split off parameters from earlier "generic_launch" scripts
#
# Assumes running from the Broad cluster with something like the following environmentis already set up:
#    $ use Python-2.7
#    $ source /idi/sabeti-scratch/kjsiddle/dnanexus/dx-toolkit/environment
#    $ dx login --token [TOKEN]


##### TARGET DATA #####
PROJECT="project-XXXXXXXXXXXXXXXXXXXX"

INPUTDIR="/analysis"
OUTPUTDIR="/assemblies"

#declare -a SUBDIRS=("l1" "l2")    # optinally specify subdirectories

ACCEPTFILTER="bam"
REJECTFILTER="cleaned|subsamp|Unmatched"

##### JOB OPTIONS #####
APPNAME="classify_kraken"
APPDIR="/viral-ngs/1.21.0/classify_kraken"

RESOURCEDIR="/resources"
REFERENCEDIR="/references"

OPTIONS=""
#OPTIONS=" -istage-1.kraken_db_tar_lz4=$REFERENCEDIR/"            ## currently broken??
#OPTIONS+=" -istage-1.krona_taxonomy_db_tgz=$REFERENCEDIR/" 

source utilities/dna_batch_launch.sh
