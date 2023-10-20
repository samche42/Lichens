!/usr/bin/bash
#SBATCH --partition=
#SBATCH --job-name=antismash
#SBATCH --time=4-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 #Tasks
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=2gb # request memory, adjustable
#SBATCH --error=antismash.%J.err
#SBATCH --output=antismash.%J.out

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

source activate antismash

if [ ! -d ${input_file/scaffolds.fasta/antiSMASH_output} ]
        then
            	antismash --cb-general --cb-knownclusters --cb-subclusters \
                --asf --pfam2go --smcog-trees --genefinding-tool prodigal ${input_file} \
                --cpus 8 --output-dir ${input_file/.fasta/_antiSMASH_output}
        fi

conda deactivate
