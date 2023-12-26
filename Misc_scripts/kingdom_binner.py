import pandas as pd
import numpy as np
from Bio import SeqIO
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-a", "--accession", help="Full file path to kegg input files")

args = parser.parse_args()

#Read in Autometa file
auto_df = pd.read_csv(args.accession+'.taxonomy.tsv', sep = "\t", usecols=['contig','superkingdom'])
auto_df.superkingdom = auto_df.superkingdom.str.capitalize()
auto_df.columns = ['contig','Autometa_superkingdom']

#Read in CAT file
CAT_df = pd.read_csv(args.accession+'.official_names.txt', sep = "\t", usecols=['# contig','superkingdom'])
CAT_df['superkingdom'] = CAT_df['superkingdom'].str.replace(':.*', '', regex=True)
CAT_df.columns = ['contig','CAT_superkingdom']
CAT_df['CAT_superkingdom'] = CAT_df['CAT_superkingdom'].replace(np.nan,'Unclassified')
CAT_df['CAT_superkingdom'] = CAT_df['CAT_superkingdom'].str.replace('no support','Unclassified')

#Read in MMSeqs2 file
mmseqs_df = pd.read_csv(args.accession+'_mmseqs_taxonomy_final.txt', sep = "\t", header=None,usecols=[0,8])
mmseqs_df.columns = ['contig','MMSeqs_taxonomy']
mmseqs_df['MMSeqs_superkingdom'] = mmseqs_df['MMSeqs_taxonomy'].str.split(';').str[1]
mmseqs_df['MMSeqs_superkingdom'] = mmseqs_df['MMSeqs_superkingdom'].str.replace('d_', '')
mmseqs_df['MMSeqs_superkingdom'] = mmseqs_df['MMSeqs_superkingdom'].replace(np.nan,'Unclassified')
mmseqs_df = mmseqs_df.drop(['MMSeqs_taxonomy'],axis = 1) 
mask = mmseqs_df['MMSeqs_superkingdom'].str.contains("vir")
mmseqs_df.loc[mask, 'MMSeqs_superkingdom'] = "Viruses"

#Merge dataframes
CAT_auto_df = pd.merge(auto_df, CAT_df, on = 'contig',how = 'outer')
CAT_auto_df['Autometa_superkingdom'] = CAT_auto_df['Autometa_superkingdom'].replace(np.nan,'Unclassified')
final_df = pd.merge(CAT_auto_df, mmseqs_df, on = 'contig',how = 'outer')
final_df['MMSeqs_superkingdom'] = final_df['MMSeqs_superkingdom'].replace(np.nan,'Unclassified')

#Get majority vote
mostCommonVote=[]
for row in final_df[['Autometa_superkingdom', 'CAT_superkingdom','MMSeqs_superkingdom']].values:
    votes, values = np.unique(row, return_counts=True)
    if np.all(values<=1):
            mostCommonVote.append("Unclassified")
    else:
        mostCommonVote.append(votes[np.argmax(values)])

final_df['Final_classification'] = mostCommonVote

#Split into kingdom bins
kingdoms = ['Eukaryota', 'Unclassified', 'Bacteria', 'Archaea', 'Viruses']

def extract_kingdom_contigs(fasta_file, kingdom):
    contig_ids = final_df.loc[final_df['Final_classification'] == kingdom, 'contig'] # Get contig IDs for the specified kingdom
    contig_ids_set = set(contig_ids) # Create a set for faster membership checking
    output_file = f"{fasta_file.split('_')[0]}_{kingdom}.fasta"
    # Filter and write contigs directly based on membership in the set
    with open(output_file, "w") as output_handle:
        for record in SeqIO.parse(fasta_file, "fasta"):
            if record.id in contig_ids_set:
                SeqIO.write(record, output_handle, "fasta")

for kingdom in kingdoms:
    extract_kingdom_contigs(args.accession+'_scaffolds.fasta', kingdom)
