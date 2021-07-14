import pandas as pd
"""
Takes a dataframe that contains a list that traces lineage and converts to
direct descendent alongside with similarity
Inputs: 
    df - pandas dataframe containing the data containing columns in cols
    cols - columns to apply function on
"""
def convert_lineage(df, cols = ["lineage", "similarity"]):
    for col in cols:
        df[col] = df[col].apply(lambda x: x[0])
        
    return df

"""
Tracks the 'generation' as defined by the length of lineage
This means that generations can overlap
Inputs:
    df - pandas dataframe that has the column lineage in list form
"""
def trace_generation(df):
    df["generation"] = df["lineage"].apply(lambda x: len(x))
    return df

"""
Takes coinventor edge list and convert to integer mappings
Saves file such that it is applicable to node2vec implementation
Inputs:
    coinventors - pd.Df that contains coinventor edgelist
    
Output:
    coinventors - mapped EdgeList to integer
    coinventor_map - mapping for inventor id to integers
    
Optional:
    Set write == True, then writes a space separated file that is compatible 
"""
def inventor_to_int(coinventors, write=False, file="file.csv"):
    # Combines two rows of the edge list
    coinventor_list = coinventors['coinventor1'].tolist() + coinventors['coinventor2'].tolist()
    # Remove Duplicates
    coinventor_list = set(coinventor_list)
    # Converts to list for indexing
    coinventor_list = list(coinventor_list)
    
    # Create dict that maps to int
    coinventor_map = {}
    for i in range(0,len(coinventor_list)):
        coinventor_map[coinventor_list[i]] = i
    
    # Maps id to int
    for index,row in coinventors.iterrows():
        row.coinventor1 = coinventor_map[row.coinventor1]
        row.coinventor2 = coinventor_map[row.coinventor2]  
    
    # OPTIONAL: writes to compatible format
    if write:
        coinventors.to_csv(file, header=False, index=False, sep=' ')
    
    output = (coinventors, coinventor_map)
        
    return output


    