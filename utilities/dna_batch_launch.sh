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
#       (optional)   SUBDIRS     Array of subddirectories to process, relative to INPUTDIR
#
#    ACCEPTFILTER    Process files whose full path matches this regex pattern ...
#    REJECTFILTER    ... without matching this regex pattern.
# 
#    APPNAME         DNAnexus app name ...
#    APPDIR          ... and where to find it, relative to project root.
#    OPTIONS         Full options string to be passed to APPNAME

#DEBUG=0  # Uncomment to print filenames but not actually run
echo =======================================================
echo Input: $INPUTDIR .... $ACCEPTFILTER, but not $REJECTFILTER
echo Output: $OUTPUTDIR
echo Running: $APPDIR/$APPNAME
echo Options: $OPTIONS
echo =======================================================

dx select $PROJECT

if [ -z $SUBDIRS ] ; then declare -a SUBDIRS=(".");  fi

for DIR in ${SUBDIRS[*]}
do
    echo =========================
    if [ $DIR == "." ]  ; then
	INPUTSUBDIR=$INPUTDIR
        OUTPUTSUBDIR=$OUTPUTDIR
    else
	INPUTSUBDIR=$INPUTDIR/$DIR
        OUTPUTSUBDIR=$OUTPUTDIR/$DIR
    fi
    echo RUNNING FROM $INPUTSUBDIR TO $OUTPUTSUBDIR

    for SAMPLE in $(dx find data --name *.bam --path $INPUTSUBDIR --delimiter "*" | cut -f 4 -d "*")
    do
	SAMPLENAME=$(basename $SAMPLE)
	if [[ $SAMPLE =~ $ACCEPTFILTER ]] && [[ ! $SAMPLE =~ $REJECTFILTER ]]  ; then
            echo $SAMPLE

	    if [ -z $DEBUG ] ; then
		dx mkdir -p $OUTPUTSUBDIR
		
		dx run "$APPDIR/$APPNAME" --yes --destination "$OUTPUTSUBDIR" \
		    --name "$APPNAME|$DIR|${SAMPLENAME%.*}" --tag "$DIR" \
		    -istage-1.raw_reads_unmapped_bam="$SAMPLE" \       # sloppy way of dealing with options that include "SAMPLE" by just putting them all here
                    -istage-1.sample_name="$SAMPLENAME"
                    $OPTIONS
	    fi
	fi
    done
done

echo =======================================================
