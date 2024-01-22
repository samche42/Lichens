#Creates a folder for every GCF with two or more members and then moves gbk files into the appropriate folder

import pandas as pd
import os
import shutil

df = pd.read_csv("GCF_assignment.txt", sep="\t", header=0)

#Get list pf GCFs fol folder names
unique_values = df['GCF'].unique()

# Create folders for each GCF
for value in unique_values:
    os.makedirs(f"GCF_{value}", exist_ok=True)

# Move files to their assigned folders
for index, row in df.iterrows():
    filename = row['File']
    gcf_value = row['GCF']
    GCF_folder = f"GCF_{gcf_value}"
    shutil.move(filename, GCF_folder)
