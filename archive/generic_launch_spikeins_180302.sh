### created KJS 03/02/18 ###

#use Python-2.7
#source /idi/sabeti-scratch/kjsiddle/dnanexus/dx-toolkit/environment
# dx select [project directory]

################ TARGET DATA #################
## flowcell ids are stored in flowcells_run_list.txt ##

while read FLOWCELLNAME; 
do
echo $FLOWCELLNAME

FLOWCELLDIR="$FLOWCELLNAME"    # ** Start with all bam files anywhere below this directory (recursive)
ACCEPTFILTER_RE="cleaned.bam"                     # ** Accept only files whose full paths match this regex pattern
REJECTFILTER_RE="mapped|subsamp|Unmatched"         # ** Reject any file whose full path matches this regex pattern

############# STANDARD OPTIONS ###############
APPNAME="spikein"
APPDIR="/pipelines/1.19.2-13-g53432ab-dp-workflows/spikein"

REPORTDIR="/spikein_reports"
INPUTDIR="assemblies_lasv"

## spikein reports currently has no optional inputs ##

## create output directory
OUTPUTDIR="$REPORTDIR/$FLOWCELLNAME"
dx mkdir $OUTPUTDIR

##############################################
#DEBUG=0  # Uncomment to print filenames but not actually run

echo Options: $OPTIONS

for SAMPLE in $(dx find data --name *cleaned.bam --path $INPUTDIR/$FLOWCELLDIR --delimiter "*" | cut -f 4 -d "*")
do
   SAMPLENAME=$(basename $SAMPLE)
   if [[ $SAMPLE =~ $ACCEPTFILTER_RE ]] && [[ ! $SAMPLE =~ $REJECTFILTER_RE ]]  ; then
      if [[ $DEBUG ]] ; then
         echo $SAMPLE
      else
         dx run "$APPDIR/$APPNAME" --yes \
              --destination "$OUTPUTDIR" \
              --name "$APPNAME|$FLOWCELLNAME|${SAMPLENAME%.*}" \
              --tag "$FLOWCELLNAME" \
              -istage-1.reads_bam="$SAMPLE" $OPTIONS
      fi
   fi
done


done <flowcells_run_list.txt
