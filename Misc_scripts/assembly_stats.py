#!/usr/bin/env python3
import sys
import os
import pandas as pd
from Bio import SeqIO
import gzip

input_directory = sys.argv[1]

stats_df = pd.DataFrame(columns=['Assembly','Size','#Contigs','#Contigs > 3000','N50','Longest_contig'])

assemblies = [file for file in os.listdir(input_directory) if file.endswith(".fasta")]

for file in assemblies:
    assembly_name = str(file).replace('.fasta','').split("_")[0] #Basically just the accession
    #Reset temp variables
    num_of_contigs = 0
    seq_length_list =[]
    sequence_total = 0
    assembly_size = 0
    seq_length_list = []
    sorted_list = []
    GC_total = 0
    weighted_cov = 0
    #Calculating variable values:
    num_of_contigs = len(list(SeqIO.parse(file, "fasta")))
    seq_length_list = [len(rec) for rec in SeqIO.parse(file, "fasta")]
    assembly_size = float(sum(seq_length_list))
    assembly_size_in_Mbp = assembly_size/1000000
    longest_contig = max(seq_length_list)
    #Finding N50
    contigs_sorted_by_length = sorted(seq_length_list, reverse = True)
    half_size  = assembly_size/2
    sorted_list = sorted(seq_length_list, reverse = True)
    for num in sorted_list:
        sequence_total += int(num)
        if sequence_total > half_size:
            n50 = num
            break
    greater_than_3000_count = sum(1 for value in seq_length_list if value > 3000)
    new_df_row = pd.DataFrame({'Assembly':[assembly_name],'Size':[assembly_size_in_Mbp],'#Contigs':[num_of_contigs],'#Contigs > 3000':[greater_than_3000_count],'N50':[n50],'Longest_contig':[longest_contig]})
    stats_df = pd.concat([stats_df,new_df_row],ignore_index=True)

stats_df.to_csv(input_directory+'/assembly_statistics.txt', sep='\t', index=False)
