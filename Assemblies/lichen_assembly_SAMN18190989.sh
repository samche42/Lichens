#!/usr/bin/bash
#SBATCH --partition=
#SBATCH --job-name=SAMN18190989
#SBATCH --time=14-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks # try to increase task number and see any change
#SBATCH --cpus-per-task=25
#SBATCH --mem-per-cpu=20gb # request memory, adjustable
#SBATCH --error=special_cases.%J.err
#SBATCH --output=special_cases.%J.out
#SBATCH --mail-user=samche42@gmail.com
#SBATCH --mail-type=END,FAIL

cd Special_cases/SAMN18190989

#DOWNLOAD RAW DATA
echo "Starting download of SRR14653145"
source activate sra-tools
fastq-dump -I --split-files --outdir ./ SRR14653145
conda deactivate
echo "Finished download of SRR14653145"

source activate trimmomatic
echo "Starting to trim..."
trimmomatic PE -baseout SRR14653145.fastq \
SRR14653145_1.fastq SRR14653145_2.fastq \
ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 MINLEN:25 && echo "Trimming successful"
conda deactivate

#SPADES ASSEMBLY
echo "Starting assembly of $acc..."
spades.py -t 25 -m 500 \
--pe1-1 SRR14653145_1P.fastq --pe1-2 SRR14653145_2P.fastq \
--nanopore SRR14653144.fastq \
-o SAMN18190989_Spades_Output

mv SAMN18190989_Spades_Output/scaffolds.fasta SAMN18190989_scaffolds.fasta #Move scaffold file out and rename
rm -r SAMN18190989_Spades_Output
tar czvf SAMN18190989_scaffolds.fasta.tar.gz SAMN18190989_scaffolds.fasta
rm *.fastq
rm SAMN18190989_scaffolds.fasta
mv SAMN18190989_scaffolds.fasta.tar.gz ../
