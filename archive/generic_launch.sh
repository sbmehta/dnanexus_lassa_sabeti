#use Python-2.7
#source /idi/sabeti-scratch/kjsiddle/dnanexus/dx-toolkit/environment
#dx login --token y8PHfHZDKX9XRxZNQGO7kAzICeno1ehB --noprojects      # samar's token till 2018-03-02
## dx login --token 3aQSon1SFT7Op4l0a8bvrXR3gf9fMUmn      # admin token through 2018-03-14
#dx select project-F5z8Jpj0Yqp6fFpXGfJVBg3b                          # LASV/FUO 15-17

################ TARGET DATA #################
# ** Uncomment one of the following flowcell names (or specify your own):
#FLOWCELLNAME="170424_M04004_0153_000000000_AYGEF"
#FLOWCELLNAME="170712_SL-HFA_0319_BFCHKJNFBBXX"
#FLOWCELLNAME="170921_SL-HBU_0700_BHYCHHBCXY"
#FLOWCELLNAME="171013_SL-HAK_0510_ACBMYCANXX"
#FLOWCELLNAME="171219_SL_HAK_0528_ACC5Y8ANXX"
#FLOWCELLNAME="180105_SL-HCD_0754_AH2WLVBCX2"
FLOWCELLNAME="180124_SL-HCD_0767_BH2YLKBCX2"

FLOWCELLDIR="$FLOWCELLNAME/demux_bams"    # ** Start with all bam files anywhere below this directory (recursive)
ACCEPTFILTER_RE="bam"                     # ** Accept only files whose full paths match this regex pattern
REJECTFILTER_RE="cleaned|subsamp"         # ** Reject any file whose full path matches this regex pattern

#ACCEPTFILTER_RE="BHYCHHBCXY/raw_merged/LASV_NGA_2016_1006"
#ACCEPTFILTER_RE+="|CBMYCANXX/raw_merged/NGA_FUO_pool_02"
#ACCEPTFILTER_RE+="|ACC5Y8ANXX.*LASV_NGA_2016_0759"

############# STANDARD OPTIONS ###############
APPNAME="assemble_denovo_with_deplete"
APPDIR="/pipelines/1.19.1-33-ga7b4ca8-dp-bmtagger/assemble_denovo_with_deplete"

ASSEMBLYDIR="/assemblies_lasv"
RESOURCEDIR="/resource_files"
REFERENCEDIR="/references"

## negative depletion filters
OPTIONS=" -istage-1.bmtaggerDbs=$RESOURCEDIR/GRCh37.68_ncRNA.bmtagger_db.tar.gz"        
OPTIONS+=" -istage-1.bmtaggerDbs=$RESOURCEDIR/hg19.bmtagger_db.tar.gz"
OPTIONS+=" -istage-1.bmtaggerDbs=$RESOURCEDIR/metagenomics_contaminants_v3.bmtagger_db.tar.gz"

## positive depletion filter
OPTIONS+=" -istage-2.lastal_db_fasta=$REFERENCEDIR/all-lasv.fasta"                      

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

##############################################
#DEBUG=0  # Uncomment to print filenames but not actually run

for SAMPLE in $(dx find data --name *.bam --path /flowcells/$FLOWCELLDIR --delimiter "*" | cut -f 4 -d "*")
do
   SAMPLENAME=$(basename $SAMPLE)
   if [[ $SAMPLE =~ $ACCEPTFILTER_RE ]] && [[ ! $SAMPLE =~ $REJECTFILTER_RE ]]  ; then
      if [[ $DEBUG ]] ; then
         echo $SAMPLE
      else
         dx run "$APPDIR/$APPNAME" --yes \
              --destination "$ASSEMBLYDIR/$FLOWCELLNAME" \
              --name "$APPNAME|$FLOWCELLNAME|${SAMPLENAME%.*}" \
              --tag "$FLOWCELLNAME" \
              -istage-1.raw_reads_unmapped_bam="$SAMPLE" $OPTIONS
      fi
   fi
done

