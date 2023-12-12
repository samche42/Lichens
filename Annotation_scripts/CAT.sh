#!/usr/bin/bash
#SBATCH --partition=norm
#SBATCH --job-name=CAT
#SBATCH --time=4-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks # try to increase task number and see any change
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=40gb # request memory, adjustable
#SBATCH --error=CAT.%J.err
#SBATCH --output=CAT.%J.out
#SBATCH --mail-user=samche42@gmail.com
#SBATCH --mail-type=FAIL

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

cd Acceptable_assemblies/

source activate CAT

CAT contigs -c ${input_file} \
    -d /cat/CAT_prepare_20210107/2021-01-07_CAT_database \
    -t cat/CAT_prepare_20210107/2021-01-07_taxonomy \
    --out_prefix ${input_file/_scaffolds.fasta/''} \
    --nproc 16 \
    --I_know_what_Im_doing \
    --top 11

CAT add_names -i ${input_file/_scaffolds.fasta/''}.contig2classification.txt \
    -o ${input_file/_scaffolds.fasta/''}.official_names.txt \
    -t /cat/CAT_prepare_20210107/2021-01-07_taxonomy \
    --only_official

conda deactivate

rm ${input_file/_scaffolds.fasta/''}.contig2classification.txt ${input_file/_scaffolds.fasta/''}.log ${input_file/_scaffolds.fasta/''}.ORF2LCA.txt ${input_file/_scaffolds.fasta/''}.predicted_proteins.faa ${input_file/_scaffolds.fasta/''}.predicted_proteins.gff ${input_file/_scaffolds.fasta/''}.alignment.diamond
