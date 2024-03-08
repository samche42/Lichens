#NB: Combine bacterial and eukaryotic RNA files into one per sample!!

#!/usr/bin/env python3
import pandas as pd
import os
from Bio import SeqIO

input_directory = "./"

RNA_files = [file for file in os.listdir(input_directory) if file.endswith("RNAs.fasta")]
for file in RNA_files:
    file_name = str(file).replace('_scaffolds_RNAs.fasta','')
    records_16S = []
    records_18S = []
    records_23S = []
    records_28S = []
    for r in SeqIO.parse(file, "fasta"):
            header_string = str(r.id)
            if "16S" in header_string:
                records_16S.append(r)
            if "18S" in header_string:
                records_18S.append(r)
            if "23S" in header_string:
                records_23S.append(r)
            if "28S" in header_string:
                records_28S.append(r)
    SeqIO.write(records_16S, file_name+"_16S.fasta", "fasta")
    SeqIO.write(records_18S, file_name+"_18S.fasta", "fasta")
    SeqIO.write(records_23S, file_name+"_23S.fasta", "fasta")
    SeqIO.write(records_28S, file_name+"_28S.fasta", "fasta")
