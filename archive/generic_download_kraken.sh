### created KJS 05/27/18 ###

#use Python-2.7
#source /idi/sabeti-scratch/kjsiddle/dnanexus/dx-toolkit/environment
# dx select [project directory]
# unless you have re-run kraken in a separate directory you should be in the original directory where demux-plus was run in order to download these files


################ TARGET DATA #################
## flowcell ids are stored in flowcells_run_list.txt ##

while read FLOWCELLNAME; 
do
echo $FLOWCELLNAME

ASSEMBLYDIR=metagenomics/"$FLOWCELLNAME"    # ** Start with all files anywhere below this directory (recursive)
DOWNLOADDIR=/idi/sabeti-scratch/kjsiddle/viral-work/LASV17-18/BROAD_assemblies/kraken/"$FLOWCELLNAME"

mkdir $DOWNLOADDIR

##############################################
#DEBUG=0  # Uncomment to print filenames but not actually run

for SAMPLE in $(dx find data --name *summary_report.txt --path $ASSEMBLYDIR --delimiter "*" | cut -f 4 -d "*")
do
   SAMPLENAME=$(basename $SAMPLE)
      if [[ $DEBUG ]] ; then
         echo $SAMPLE
      else
         dx download $SAMPLE -o $DOWNLOADDIR
      fi
done


done <flowcells_run_list.txt
