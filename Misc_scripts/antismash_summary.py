#Use python3 antismash_summary.py /path/to/gbk/files

#!/usr/bin/env python3
import sys
import os
import pandas as pd
from Bio import SeqIO
import linecache
import numpy as np

input_directory = sys.argv[1]
df_list = []
df = pd.DataFrame(columns=['Cluster','Spades_Node','Predicted BGC_start','Predicted BGC_end','BGC length','Contig edge?','Predicted BGC Types'])
gbk_files = [file for file in os.listdir(input_directory) if file.endswith(".gbk")]
for gbk in gbk_files:
        original_id = None
        orig_start = None
        orig_end = None
        contig_edge = None
        products = []
        base_name = os.path.splitext(os.path.basename(gbk))[0]
        with open(gbk, 'rt') as f:
            data = f.readlines()[0:25] #read in first 25 lines of file
        for line in data:
            if 'Original ID' in line:
                original_id = str((line.strip('\n').split(' :: '))[1])
            elif 'Orig. start' in line:
               orig_start = int(str((line.strip('\n').split(' :: '))[1]))
            elif 'Orig. end' in line:
             orig_end = int(str((line.strip('\n').split(' :: '))[1]))
        BGC_length = orig_end - orig_start
        for record in SeqIO.parse(gbk, "genbank"):
            for feature in record.features:
                if feature.type == "cand_cluster":
                    qualifiers = feature.qualifiers
                    if "contig_edge" in qualifiers:
                        contig_edge = qualifiers["contig_edge"][0]
                    if "product" in qualifiers:
                        products.extend(qualifiers["product"])
        new_row = pd.DataFrame({'Cluster':base_name,'Spades_Node':original_id, 'Predicted BGC_start':orig_start,'Predicted BGC_end':orig_end,'BGC length':BGC_length,'Contig edge?':contig_edge,'Predicted BGC Types':products})
        df = pd.concat([df,new_row],ignore_index=True)

df.to_csv(input_directory+'/antismash_summary_details.txt', sep="\t", index=False)
