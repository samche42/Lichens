#!/usr/bin/env python3

from Bio import SeqIO
import sys
import os

# Input and output file paths
input_file = sys.argv[1]
base_filename = os.path.splitext(input_file)[0]
output_file = f"{base_filename}_3000bp_removed.fasta"

# Minimum sequence length
min_length = 3000

# List to store sequences that meet the length criterion
filtered_sequences = []

# Open the input file and filter sequences
with open(input_file, "r") as input_handle:
    for record in SeqIO.parse(input_handle, "fasta"):
        if len(record.seq) >= min_length:
            filtered_sequences.append(record)

# Write the filtered sequences to the output file
with open(output_file, "w") as output_handle:
    SeqIO.write(filtered_sequences, output_handle, "fasta")
