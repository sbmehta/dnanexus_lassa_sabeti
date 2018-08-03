#! /bin/bash

##########################################
### DNANEXUS SCRIPT: launch batch jobs ###
##########################################
# VERSIONS:
#     v0.1  2018-08-03 sbm    Split out actual batch loop from parameters file
#
# Please call from another script/environment where relevant paramters are already set; will not run as an independent script.
#
# Required Parameters: 
#    PROJECT         DNAnexus PROJECT ID
#    INPUTDIR        Input directory, relative to project root
#    OUTPUTDIR       Output directory, relative to project root
#    SUBDIR          Array of subddirectories to process, relative to INPUTDIR
#
#    ACCEPTFILTER    Process files whose full path matches this regex pattern ...
#    REJECTFILTER    ... without matching this regex pattern.
# 
#    APPNAME         DNAnexus app name ...
#    APPDIR          ... and where to find it.
#    OPTIONS         Full options string to be passed to APPNAME


##############################################
DEBUG=0  # Uncomment to print filenames but not actually run
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
		    --name "$APPNAME|$DIR|${SAMPLENAME%.*}" \
		    --tag "$DIR" \
		    -istage-1.raw_reads_unmapped_bam="$SAMPLE" $OPTIONS
	    fi
	fi
    done
done

