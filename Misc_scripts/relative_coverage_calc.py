import pandas as pd
import os

#Set up empty results df
tax_df = pd.DataFrame()
tax_df = pd.DataFrame(columns = ['Sample', 'Contig','Superkingdom','Phylum','Class','Order','Family','Genus','Species','Contig_length','Relative_Length_corrected_coverage'])

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
    sub_df['Contig_coverage'] = sub_df.Contig.str.split('_', expand=True)[5]
    sub_df['Contig_length'] = sub_df['Contig_length'].astype(float)
    sub_df['Contig_coverage'] = sub_df['Contig_coverage'].astype(float)
    sub_df['Length_corrected_coverage'] = sub_df['Contig_coverage']/sub_df['Contig_length']
    total_sample_coverage = sub_df['Length_corrected_coverage'].sum()
    sub_df['Relative_Length_corrected_coverage'] = sub_df['Length_corrected_coverage']/total_sample_coverage*100
    sub_df = sub_df.drop(['Contig_coverage','Length_corrected_coverage'], axis=1)
    tax_df = pd.concat([tax_df, sub_df]) #Add data to final df

kingdom_coverage_summary = tax_df.groupby(['Sample', 'Superkingdom'])['Relative_Length_corrected_coverage'].sum().unstack(fill_value=0).reset_index()
kingdom_coverage_summary.to_csv('kingdom_coverage.txt', sep='\t', index=True) #Write out relative coverage per sample per kingdom

bacterial_df = tax_df.loc[tax_df['Superkingdom'] == 'Bacteria']
phyla = bacterial_df.groupby(['Sample','Phylum'])['Relative_Length_corrected_coverage'].sum().unstack(fill_value=0).reset_index()
phyla.to_csv('bacterial_phyla_coverage.txt', sep='\t', index=True)
