#!/usr/bin/bash
#SBATCH --partition=
#SBATCH --job-name=bigscape
#SBATCH --time=4-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks # try to increase task number and see any change
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=200gb # request memory, adjustable
#SBATCH --error=bigscape.%J.err
#SBATCH --output=bigscape.%J.out

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
        -v --mibig --no_classify --mode auto \
        --include_singletons \
        --pfam_dir Databases --cores 8

conda deactivate
