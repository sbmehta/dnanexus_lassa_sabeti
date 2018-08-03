#! /bin/bash

##########################################
### DNANEXUS SCRIPT: launch batch jobs ###
##########################################
# VERSIONS:
#     v0.1  2018-08-01 sbm    Created based on earlier "generic_launch" scripts
#
# Assumes running from the Broad cluster with something like the following environmentis already set up:
#    $ use Python-2.7
#    $ source /idi/sabeti-scratch/kjsiddle/dnanexus/dx-toolkit/environment
#    $ dx login --token [TOKEN]


##########################################
############### PARAMETERS ###############
##########################################

##### TARGET DATA #####
PROJECT="project-FJ4PZ2j0VkG0Vz2Z74bX0x7Q"    ## DNAnexus PROJECT ID

INPUTDIR="/analysis"                          ## Input directory, relative to project root
OUTPUTDIR="/assemblies"                       ## Output directory, relative to project root

SUBDIR[0]="l2"                                ## List of subddirectories to process, relative to INPUTDIR
SUBDIR[1]="l2"

ACCEPTFILTER="bam"                            ## Process files whose full path matches this regex pattern ...
REJECTFILTER="cleaned|subsamp|Unmatched"      ##  ... without matching this regex pattern.

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


##############################################
#DEBUG=0  # Uncomment to print filenames but not actually run
echo Options: $OPTIONS

dx select $PROJECT
for DIR in $SUBDIR
do
    for SAMPLE in $(dx find data --name *.bam --path $INPUTDIR/$DIR --delimiter "*" | cut -f 4 -d "*")
    do
	SAMPLENAME=$(basename $SAMPLE)
	if [[ $SAMPLE =~ $ACCEPTFILTER ]] && [[ ! $SAMPLE =~ $REJECTFILTER ]]  ; then
	    if [[ $DEBUG ]] ; then
		echo $SAMPLE
	    else
		dx mkdir -p $OUTPUTDIR/$DIR
		
		dx run "$APPDIR/$APPNAME" --yes \
		    --destination "$OUTPUTDIR/$DIR" \
		    --name "$APPNAME|$DR|${SAMPLENAME%.*}" \
		    --tag "$DIR" \
		    -istage-1.raw_reads_unmapped_bam="$SAMPLE" $OPTIONS
	    fi
	fi
    done
done

