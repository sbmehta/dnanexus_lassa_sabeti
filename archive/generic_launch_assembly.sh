### modified KJS 03/01/18 ###

#use Python-2.7
#source /idi/sabeti-scratch/kjsiddle/dnanexus/dx-toolkit/environment
# dx select [project directory]

################ TARGET DATA #################
## flowcell ids are stored in flowcells_run_list.txt ##

while read FLOWCELLNAME; 
do
echo $FLOWCELLNAME

FLOWCELLDIR="$FLOWCELLNAME"    # ** Start with all bam files anywhere below this directory (recursive)
ACCEPTFILTER_RE="bam"                     # ** Accept only files whose full paths match this regex pattern
REJECTFILTER_RE="cleaned|subsamp|Unmatched"         # ** Reject any file whose full path matches this regex pattern

############# STANDARD OPTIONS ###############
APPNAME="assemble_denovo_with_deplete"
APPDIR="/pipelines/1.19.2-11-gca5b926-dp-workflows/assemble_denovo_with_deplete"

ASSEMBLYDIR="/assemblies_lasv"
RESOURCEDIR="/resource_files"
REFERENCEDIR="/references"

## negative depletion filters
#OPTIONS=" -istage-1.bwaDbs=$RESOURCEDIR/hg19.bwa_idx.tar.lz4"
#OPTIONS+=" -j '{\"stage-1.bmtaggerDbs\":[]}'"

## positive depletion filter
OPTIONS=" -istage-2.lastal_db_fasta=$REFERENCEDIR/all-lasv.fasta"                      

## references
OPTIONS+=" -istage-4.reference_genome_fasta=$REFERENCEDIR/ref-lasv-BNI_Nig08_A19.fasta" 
OPTIONS+=" -istage-4.reference_genome_fasta=$REFERENCEDIR/ref-lasv-ISTH2376.fasta"
OPTIONS+=" -istage-4.reference_genome_fasta=$REFERENCEDIR/ref-lasv-KGH_G502.fasta"

## QI cutoffs
OPTIONS+=" -istage-4.min_length_fraction=0.01"
OPTIONS+=" -istage-4.min_unambig=0.01"

## assembly resources
OPTIONS+=" -istage-5.gatk_jar=$RESOURCEDIR/GenomeAnalysisTK-3.6.tar.bz2"               
OPTIONS+=" -istage-5.novocraft_license=$RESOURCEDIR/novoalign.lic"

## create output directory
OUTPUTDIR="$ASSEMBLYDIR/$FLOWCELLNAME"
dx mkdir $OUTPUTDIR

##############################################
#DEBUG=0  # Uncomment to print filenames but not actually run

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
              -istage-1.raw_reads_unmapped_bam="$SAMPLE" $OPTIONS
      fi
   fi
done


done <flowcells_run_list.txt
