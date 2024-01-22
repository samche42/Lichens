#!/usr/bin/bash
#SBATCH --partition=
#SBATCH --job-name=bigslice
#SBATCH --time=4-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 8 # Tasks # try to increase task number and see any change
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=25gb # request memory, adjustable
#SBATCH --error=bigslice.%J.err
#SBATCH --output=bigslice.%J.out

source activate bigslice

bigslice -i path/to/Bigslice_input path/to/Bigslice_output

conda deactivate

