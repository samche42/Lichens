import os
import pandas as pd
import numpy as np
import argparse
from Bio import SeqIO

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input_directory", help="Input directory path")

args = parser.parse_args()

input_directory = args.input_directory
accessions = [(((os.path.splitext(file))[0]).split("_"))[0] for file in os.listdir(input_directory) if file.endswith("Eukaryota_3000bp_removed.fasta")]

def extract_kingdom_contigs(fasta_file, kingdom, function_df):
    contig_ids = function_df.loc[function_df['MMSeqs_kingdom'] == kingdom, 'contig'] # Get contig IDs for the specified kingdom
    contig_ids_set = set(contig_ids) # Create a set for faster membership checking
    output_file = f"{fasta_file.split('_')[0]}_eukary_{kingdom}.fasta" #Create output file name
    # Filter and write contigs directly based on membership in the set
    with open(output_file, "w") as output_handle:
        for record in SeqIO.parse(fasta_file, "fasta"):
            if record.id in contig_ids_set:
                SeqIO.write(record, output_handle, "fasta")

def get_kingdom(accession,fasta_file,tax_file):
    # Extract headers from the FASTA file using SeqIO
    fasta_headers = []
    for record in SeqIO.parse(fasta_file, "fasta"):
        fasta_headers.append(record.id)
    # Create a pandas DataFrame with the headers in a 'contig' column
    df = pd.DataFrame({'contig': fasta_headers})
    mmseqs_df = pd.read_csv(tax_file, sep = "\t", header=None,usecols=[0,8])
    mmseqs_df.columns = ['contig','MMSeqs_taxonomy']
    mmseqs_df['MMSeqs_kingdom'] = (mmseqs_df.MMSeqs_taxonomy.str.split('k_', expand=True)[1]).str.split(';',expand=True)[0]
    mmseqs_df = mmseqs_df.drop(['MMSeqs_taxonomy'],axis = 1) 
    final_df = pd.merge(df,mmseqs_df, on = 'contig', how = 'inner')
    final_df = final_df.fillna('Unclassified')
    kingdom_df = final_df .loc[:, ['contig', 'MMSeqs_kingdom']]
    kingdoms = ['Fungi','Viridiplantae','Unclassified','Metazoa']
    for kingdom in kingdoms:
        extract_kingdom_contigs(fasta_file, kingdom,kingdom_df)


for acc in accessions:
    fasta_file = acc+"_Eukaryota_3000bp_removed.fasta"
    tax_file = acc+"_mmseqs_taxonomy_final.txt"
    if os.stat(fasta_file).st_size == 0: #Skip if Eukary file is empty 
        continue 
    else:
        get_kingdom(acc,fasta_file,tax_file)
