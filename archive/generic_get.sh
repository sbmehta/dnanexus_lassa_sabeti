### DNA Nexus script: downloads all files whose names match an RE and renames them with a modified version of their full path

### Assumes DNAnexus environment already set up using commands like those below
#use Python-2.7
#source /idi/sabeti-scratch/kjsiddle/dnanexus/dx-toolkit/environment
#dx login --token y8PHfHZDKX9XRxZNQGO7kAzICeno1ehB --noprojects      # samar's token till 2018-03-02
#dx select project-F5z8Jpj0Yqp6fFpXGfJVBg3b                          # LASV/FUO 15-17

#TOPDIR="project-Bq29k680jy1JF3gvkk3Gjf11:/180601_SL-HDD_0981_ACCHDDANXX/analyses"      # ** Start with all files anywhere below this directory (recursive)
TOPDIR="project-Bq29k680jy1JF3gvkk3Gjf11:/180627_SL-NVB_0098_AFCHCYTJDMXX/analyses"      # ** Start with all files anywhere below this directory (recursive)

ACCEPTFILTER_RE="barcodes"      # ** Accept only files whose full paths match this regex
REJECTFILTER_RE="nothing"      # ** Reject all files whose full paths match this regex

#REMOVETEXT_RE="s/_SL-HDD_0981|\.analyses//g"   # ** remove text matching this sed regex from output filename
REMOVETEXT_RE="s/_SL-NVB_0098|\.analyses//g"   # ** remove text matching this sed regex from output filename

##############################################
#DEBUG=0  # Uncomment to print filenames but not actually run

for FILE in $(dx find data --name "*.txt" --path $TOPDIR --delimiter "*" | cut -f 4 -d "*")
do
   OUTFILE=$(echo $FILE | tr / . | cut -c 2- | sed -r $REMOVETEXT_RE)     # file-> path-> validfilname -> trim first .

   if [[ $FILE =~ $ACCEPTFILTER_RE ]] && [[ ! $FILE =~ $REJECTFILTER_RE  ]] ; then
      if [[ $DEBUG ]] ; then
         echo $OUTFILE
      else
	 dx download $FILE -o "$OUTFILE"
      fi
   fi
done
