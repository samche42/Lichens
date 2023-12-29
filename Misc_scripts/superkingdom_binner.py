import pandas as pd
import numpy as np
from Bio import SeqIO
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-a", "--accession", help="Full file path to kegg input files")

args = parser.parse_args()

#Read in CAT file
CAT_df = pd.read_csv("SRR13685122"+'.official_names.txt', sep = "\t", usecols=['# contig','superkingdom'])
CAT_df['superkingdom'] = CAT_df['superkingdom'].str.replace(':.*', '', regex=True)
CAT_df.columns = ['contig','CAT_superkingdom']
CAT_df['CAT_superkingdom'] = CAT_df['CAT_superkingdom'].replace(np.nan,'Unclassified')
CAT_df['CAT_superkingdom'] = CAT_df['CAT_superkingdom'].str.replace('no support','Unclassified')

#Read in MMSeqs2 file
mmseqs_df = pd.read_csv("SRR13685122"+'_mmseqs_taxonomy_final.txt', sep = "\t", header=None,usecols=[0,8])
mmseqs_df.columns = ['contig','MMSeqs_taxonomy']
mmseqs_df['MMSeqs_superkingdom'] = mmseqs_df['MMSeqs_taxonomy'].str.split(';').str[1]
mmseqs_df['MMSeqs_superkingdom'] = mmseqs_df['MMSeqs_superkingdom'].str.replace('d_', '')
mmseqs_df['MMSeqs_superkingdom'] = mmseqs_df['MMSeqs_superkingdom'].replace(np.nan,'Unclassified')
mmseqs_df = mmseqs_df.drop(['MMSeqs_taxonomy'],axis = 1) 
mask = mmseqs_df['MMSeqs_superkingdom'].str.contains("vir")
mmseqs_df.loc[mask, 'MMSeqs_superkingdom'] = "Viruses"

#Merge dataframes
final_df = pd.merge(mmseqs_df, CAT_df, on = 'contig',how = 'outer')
#final_df['MMSeqs_superkingdom'] = final_df['MMSeqs_superkingdom'].replace(np.nan,'Unclassified')
final_df = final_df.replace('Unclassified', np.nan)

#Get majority vote
mostCommonVote=[]
for row in final_df[['CAT_superkingdom','MMSeqs_superkingdom']].values:
    row = [i for i in row if i is not np.nan]
    votes, values = np.unique(row, return_counts=True)
    if len(values) == 0: #If they were both unclassified, assign "Unclassified" as the final decision
        mostCommonVote.append("Unclassified")
    elif len(values) == 1: #If only one tool managed to classify the contig, go with that assignment
        mostCommonVote.append(votes[0])
    elif np.all(values<=1): #If there's a split vote, assign "Unclassified"
        mostCommonVote.append("Unclassified")
    else:
        mostCommonVote.append(votes[np.argmax(values)])

final_df['Final_classification'] = mostCommonVote

#Split into kingdom bins
kingdoms = ['Eukaryota', 'Unclassified', 'Bacteria', 'Archaea', 'Viruses']

def extract_kingdom_contigs(fasta_file, kingdom):
    contigs = final_df[final_df['Final_classification'] == kingdom]['contig'].tolist()
    output_file = fasta_file.split("_")[0] + "_"+kingdom+".fasta"
    records = (r for r in SeqIO.parse(fasta_file, "fasta") if r.id in contigs)
    SeqIO.write(records, output_file, "fasta")

for kingdom in kingdoms:
    extract_kingdom_contigs(args.accession+'_scaffolds.fasta', kingdom)
