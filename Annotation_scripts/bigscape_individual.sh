#!/usr/bin/bash
#SBATCH --partition=
#SBATCH --job-name=bigscape
#SBATCH --time=4-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks # try to increase task number and see any change
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=50gb # request memory, adjustable
#SBATCH --error=bigscape.%J.err
#SBATCH --output=bigscape.%J.out

#Run with: for GCF in `ls -d Bacterial_AND_Fungal_BGCs/*/`; do sbatch bigscape_individual.sh -i ${GCF};done

usage()
{
   # Display Help
   echo "-h     Display help menu"
   echo
   echo "Required flags:"
   echo "-i     Input directory"
}

#Define flags
while getopts "i:h" flag
do
    case "${flag}" in
        i) input_dir=${OPTARG};;
        h) usage exit;;
    esac
done

source activate bigscape

bigscape.py \
        --inputdir ${input_dir} \
        --outputdir ${input_dir}/Bigscape_results \
        -v --mibig --mode auto --mix \
        --include_singletons --cutoffs 0.3 \
        --pfam_dir Databases --cores 8

conda deactivate
