#!/usr/bin/bash
#SBATCH --partition=
#SBATCH --job-name=CAT
#SBATCH --time=4-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks 
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=40gb 
#SBATCH --error=CAT.%J.err
#SBATCH --output=CAT.%J.out

#Looped through all fasta files with the following command:
#for file in Lichen_assemblies/*.fasta; do sbatch CAT.sh -i ${file};done

usage()
{
   # Display Help
   echo "-h     Display help menu"
   echo
   echo "Required flags:"
   echo "-i     Input fasta file"
}

#Define flags
while getopts "i:h" flag
do
    case "${flag}" in
        i) input_file=${OPTARG};;
        h) usage exit;;
    esac
done

source activate CAT

CAT contigs -c ${input_file} \
    -d CAT_prepare_20210107/2021-01-07_CAT_database \
    -t CAT_prepare_20210107/2021-01-07_taxonomy \
    --out_prefix ${input_file/_scaffolds.fasta/''} \
    --nproc 16 \
    --I_know_what_Im_doing \
    --top 11

CAT add_names -i ${input_file/_scaffolds.fasta/''}.contig2classification.txt \
    -o ${input_file/_scaffolds.fasta/''}.official_names.txt \
    -t CAT_prepare_20210107/2021-01-07_taxonomy \
    --only_official

CAT summarise -c ${input_file} \
    -i ${input_file/_scaffolds.fasta/''}.official_names.txt \
    -o ${input_file/_scaffolds.fasta/''}.summary.txt

conda deactivate
