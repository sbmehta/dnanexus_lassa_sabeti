#! /bin/bash

###############################################################
### DNANEXUS BATCH PARAMETERS: ALIGN_AND_PLOT #################
###############################################################
# VERSIONS:
#     v0.1  2018-08-03 sbm    Split off parameters from earlier "generic_launch" script
#
# Assumes running from the Broad cluster with something like the following environmentis already set up:
#    $ use Python-2.7
#    $ source /idi/sabeti-scratch/kjsiddle/dnanexus/dx-toolkit/environment
#    $ dx login --token [TOKEN]


##### TARGET DATA #####
PROJECT="project-XXXXXXXXXXXXXXXXXXXX"

INPUTDIR="/analysis"
OUTPUTDIR="/assemblies"

ACCEPTFILTER="cleaned.bam"
REJECTFILTER="subsamp|Unmatched"

##### JOB OPTIONS #####
APPNAME="align_and_plot"
APPDIR="/viral-ngs/1.21.0/align_and_plot"

RESOURCEDIR="/resources"
REFERENCEDIR="/references"

## metagenomic databases
OPTIONS=" -istage-1.assembly_fasta=$REFERENCEDIR/ref-lasv-ISTH2376.fasta"
OPTIONS+=" -istage-1.gatk_jar=$RESOURCEDIR/GenomeAnalysisTK-3.6.tar.bz2"
OPTIONS+=" -istage-1.novocraft_license=$RESOURCEDIR/novoalign.lic"
#OPTIONS+="istage-1.aligner="
#OPTIONS+="istage-1.aligner_options="



source utilities/dna_batch_launch.sh




