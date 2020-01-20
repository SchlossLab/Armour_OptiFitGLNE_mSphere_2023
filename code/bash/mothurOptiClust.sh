#! /bin/bash
# mothurOptiClust.sh
# Begum Topcuoglu
# William L. Close
# Schloss Lab
# University of Michigan

##################
# Set Script Env #
##################

# Set the variables to be used in this script
FASTA=${1:?ERROR: Need to define FASTA.}
COUNT=${2:?ERROR: Need to define COUNT.}
TAXONOMY=${3:?ERROR: Need to define TAXONOMY.}

# Other variables
OUTDIR=data/process/opticlust/shared/ # Output dir based on sample name to keep things separate during parallelization/organized
NPROC=$(nproc) # Setting number of processors to use based on available resources
SUBSIZE=10000 # Number of reads to subsample to, based on Baxter, et al., Genome Med, 2016


#############################################
# Create Master Shared File Using OptiClust #
#############################################

# Cluster all sequences while leaving out the specified sample
mothur "#set.current(outputdir="${OUTDIR}"/, processors="${NPROC}", fasta="${FASTA}", count="${COUNT}", taxonomy="${TAXONOMY}");
	dist.seqs(fasta=current, cutoff=0.03);
	cluster(column=current, count=current);
	make.shared(list=current, count=current, label=0.03);
	sub.sample(shared=current, label=0.03, size="${SUBSIZE}")"

# Removing file generated by set.current()
rm "${OUTDIR}"/current_files.summary

# Renaming outputs of files generated after leaving the specified sample out
for FILE in $(find "${OUTDIR}"/ -regex ".*precluster.*"); do

	# Uses path and suffix of input file to rename output file using $SAMPLE and 'out' to represent the file is for
	# all of the other samples after the specified sample has been left out.
	REPLACEMENT=$(echo "${FILE}" | sed "s:precluster:opticlust:")

	# Rename files using new format
	echo mv "${FILE}" "${REPLACEMENT}"

done
