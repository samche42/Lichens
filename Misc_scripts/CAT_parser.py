#!/usr/bin/env python3
import pandas as pd
import os

#Set up empty results df
tax_df = pd.DataFrame()
tax_df = pd.DataFrame(columns = ['Sample', 'Contig','Superkingdom','Phylum','Class','Order','Family','Genus','Species','Contig_length'])

tax_files = [file for file in os.listdir("./") if file.endswith("official_names.txt")]
for file in tax_files:
    filename = file.split(".")[0] #Get accession from file name
    tmp_df = pd.DataFrame()
    tmp_df = pd.read_csv(file,sep='\t',header=0) #Read file into dataframe
    tmp_df['Sample'] = filename #Add accession to new column
    for col in ['superkingdom','phylum','class','order','family','genus','species']: #Remobe scres after classifcations
        tmp_df[col] = tmp_df[col].str.replace(':.*', '', regex=True)
    sub_df = pd.DataFrame()
    sub_df = tmp_df.loc[:, ['Sample','# contig','superkingdom','phylum','class','order','family','genus','species']] #Subset out necessary columns
    sub_df.columns = ['Sample', 'Contig','Superkingdom','Phylum','Class','Order','Family','Genus','Species'] #Rename columns
    sub_df['Contig_length'] = sub_df.Contig.str.split('_', expand=True)[3] #Create new colum with contig lengths based on contig names
    tax_df = pd.concat([tax_df, sub_df]) #Add data to final df

tax_df.reset_index(inplace=True)
tax_df = tax_df.drop(['index'], axis=1)
tax_df = tax_df.fillna('unknown')

tax_summary = tax_df.groupby('Sample')['Superkingdom'].value_counts(dropna=False).unstack(fill_value=0).reset_index()
tax_summary["Unknown"] = tax_summary["unknown"] + tax_summary["no support"]
tax_summary.drop(['unknown','no support'], axis=1, inplace=True)

tax_df['Contig_length'] = tax_df['Contig_length'].astype(int)
kingdom_length_summary = tax_df.groupby(['Sample', 'Superkingdom'])['Contig_length'].sum().unstack(fill_value=0).reset_index()
kingdom_length_summary["Unknown"] = kingdom_length_summary["unknown"] + kingdom_length_summary["no support"]
kingdom_length_summary.drop(['unknown','no support'], axis=1, inplace=True)

tax_df.to_csv('contig_taxonomy.txt', sep='\t', index=False)
tax_summary.to_csv('kingdom_count.txt', sep='\t', index=False)
kingdom_length_summary.to_csv('kingdom_length.txt', sep='\t', index=False)
