#Use python3 antismash_summary.py /path/to/gbk/files

#!/usr/bin/env python3
import sys
import os
import pandas as pd
from Bio import SeqIO
import linecache

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

df.to_csv(input_directory+'/antismash_summary.txt', sep="\t", index=False)
