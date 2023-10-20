#!/usr/bin/bash
#SBATCH --partition=
#SBATCH --job-name=special_cases
#SBATCH --time=14-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks # try to increase task number and see any change
#SBATCH --cpus-per-task=25
#SBATCH --mem-per-cpu=20gb # request memory, adjustable
#SBATCH --error=special_cases.%J.err
#SBATCH --output=special_cases.%J.out

cd Special_cases

mkdir SAMN08225147

cd SAMN08225147

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
done

source activate trimmomatic
for seq_file in `ls *_1.fastq`; do
	trimmomatic PE -baseout ${seq_file/_1.fastq/.fastq} \
	${seq_file} ${seq_file/_1.fastq/_2.fastq} \
	ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 MINLEN:25
done
conda deactivate

#Concatenate fwd and rev files into single fwd and rev 
cat *_1P.fastq > SAMN08225147_1.fastq
cat *_2P.fastq > SAMN08225147_2.fastq

#SPADES ASSEMBLY
echo "Starting assembly of $acc..."
spades.py -t 25 -m 500 \
--pe1-1 SAMN08225147_1.fastq --pe1-2 SAMN08225147_2.fastq \
-o SAMN08225147_Spades_Output

mv SAMN08225147_Spades_Output/scaffolds.fasta SAMN08225147_scaffolds.fasta #Move scaffold file out and rename
rm -r SAMN08225147_Spades_Output
tar czvf SAMN08225147_scaffolds.fasta.tar.gz SAMN08225147_scaffolds.fasta
rm *.fastq
rm SAMN08225147_scaffolds.fasta
mv SAMN08225147_scaffolds.fasta.tar.gz ../
