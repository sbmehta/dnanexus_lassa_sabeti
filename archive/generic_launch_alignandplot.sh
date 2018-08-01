### modified KJS 06/11/18 ###

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
REJECTFILTER_RE="subsamp|Unmatched"         # ** Reject any file whose full path matches this regex pattern

############# STANDARD OPTIONS ###############
APPNAME="align_and_plot"
APPDIR="/pipelines/1.19.2-11-gca5b926-dp-workflows/align_and_plot"

ASSEMBLYDIR="/align_and_plot"
RESOURCEDIR="/resource_files"
REFERENCEDIR="/references"

## metagenomic databases
OPTIONS=" istage-1.assembly_fasta=$REFERENCEDIR/ref-lasv-ISTH2376.fasta"
OPTIONS+="istage-1.gatk_jar=$RESOURCEDIR/GenomeAnalysisTK-3.6.tar.bz2"
OPTIONS+="stage-1.novocraft_license=$RESOURCEDIR/novoalign.lic"
OPTIONS+="stage-1.aligner="
OPTIONS+="stage-1.aligner_options="

## create output directory
OUTPUTDIR="$ASSEMBLYDIR/$FLOWCELLNAME"
dx mkdir $OUTPUTDIR


##############################################
DEBUG=0  # Uncomment to print filenames but not actually run

echo Options: $OPTIONS

for SAMPLE in $(dx find data --name *.bam --path /flowcells/$FLOWCELLDIR --delimiter "*" | cut -f 4 -d "*")
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
              -istage-1.reads_unmapped_bam="$SAMPLE" -istage-1.sample_name="$SAMPLENAME" $OPTIONS
      fi
   fi
done


done <flowcells_run_list.txt
