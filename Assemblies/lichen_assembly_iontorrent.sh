#!/usr/bin/bash
#SBATCH --partition=
#SBATCH --job-name=iontorrent_assembly
#SBATCH --time=14-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks # try to increase task number and see any change
#SBATCH --cpus-per-task=25
#SBATCH --mem-per-cpu=20gb # request memory, adjustable
#SBATCH --error=iontorrent_assembly.%J.err
#SBATCH --output=iontorrent_assembly.%J.out
#SBATCH --mail-user=samche42@gmail.com
#SBATCH --mail-type=END,FAIL

cd /home/simonsonsc/Lichen_assemblies/Ion_torrent_assemblies

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
	fastq-dump -I --outdir ./ ${acc}
	conda deactivate
	echo "Finished download of $acc"
	for seq_file in `ls ${acc}.fastq`; do
		#SPADES ASSEMBLY
		echo "Starting assembly of $acc..."
		spades.py -t 25 -m 500 \
		--iontorrent \
		--s1 ${seq_file}\
		-o ${seq_file/.fastq/_Spades_Output} 
		mv ${seq_file/.fastq/_Spades_Output}/scaffolds.fasta ${seq_file/.fastq/_scaffolds.fasta} #Move scaffold file out and rename with accession
		#rm -r ${seq_file/_1.fastq/_Spades_Output} #Delete folder containing other assembly files (we only need scaffolds.fasta for each)
		#tar czvf ${seq_file/_1.fastq/_scaffolds.fasta}.tar.gz ${seq_file/_1.fastq/_scaffolds.fasta} #Compress scaffolds file
		#rm ${acc}*.fastq #remove raw data
		#rm ${seq_file/_1.fastq/_scaffolds.fasta} #remove uncompressed scaffolds file
	done
done

