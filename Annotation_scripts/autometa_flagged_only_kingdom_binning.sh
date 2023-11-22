#!/usr/bin/bash
#SBATCH --partition=norm
#SBATCH --job-name=autometa
#SBATCH --time=14-00:00:00
#SBATCH -N 1 # Nodes
#SBATCH -n 1 # Tasks # try to increase task number and see any change
#SBATCH --cpus-per-task=12
#SBATCH --mem-per-cpu=2gb # request memory, adjustable
#SBATCH --error=/home/simonsonsc/Slurm_scripts/log_files/autometa.%J.err
#SBATCH --output=/home/simonsonsc/Slurm_scripts/log_files/autometa.%J.out
#SBATCH --mail-user=samche42@gmail.com
#SBATCH --mail-type=END,FAIL

cd /mnt/projects/abcs-dssb/mtp/slurm/simonsonsc/Lichen_project/Acceptable_assemblies/Trial_folder

source /mnt/nasapps/development/python/miniconda3/3.10/bin/activate autometa

usage()
{
   # Display Help
   echo "-h     Display help menu"
   echo
   echo "Required flags:"
   echo "-o     Directory path to where the output will go"
   echo "-a     Full path to where your scaffold/contig file is (include file name)"
   echo "-s     Simple name to prefix output files"
   echo "-n     Path to NCBI databases"
   echo "-m     Path to marker files"
   echo "-l     Contig length cutoff in bp. Change this according to the N50 you got from running metaQuast"
   echo "-v     Options are 'spades' or 'other'. If you assembled your metagenome with spades, choose teh spades option. If you used a different assembler, please use the 'other' option for the coverage calculation."
   echo "-f     Forward reads. Required only if metagenome not assembled with Spades"
   echo "-r     Reverse reads. Required only if metagenome not assembled with Spades"
   echo "-c     How many cpus you would like to use"
}

#Define flags
while getopts "o:a:s:n:m:l:v:f:r:c:h" flag
do
    case "${flag}" in
        o) out_dir=${OPTARG};;
        a) assembly=${OPTARG};;
        s) simple_name=${OPTARG};;
        n) ncbi=${OPTARG};;
        m) marker_db=${OPTARG};;
        l) length_cutoff=${OPTARG};;
        v) coverage=${OPTARG};;
        f) fwd_reads=${OPTARG};;
        r) rev_reads=${OPTARG};;
        c) cpus=${OPTARG};;
        h) usage exit;;
    esac
done

if [ "$#" -eq 0 ]
then
    echo "No arguments provided"
    echo
    usage >&2
    exit 1
fi

echo 
echo "Your current conda environment is: " $CONDA_DEFAULT_ENV

if [[ "$CONDA_DEFAULT_ENV"  == *"utometa"* ]]
then
    echo "Your conda environment is correct. Continuing..."
else
    echo "The correct conda environment is not activated. Please activate the autometa conda environment by running 'conda activate autometa'"
    exit
fi

echo
echo "You have provided the following input parameters:"
echo "Output directory: " $out_dir
echo "Scaffolds file: " $assembly
echo "File prefix: " $simple_name
echo "Contig length cutoff: " $length_cutoff
echo "Coverage calc option: " $coverage
echo "CPUS to be used: " $cpus
echo "Path to NCBI files: " $ncbi
echo "Path to marker files: " $marker_db
echo

#Check that required flags are provided
if [ -z $out_dir ]; then
    echo "Output directory not provided"
    exit 1
fi

if [ -z $assembly ]; then
    echo "Scaffold file not provided"
    exit 1
fi

if [ -z $simple_name ]; then
    echo "File prefix not provided"
    exit 1
fi

if [ -z $ncbi ]; then
    echo "Path to ncbi database not provided"
    exit 1
fi

if [ -z $marker_db ]; then
    echo "Path to marker database not provided"
    exit 1
fi

if [ -z $length_cutoff ]; then
    echo "Contig length cutoff not provided"
    exit 1
fi

if [ -z $coverage ]; then
    echo "Method for coverage calc not provided"
    exit 1
fi

if [ -z $cpus ]; then
    echo "Number of CPUs to be used not provided"
    exit 1
fi

#Check that provided files exist
echo "Checking that provided files exist..."
if [ -d "$out_dir" ]; then
        echo "$out_dir found."
else 
        echo "$out_dir does not exist."
        exit
fi

if [ -f "$assembly" ]; then
        echo "$assembly found."
else 
        echo "$assembly does not exist."
        exit
fi

if [ -d "$ncbi" ]; then
        echo "$ncbi found."
else 
        echo "$ncbi does not exist."
        exit
fi

#Check if ncbi files are present, if not, download and prep them
if [ -f "$ncbi/nr.dmnd" ]; then
    echo "NCBI files are present where specified, moving on..."
else
    echo "NCBI files not found where specified. Please run autometa-update-databases --update-ncbi to download"
    exit
fi

if [ -d "$marker_db" ]; then
        echo "$marker_db found."
else 
        echo "$marker_db does not exist."
        exit
fi

#Create output folder
outdir="${out_dir}/${simple_name}_Autometa_Output"
if [ ! -d $outdir ]
then mkdir -p $outdir
fi

# Default Autometa Parameters - If you don't know what you're doing, leave these alone!!
kmer_size=5
norm_method="am_clr" # choices: am_clr, clr, ilr
pca_dimensions=50 # NOTE: must be greater than $embed_dimensions
embed_dimensions=2 # NOTE: must be less than $pca_dimensions
embed_method="bhsne" # choices: bhsne, sksne, umap, densne, trimap
cluster_method="hdbscan" # choices: hdbscan, dbscan
completeness=20.0
purity=95.0
cov_stddev_limit=25.0
gc_stddev_limit=5.0
seed=42

# Report autometa version
echo
autometa --version

#Step 1: Filter assembly by length and retrieve contig lengths as well as GC content

filtered_assembly="${outdir}/${simple_name}.filtered.fna"
gc_content="${outdir}/${simple_name}.gc_content.tsv"

autometa-length-filter \
    --assembly $assembly \
    --cutoff $length_cutoff \
    --output-fasta $filtered_assembly \
    --output-gc-content $gc_content

#Step 2: Determine coverages from assembly read alignments
coverages="${outdir}/${simple_name}.coverages.tsv"

if [[ "$coverage" == "spades" ]]
then
    echo
    echo "Coverage to be taken from Spades headers"
    autometa-coverage --assembly $filtered_assembly --from-spades --out $coverages
else
    if [[ "$coverage" == "other" ]]
    then
        echo
        echo "Coverage to be calculated from reads"
        if [ -z $fwd_reads ]; then
            echo "Forward reads were not provided. These are required for coverage calculations"
            exit 1
        fi

        if [ -f "$fwd_reads" ]; then
            echo "$fwd_reads found."
        else 
            echo "$fwd_reads does not exist."
            exit
        fi

        if [ -z $rev_reads ]; then
            echo "Reverse reads were not provided. These are required for coverage calculations"
            exit 1
        fi

        if [ -f "$rev_reads" ]; then
            echo "$rev_reads found."
        else 
            echo "$rev_reads does not exist."
            exit
        fi

        autometa-coverage --assembly $filtered_assembly --fwd-reads $fwd_reads --rev-reads $rev_reads --out $coverages --cpus $cpus

    else
        echo
        echo "You have provided an invalid option. The options for coverage are 'spades' or 'other'. Please fix">&2; exit 1
    fi
fi

# Step 3: Annotate and filter markers

orfs="${outdir}/${simple_name}.orfs.faa"
orfs_nuc="${outdir}/${simple_name}.orfs.fna"

#Get ORFs
autometa-orfs \
    --assembly $filtered_assembly \
    --output-nucls $orfs_nuc \
    --output-prots $orfs \
    --cpus $cpus

if [ $? -eq 0 ]; then
   echo "ORFs successfully generated"
else
   echo "ORF generation failed"
fi

#Check if marker files are pressed, if not, press them
echo
echo "Checking if hmm files are pressed..."
if [ -f "$marker_db/bacteria.single_copy.hmm.h3i" ]; then
    echo "Bacterial hmm files are pressed, moving on..."
else
    echo "Bacterial hmm files not pressed. Pressing files now..."
    hmmpress -f $marker_db/bacteria.single_copy.hmm
fi


if [ -f "$marker_db/archaea.single_copy.hmm.h3i" ]; then
    echo "Archaeal hmm files are pressed, moving on..."
else
    echo "Archaeal hmm files not pressed. Pressing files now..."
    hmmpress -f $marker_db/archaea.single_copy.hmm
fi

kingdoms=(bacteria archaea)

# NOTE: We iterate through both sets of markers for binning both bacterial and archeal kingdoms
for kingdom in ${kingdoms[@]};do
    # kingdom-specific output:
    hmmscan="${outdir}/${simple_name}.${kingdom}.hmmscan.tsv"
    markers="${outdir}/${simple_name}.${kingdom}.markers.tsv"

    # script:
    autometa-markers \
        --orfs $orfs \
        --hmmscan $hmmscan \
        --dbdir $marker_db \
        --out $markers \
        --kingdom $kingdom \
        --parallel \
        --cpus $cpus \
        --seed $seed && echo "autometa-markers completed successfully for ${kingdom}"
done

# Step 4.1: Determine ORF lowest common ancestor (LCA) amongst top hits

#Run blastp
blast="${outdir}/${simple_name}.blastp.tsv" #Generate output file name

diamond blastp \
    --query $orfs \
    --db "$ncbi/nr.dmnd" \
    --evalue 1e-5 \
    --max-target-seqs 200 \
    --threads $cpus \
    --outfmt 6 \
    --out $blast && echo "diamond blastp completed successfully"

# output:
lca="${outdir}/${simple_name}.orfs.lca.tsv"
sseqid2taxid="${outdir}/${simple_name}.orfs.sseqid2taxid.tsv"
error_taxids="${outdir}/${simple_name}.orfs.errortaxids.tsv"

# script:
autometa-taxonomy-lca \
    --blast $blast \
    --dbdir $ncbi \
    --lca-output $lca \
    --sseqid2taxid-output $sseqid2taxid \
    --lca-error-taxids $error_taxids && echo "autometa-taxonomy-lca completed successfully"

# Step 4.2: Perform Modified Majority vote of ORF LCAs for all contigs that returned hits in blast search

votes="${outdir}/${simple_name}.taxids.tsv"

autometa-taxonomy-majority-vote \
    --lca $lca \
    --output $votes \
    --dbdir $ncbi && echo "autometa-majority-votes completed successfully"

# Step 4.3: Split assigned taxonomies into kingdoms

autometa-taxonomy \
    --votes $votes \
    --output $outdir \
    --prefix $simple_name \
    --split-rank-and-write superkingdom \
    --assembly $filtered_assembly \
    --dbtype ncbi \
    --dbdir $ncbi && echo "autometa-taxonomy completed successfully"

conda deactivate
