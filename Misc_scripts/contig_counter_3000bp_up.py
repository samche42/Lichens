#!/usr/bin/env python3
import os
import pandas as pd
import numpy as np
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input_directory", help="Input directory path")

args = parser.parse_args()

input_directory = args.input_directory
accessions = [(((os.path.splitext(file))[0]).split("_"))[0] for file in os.listdir(input_directory) if file.endswith("scaffolds.fasta")]

def get_final_df(accession):
    #Read in CAT file
    CAT_df = pd.read_csv(accession+'.official_names.txt', sep = "\t", usecols=['# contig','superkingdom'])
    CAT_df['superkingdom'] = CAT_df['superkingdom'].str.replace(':.*', '', regex=True)
    CAT_df.columns = ['contig','CAT_superkingdom']
    CAT_df['CAT_superkingdom'] = CAT_df['CAT_superkingdom'].replace(np.nan,'Unclassified')
    CAT_df['CAT_superkingdom'] = CAT_df['CAT_superkingdom'].str.replace('no support','Unclassified')

    #Read in MMSeqs2 file
    mmseqs_df = pd.read_csv(accession+'_mmseqs_taxonomy_final.txt', sep = "\t", header=None,usecols=[0,8])
    mmseqs_df.columns = ['contig','MMSeqs_taxonomy']
    mmseqs_df['MMSeqs_superkingdom'] = mmseqs_df['MMSeqs_taxonomy'].str.split(';').str[1]
    mmseqs_df['MMSeqs_superkingdom'] = mmseqs_df['MMSeqs_superkingdom'].str.replace('d_', '')
    mmseqs_df['MMSeqs_superkingdom'] = mmseqs_df['MMSeqs_superkingdom'].replace(np.nan,'Unclassified')
    mmseqs_df = mmseqs_df.drop(['MMSeqs_taxonomy'],axis = 1) 
    mask = mmseqs_df['MMSeqs_superkingdom'].str.contains("vir")
    mmseqs_df.loc[mask, 'MMSeqs_superkingdom'] = "Viruses"

    #Merge dataframes
    final_df = pd.merge(mmseqs_df, CAT_df, on = 'contig',how = 'outer')
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
    final_df['Coverage'] = final_df.contig.str.split('_', expand=True)[6]
    final_df['Length'] = final_df.contig.str.split('_', expand=True)[4]
    final_df = final_df.astype({'Coverage':'float','Length':'int'})
    final_df = final_df[final_df['length'] >= 3000]
    final_df['Length_corrected_coverage'] = final_df['Coverage']/final_df['Length']
    total_sample_coverage = final_df['Length_corrected_coverage'].sum()
    final_df['Relative_Length_corrected_coverage'] = final_df['Length_corrected_coverage']/total_sample_coverage*100
    final_df = final_df.drop(['Length_corrected_coverage','Coverage','CAT_superkingdom','MMSeqs_superkingdom'], axis=1)
    return final_df

list_of_counts = []
list_of_abundances = []
list_of_lengths = []
for acc in accessions:
    final_df = get_final_df(acc)
    value_counts_dict = final_df['Final_classification'].value_counts().to_dict()
    abundances_dict = final_df.groupby('Final_classification')['Relative_Length_corrected_coverage'].sum().to_dict()
    length_dict = final_df.groupby('Final_classification')['Length'].sum().to_dict()
    value_counts_dict['Accession'] = acc
    abundances_dict['Accession'] = acc
    length_dict['Accession'] = acc
    list_of_counts.append(value_counts_dict)
    list_of_abundances.append(abundances_dict)
    list_of_lengths.append(length_dict)

counts_df = pd.DataFrame(list_of_counts)
abundances_df = pd.DataFrame(list_of_abundances)
lengths_df = pd.DataFrame(list_of_lengths)

counts_df.to_csv("Superkingdom_contig_counts_3000bp_and_up.txt", sep='\t', index=False)
abundances_df.to_csv("Superkingdom_contig_abundances_3000bp_and_up.txt", sep='\t', index=False)
lengths_df.to_csv("Superkingdom_contig_lengths_3000bp_and_up.txt", sep='\t', index=False)
