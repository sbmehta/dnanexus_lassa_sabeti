#! /bin/bash

###############################################################
### DNANEXUS BATCH PARAMETERS: ASSEMBLE_DENOVO_WITH_DEPLETE ###
###############################################################
# VERSIONS:
#     v0.1  2018-08-03 sbm    Split off parameters from earlier "generic_launch" scripts
#
# Assumes running from the Broad cluster with something like the following environmentis already set up:
#    $ use Python-2.7
#    $ source /idi/sabeti-scratch/kjsiddle/dnanexus/dx-toolkit/environment
#    $ dx login --token [TOKEN]


##### TARGET DATA #####
PROJECT="project-FJ4PZ2j0VkG0Vz2Z74bX0x7Q"

INPUTDIR="/analysis"
OUTPUTDIR="/assemblies"

#declare -a SUBDIRS=("l1" "l2")    # optinally specify subdirectories

ACCEPTFILTER="bam"
REJECTFILTER="cleaned|subsamp|Unmatched"

##### JOB OPTIONS #####
APPNAME="assemble_denovo_with_deplete"
APPDIR="/viral-ngs/1.21.0/assemble_denovo_with_deplete"

RESOURCEDIR="/resources"
REFERENCEDIR="/references"

OPTIONS=" -istage-2.lastal_db_fasta=$REFERENCEDIR/all-lasv.fasta"                      
OPTIONS+=" -istage-4.reference_genome_fasta=$REFERENCEDIR/ref-lasv-BNI_Nig08_A19.fasta" 
OPTIONS+=" -istage-4.reference_genome_fasta=$REFERENCEDIR/ref-lasv-ISTH2376.fasta"
OPTIONS+=" -istage-4.reference_genome_fasta=$REFERENCEDIR/ref-lasv-KGH_G502.fasta"
OPTIONS+=" -istage-4.min_length_fraction=0.01"
OPTIONS+=" -istage-4.min_unambig=0.01"
OPTIONS+=" -istage-5.gatk_jar=$RESOURCEDIR/GenomeAnalysisTK-3.6.tar.bz2"               
OPTIONS+=" -istage-5.novocraft_license=$RESOURCEDIR/novoalign.lic"

source utilities/dna_batch_launch.sh
