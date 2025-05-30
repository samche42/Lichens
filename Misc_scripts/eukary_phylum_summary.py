#!/usr/bin/env python3
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

def get_phyla(accession,fasta_file,tax_file,scaffold_file):
    # Extract headers from the FASTA file using SeqIO
    fasta_headers = []
    scaffold_headers = []
    for record in SeqIO.parse(fasta_file, "fasta"):
        fasta_headers.append(record.id)
    for record in SeqIO.parse(scaffold_file, "fasta"):
        scaffold_headers.append(record.id)
    # Create a pandas DataFrame with the headers in a 'contig' column
    df = pd.DataFrame({'contig': fasta_headers})
    df['cov'] = df.contig.str.split('_', expand=True)[6]
    df['length'] = df.contig.str.split('_', expand=True)[4]
    df = df.astype({'cov':'float','length':'float'})

    scaffold_df = pd.DataFrame({'contig': scaffold_headers})
    scaffold_df['cov'] = scaffold_df.contig.str.split('_', expand=True)[6]
    scaffold_df['length'] = scaffold_df.contig.str.split('_', expand=True)[4]
    scaffold_df = scaffold_df.astype({'cov':'float','length':'float'})
    total_coverage = scaffold_df['cov'].sum()
    df['rel_cov'] = df['cov']/total_coverage*100
    filtered_scaffold_df = scaffold_df[scaffold_df['length'] >= 3000]
    total_coverage_over_3000 = filtered_scaffold_df['cov'].sum()
    df['rel_cov_over_3000'] = df['cov']/total_coverage_over_3000*100
    
    mmseqs_df = pd.read_csv(tax_file, sep = "\t", header=None,usecols=[0,8])
    mmseqs_df.columns = ['contig','MMSeqs_taxonomy']
    mmseqs_df['MMSeqs_kingdom'] = (mmseqs_df.MMSeqs_taxonomy.str.split('k_', expand=True)[1]).str.split(';',expand=True)[0]
    mmseqs_df['MMSeqs_phylum'] = (mmseqs_df.MMSeqs_taxonomy.str.split('p_', expand=True)[1]).str.split(';',expand=True)[0]
    mmseqs_df = mmseqs_df.drop(['MMSeqs_taxonomy'],axis = 1) 
    
    final_df = pd.merge(df,mmseqs_df, on = 'contig', how = 'inner')
    final_df = final_df.fillna('Unclassified')

    counts_df = final_df.groupby('MMSeqs_phylum').count().loc[:, ['contig']]
    counts_df = counts_df.reset_index()
    counts_df = counts_df.rename(columns = {'contig':accession})
    abundance_df = final_df.groupby('MMSeqs_phylum')['rel_cov'].sum()
    abundance_df = abundance_df.reset_index()
    abundance_df = abundance_df.rename(columns = {'rel_cov':accession})
    length_df = final_df.groupby('MMSeqs_phylum')['length'].sum()
    length_df = length_df.reset_index()
    length_df = length_df.rename(columns = {'length':accession})
    abundance_df2 = final_df.groupby('MMSeqs_phylum')['rel_cov_over_3000'].sum()
    abundance_df2 = abundance_df2.reset_index()
    abundance_df2 = abundance_df2.rename(columns = {'rel_cov_over_3000':accession})
    return counts_df, abundance_df, length_df, abundance_df2

final_count_df = pd.DataFrame(columns =['MMSeqs_phylum'])
final_abund_df = pd.DataFrame(columns =['MMSeqs_phylum'])
final_length_df = pd.DataFrame(columns =['MMSeqs_phylum'])
final_abund2_df = pd.DataFrame(columns =['MMSeqs_phylum'])

for acc in accessions:
    scaffold_file = acc+"_scaffolds.fasta"
    fasta_file = acc+"_Eukaryota_3000bp_removed.fasta"
    tax_file = acc+"_mmseqs_taxonomy_final.txt"
    if os.stat(fasta_file).st_size == 0: #If file is empty, merge in a column of zeros with as many rows as each final df currently has
        count = final_count_df.loc[:, ['MMSeqs_phylum']]
        rows_to_add_count = final_count_df.shape[0]
        count[acc] = [0]*rows_to_add_count
        abund = final_abund_df.loc[:, ['MMSeqs_phylum']]
        rows_to_add_abund = final_abund_df.shape[0]
        abund[acc] = [0]*rows_to_add_abund
        length = final_length_df.loc[:, ['MMSeqs_phylum']]
        rows_to_add_length = final_length_df.shape[0]
        length[acc] = [0]*rows_to_add_length
        abund2 = final_abund2_df.loc[:, ['MMSeqs_phylum']]
        rows_to_add_abund2 = final_abund2_df.shape[0]
        abund2[acc] = [0]*rows_to_add_abund2
    else:
        count,abund,length,abund2 = get_phyla(acc,fasta_file,tax_file,scaffold_file)
    final_count_df = pd.merge(final_count_df, count, on = 'MMSeqs_phylum', how = 'outer')
    final_abund_df = pd.merge(final_abund_df, abund, on = 'MMSeqs_phylum', how = 'outer')
    final_length_df = pd.merge(final_length_df, length, on = 'MMSeqs_phylum', how = 'outer')
    final_abund2_df = pd.merge(final_abund2_df, abund2, on = 'MMSeqs_phylum', how = 'outer')

final_count_df = final_count_df.fillna('0')
final_abund_df = final_abund_df.fillna('0')
final_length_df = final_length_df.fillna('0')
final_abund2_df = final_abund2_df.fillna('0')

final_count_df.to_csv("Eukary_phyla_counts.txt", sep='\t', index=False)
final_abund_df.to_csv("Eukary_phyla_abundances.txt", sep='\t', index=False)
final_length_df.to_csv("Eukary_phyla_lengths.txt", sep='\t', index=False)
final_abund2_df.to_csv("Eukary_phyla_abundances_over_3000bp.txt", sep='\t', index=False)
