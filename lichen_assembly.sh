#!/usr/bin/bash
#SBATCH --partition=
#SBATCH --job-name=illumina_assemblies
#SBATCH --time=14-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks # try to increase task number and see any change
#SBATCH --cpus-per-task=25
#SBATCH --mem-per-cpu=12gb # request memory, adjustable
#SBATCH --error=illumina_assemblies.%J.err
#SBATCH --output=illumina_assemblies.%J.out
#SBATCH --mail-user=samche42@gmail.com
#SBATCH --mail-type=END,FAIL



#Define flags
while getopts "a:" flag
do
    case "${flag}" in
        a) accession=${OPTARG};;
    esac
done

for acc in `cat $accession`; do
	#DOWNLOAD RAW DATA
	echo "Starting download of $acc"
	source activate sra-tools
	fastq-dump -I --split-files --outdir ./ ${acc}
	conda deactivate
	echo "Finished download of $acc"
	for seq_file in `ls ${acc}_1.fastq`; do
		#TRIMMOMATIC CLEAN UP
		echo "Starting trim of ${seq_file} and ${seq_file/_1.fastq/_2.fastq}..."
		source activate trimmomatic
		echo "trimmomatic PE -baseout ${seq_file/_1.fastq/.fastq} ${seq_file} ${seq_file/_1.fastq/_2.fastq} ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 MINLEN:25"
		trimmomatic PE -baseout ${seq_file/_1.fastq/.fastq} \
		${seq_file} ${seq_file/_1.fastq/_2.fastq} \
		ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 MINLEN:25
		conda deactivate
		echo "Completed trim of ${seq_file} and ${seq_file/_1.fastq/_2.fastq}"
		#SPADES ASSEMBLY
		echo "Starting assembly of $acc..."
		spades.py -t 25 -m 300 \
		--pe1-1 ${seq_file/_1.fastq/_1P.fastq} --pe1-2 ${seq_file/_1.fastq/_2P.fastq} \
		-o ${seq_file/_1.fastq/_Spades_Output} 
		mv ${seq_file/_1.fastq/_Spades_Output}/scaffolds.fasta ${seq_file/_1.fastq/_scaffolds.fasta} #Move scaffold file out and rename with accession
		rm -r ${seq_file/_1.fastq/_Spades_Output} #Delete folder containing other assembly files (we only need scaffolds.fasta for each)
		tar czvf ${seq_file/_1.fastq/_scaffolds.fasta}.tar.gz ${seq_file/_1.fastq/_scaffolds.fasta} #Compress scaffolds file
		rm ${acc}*.fastq #remove raw data
		rm ${seq_file/_1.fastq/_scaffolds.fasta} #remove uncompressed scaffolds file
	done
done

