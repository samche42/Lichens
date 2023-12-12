#!/usr/bin/bash
#SBATCH --partition=
#SBATCH --job-name=kingdom_binner
#SBATCH --time=1-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks # try to increase task number and see any change
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10gb # request memory, adjustable
#SBATCH --error=binner.%J.err
#SBATCH --output=binner.%J.out

#Run with for accession in `cat accessions`;do sbatch kingdom_binning.sh -a ${accession};done

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

python3 kingdom_binner.py -a ${acc}
