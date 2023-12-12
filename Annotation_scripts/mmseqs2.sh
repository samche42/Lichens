#!/usr/bin/bash
#SBATCH --partition=
#SBATCH --job-name=mmseqs
#SBATCH --time=4-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks # try to increase task number and see any change
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=25gb # request memory, adjustable
#SBATCH --error=mmseqs.%J.err
#SBATCH --output=mmseqs.%J.out

#Run with for accession in `cat accessions`;do sbatch mmseqs2.sh -a ${accession};done

usage()
{
   # Display Help
   echo "-h     Display help menu"
   echo
   echo "Required flags:"
   echo "-a     Accession"
}

#Define flags
while getopts "a:h" flag
do
    case "${flag}" in
        a) acc=${OPTARG};;
        h) usage exit;;
    esac
done

cd Acceptable_assemblies/

source activate mmseqs2

mmseqs createdb ${acc}_scaffolds.fasta ${acc}_DB
mmseqs taxonomy ${acc}_DB /mmseqs2/NR/NR ${acc}_mmseqs_taxonomy.txt ${acc}_temp --tax-lineage 1 --orf-filter 1 --threads 24 --split-memory-limit 600G
mmseqs createtsv ${acc}_DB ${acc}_mmseqs_taxonomy.txt ${acc}_mmseqs_taxonomy_final.txt
rm ${acc}_mmseqs_taxonomy.txt*
rm -r ${acc}_temp
rm ${acc}_DB*

conda deactivate
