from rdkit import Chem
from rdkit.Chem import AllChem
from rdkit.Chem import PandasTools
from rdkit import DataStructs
from itertools import combinations
import numpy as np
import pandas as pd
import json
import os

#Stop RDKit logging (just excessive really and slows everything down)
def disable_rdkit_logging():
    import rdkit.rdBase as rkrb
    import rdkit.RDLogger as rkl
    logger = rkl.logger()
    logger.setLevel(rkl.ERROR)
    rkrb.DisableLog('rdApp.error')
    
disable_rdkit_logging()

#Import MiBIG compounds

json_files = [file for file in os.listdir("./") if file.endswith(".json")]

list_of_dicts = []

for json_file in json_files:
    with open(json_file, 'r') as file:
        count = 0
        data = json.load(file)
        mibig_accession = data['cluster']['mibig_accession']
        for compound in data['cluster']['compounds']:
            compound_name = compound['compound']
            cmpd_id = mibig_accession+"_"+compound_name
            compound_info = {
            'ID':cmpd_id,
            'SMILES': compound.get('chem_struct', 'Not available'),
        }
            list_of_dicts.append(compound_info)
            
mibig_df = pd.DataFrame(list_of_dicts)
mibig_df = mibig_df[~mibig_df.SMILES.str.contains("Not available")] #Remobe any rows where SMILE is not available


#Import Lichendex compounds
lichendex_df = pd.read_csv("Sam_subset.txt",sep='\t',header=0, usecols=['ID', 'Structure'])
lichendex_df.columns = ['ID','SMILES']
lichendex_df = lichendex_df.dropna() 

final_df = pd.concat([mibig_df, lichendex_df])

#Create dictionary of mols
smiles_fp_dict = {}
for cmpd,smile in zip(final_df.ID, final_df.SMILES):
    mol = Chem.MolFromSmiles(smile)
    if mol is not None:
        fp = AllChem.GetMorganFingerprintAsBitVect(mol, 2, nBits=2048, useFeatures=True)
        smiles_fp_dict[cmpd] = fp
    else:
        print(str(cmpd)+" is not a valid SMILE. Not including in analysis")

#piarwise comparison of all vs all
def PairwiseComparison(fp1, fp2, cmpd1,cmpd2):
	similarity_score = DataStructs.FingerprintSimilarity(fp1, fp2)
	if similarity_score >= 0.7:
		new_row = {'Compound_1': cmpd1, 'Compound_2': cmpd2, 'Similarity_score': similarity_score}
		return new_row
	else:
		pass

pairwise_sim_df = pd.DataFrame(columns=['Compound_1', 'Compound_2', 'Similarity_score'])
fp_combinations = combinations(smiles_fp_dict, 2)

for cmpd1,cmpd2 in fp_combinations:
	new_row = PairwiseComparison(smiles_fp_dict[cmpd1],smiles_fp_dict[cmpd2],cmpd1,cmpd2)
	if new_row is None:
		pass 
	else:
		pairwise_sim_df = pd.concat([pairwise_sim_df, pd.DataFrame.from_records([new_row])])

pairwise_sim_df.to_csv('Pairwise_similarity.tab', sep='\t', index=False)

