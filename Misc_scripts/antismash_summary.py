#Use python3 antismash_summary.py /path/to/gbk/files

#!/usr/bin/env python3
import sys
import os
import pandas as pd
from Bio import SeqIO
import linecache
import numpy as np

input_directory = sys.argv[1]
df = pd.DataFrame(columns=['Cluster','Spades_Node','Predicted BGC_start','Predicted BGC_end','BGC length','Contig edge?','Predicted BGC Types'])
gbk_files = [file for file in os.listdir(input_directory) if file.endswith(".gbk")]
for gbk in gbk_files:
        original_id = None
        orig_start = None
        orig_end = None
        contig_edge = None
        products = []
        base_name = os.path.splitext(os.path.basename(gbk))[0]
        original_id_line = linecache.getline(gbk, 12)
        original_id = str((original_id_line.strip('\n').split(' :: '))[1])
        orig_start_line = linecache.getline(gbk, 14)
        orig_start = int(str((orig_start_line.strip('\n').split(' :: '))[1]))
        orig_end_line = linecache.getline(gbk, 15)
        orig_end = int(str((orig_end_line.strip('\n').split(' :: '))[1]))
        BGC_length = orig_end - orig_start
        for record in SeqIO.parse(gbk, "genbank"):
            for feature in record.features:
                if feature.type == "cand_cluster":
                    qualifiers = feature.qualifiers
                    if "contig_edge" in qualifiers:
                        contig_edge = qualifiers["contig_edge"][0]
                    if "product" in qualifiers:
                        products.extend(qualifiers["product"])
        df = df.append({'Cluster':base_name,'Spades_Node':original_id, 'Predicted BGC_start':orig_start,'Predicted BGC_end':orig_end,'BGC length':BGC_length,'Contig edge?':contig_edge,'Predicted BGC Types':products}, ignore_index=True)

def remove_duplicates_and_sort(lst):
    seen = set()
    return sorted([x for x in lst if not (x in seen or seen.add(x))])

def create_final_column(row):
    bgc_types = row['Predicted BGC Types']
    if len(bgc_types) > 1:
        concatenated = '_'.join(bgc_types) + ' hybrid'
        return concatenated
    else:
        return bgc_types[0]

df['Sample'] = df.Spades_Node.str.split('_', expand=True)[0]
df['Predicted BGC Types'] = df['Predicted BGC Types'].apply(remove_duplicates_and_sort)
df['Predicted_BGC_Types_count'] = df['Predicted BGC Types'].apply(len)
df['BGC_type'] = df.apply(create_final_column, axis=1)

BGC_counts = df.groupby(['Sample','Contig edge?','BGC_type']).size().unstack(fill_value=0).reset_index()
BGC_counts = BGC_counts.rename_axis(None, axis=1)
sums = BGC_counts.drop(['Sample','Contig edge?'], axis=1).sum()
sorted_columns = sums.sort_values(ascending=False).index.tolist()
BGC_counts_reordered = BGC_counts[['Sample','Contig edge?'] + sorted_columns]

total_BGC_count = df.groupby(['BGC_type','Contig edge?',]).size().unstack(fill_value=0).reset_index()
total_BGC_count = total_BGC_count.rename_axis(None, axis=1)

df.to_csv(input_directory+'/antismash_summary_details.txt', sep="\t", index=False)
BGC_counts_reordered.to_csv(input_directory+'/BGC_counts_per_sample_per_contig_edge.txt', sep="\t", index=False)
total_BGC_count.to_csv(input_directory+'/total_BGC_count.txt', sep="\t", index=False)
