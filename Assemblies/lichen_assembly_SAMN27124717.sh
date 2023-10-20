#!/usr/bin/bash
#SBATCH --partition=
#SBATCH --job-name=SAMN27124717
#SBATCH --time=14-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks # try to increase task number and see any change
#SBATCH --cpus-per-task=25
#SBATCH --mem-per-cpu=1gb # request memory, adjustable
#SBATCH --error=special_cases.%J.err
#SBATCH --output=special_cases.%J.out
#SBATCH --mail-user=samche42@gmail.com
#SBATCH --mail-type=END,FAIL

cd Special_cases/SAMN27124717

#DOWNLOAD RAW DATA
echo "Starting download of SRR18971041"
source activate sra-tools
fastq-dump -I --split-files --outdir ./ SRR18971041
conda deactivate
echo "Finished download of SRR18971041"

source activate trimmomatic
trimmomatic PE -baseout SRR18971041.fastq \
SRR18971041_1.fastq SRR18971041_2.fastq \
ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 MINLEN:25
conda deactivate

#SPADES ASSEMBLY
echo "Starting assembly of $acc..."
spades.py -t 25 -m 500 \
--pe1-1 SRR18971041_1P.fastq --pe1-2 SRR18971041_2P.fastq \
--nanopore SRR18971040.fastq \
-o SAMN27124717_Spades_Output

mv SAMN27124717_Spades_Output/scaffolds.fasta SAMN27124717_scaffolds.fasta #Move scaffold file out and rename
rm -r SAMN27124717_Spades_Output
tar czvf SAMN27124717_scaffolds.fasta.tar.gz SAMN27124717_scaffolds.fasta
rm *.fastq
rm SAMN27124717_scaffolds.fasta
mv SAMN27124717_scaffolds.fasta.tar.gz ../
