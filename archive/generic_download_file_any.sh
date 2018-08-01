### created KJS 07/21/18 ###

#use Python-2.7
#source /idi/sabeti-scratch/kjsiddle/dnanexus/dx-toolkit/environment
# dx select [project directory]

################ TARGET DATA #################
## flowcell ids are stored in flowcells_run_list.txt ##

while read FLOWCELLNAME; 
do
echo $FLOWCELLNAME

SEARCHDIR=assemblies_lasv/"$FLOWCELLNAME"    # ** Start with all bam files anywhere below this directory (recursive)
DOWNLOADDIR=/idi/sabeti-scratch/kjsiddle/viral-work/LASV17-18/cleaned_bams

echo $ASSEMBLYDIR

ACCEPTFILTER_RE="cleaned.bam"                     # ** Accept only files whose full paths match this regex pattern
REJECTFILTER_RE="refine1|trinity|scaffold|intermediate"         # ** Reject any file whose full path matches this regex pattern

##############################################
#DEBUG=0  # Uncomment to print filenames but not actually run

for SAMPLE in $(dx find data --name *$ACCEPTFILTER_RE --path $SEARCHDIR --delimiter "*" | cut -f 4 -d "*")
do
   SAMPLENAME=$(basename $SAMPLE)
   if [[ $SAMPLE =~ $ACCEPTFILTER_RE ]] && [[ ! $SAMPLE =~ $REJECTFILTER_RE ]]  ; then
      if [[ $DEBUG ]] ; then
         echo $SAMPLE
      else
         dx download $SAMPLE -o $DOWNLOADDIR
      fi
   fi
done


done <flowcells_run_list.txt
