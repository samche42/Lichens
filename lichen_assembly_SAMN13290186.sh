#!/usr/bin/bash
#SBATCH --partition=
#SBATCH --job-name=SAMN13290186
#SBATCH --time=14-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks # try to increase task number and see any change
#SBATCH --cpus-per-task=25
#SBATCH --mem-per-cpu=20gb # request memory, adjustable
#SBATCH --error=special_cases.%J.err
#SBATCH --output=special_cases.%J.out
#SBATCH --mail-user=samche42@gmail.com
#SBATCH --mail-type=END,FAIL

cd Special_cases/SAMN13290186

#DOWNLOAD RAW DATA
echo "Starting download of SRR12527637"
source activate sra-tools
fastq-dump -I --split-files --outdir ./ SRR12527637
conda deactivate
echo "Finished download of SRR12527637"

source activate trimmomatic
trimmomatic PE -baseout SRR12527637.fastq \
SRR12527637_1.fastq SRR12527637_2.fastq \
ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 MINLEN:25
conda deactivate

#SPADES ASSEMBLY
echo "Starting assembly of $acc..."
spades.py -t 25 -m 500 \
--pe1-1 SRR12527637_1P.fastq --pe1-2 SRR12527637_2P.fastq \
--nanopore SAMN13290186.fastq \
-o SAMN13290186_Spades_Output

mv SAMN13290186_Spades_Output/scaffolds.fasta SAMN13290186_scaffolds.fasta #Move scaffold file out and rename
rm -r SAMN13290186_Spades_Output
tar czvf SAMN13290186_scaffolds.fasta.tar.gz SAMN13290186_scaffolds.fasta
rm *.fastq
rm SAMN13290186_scaffolds.fasta
mv SAMN13290186_scaffolds.fasta.tar.gz ../
