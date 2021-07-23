"""
Author: Justin Ho
Date: July 08 2021
Contains routine functions for analysis of patent data
"""

import numpy as np
import pandas as pd
import itertools
from scipy import spatial

"""
Takes a path to the file (in the format of the node2vec output)
and returns a np matrix
Input:
    path_to_fil - string of path to file
Output:
    np_data - nxd matrix with n inventors and d dimension of vector representation
"""
def convert_np(path_to_file):
    # Reading file that is compatible with node2vec output
    df = pd.read_csv(path_to_file, 
                     delimiter=" ", 
                     skiprows=1, 
                     header=None)
    
    # Sort values by the first column (int representation of the nodes)
    # This is so that the returned data is indexed
    df = df.sort_values(df.columns[0])
    
    # Drop index column
    df = df.drop(df.columns[0], axis=1)
    np_data = df.to_numpy()
    
    return np_data

"""
Given inventors 1 and 2, calculate the dot product of the inventors
Requires the coinventor_mapping dictionary and node embeddings
Return None if there are no inventors
Input: 
    coinventor_mapping - dictionary that maps inventor id to int
    node_emb - node2vec embeddings in np.ndarray represetation
    inventor1,2 - inventor id 
    measure - default with cosine
Ouput:
    sim - similarity score based on dot product
"""
def similarity_score(coinventor_mapping, node_emb, inventor1, inventor2, measure="cos"):
    # Check if both inventors are part of the dictionary
    keys = list(coinventor_mapping.keys())
    if inventor1 not in keys or inventor2 not in keys:
        return None
    
    # Obtain index of inventor
    emb1 = coinventor_mapping[inventor1]
    emb2 = coinventor_mapping[inventor2]
    
    # Dot product
    if measure == "cos":
        sim = 1 - spatial.distance.cosine(node_emb[emb1],node_emb[emb2])
    else:
        sim = node_emb[emb1].dot(node_emb[emb2])
    return sim

'''
Given inventors hops relations, returns the shortest distance required to
reach given nodes
Input: 
    inventor - starting node
    related_inventors - dataframe containing hop relationships with inventor
Outputs:
    shortest_path - dataframe relating the number of hops
'''
def related_inventors_sp(inventor,related_inventors):
    # transform to set to remove duplicate hops and count the length
    related_inventors["hops"] = related_inventors["hops"].apply(lambda x: len(set(x)))
    
    # init empty dataframe
    shortest_path = pd.DataFrame(columns = ['inventor', 'related', 'hops'])
    
    # for every inventor, get shortest path
    for i in related_inventors.related.unique():
        min_hops = 0 # self similarity
        if inventor != i: # exclude self
            min_hops = related_inventors[related_inventors.related == i]['hops'].min()
        
        new_row = {'inventor': inventor, 'related': i, 'hops': min_hops}
        shortest_path = shortest_path.append(new_row, ignore_index=True)
            
    return shortest_path

'''
Given citation tree, returns direct ancestor relationship
Input:
    citation_tree
Output:
    direct_ancestor - with similarity scores
'''
def get_direct_ancestor(citation_tree):
    # takes first element in list
    citation_tree['lineage'] = citation_tree['lineage'].apply(lambda x: x[0])
    citation_tree['similarity'] = citation_tree['similarity'].apply(lambda x: x[0])
    
    direct_ancestor = citation_tree[["id", "lineage", "similarity"]]
    
    return direct_ancestor

'''
Given direct ancestor and list of patent inventors, generate pairwise combination
of inventors between the two patents
Input:
    direct_ancestor
    inventor_tree
Output:
    direct_ancestor - with combination
'''
def interpatent_inventor_combination(direct_ancestor, inventor_tree):
    combination = []
    
    # Generate combination of inventors
    for index,row in direct_ancestor.iterrows():
        citing = inventor_tree[inventor_tree['patent'] == row.id]['inventor'].tolist()[0]
        cited = inventor_tree[inventor_tree['patent'] == row.lineage]['inventor'].tolist()[0]
        combination.append(itertools.combinations(citing + cited, 2))
        
    direct_ancestor['combination'] = combination
    
    return direct_ancestor
    