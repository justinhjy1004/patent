'''
Author: Justin Ho
Date: 07/02/2021
This contains query functions between neo4j database and driver in Python
Contains both write and read transactions
'''
import neo4j
import pandas as pd

# Obtain all direct children (1 hop) given root patent
# Returns a pd.Dataframe
def direct_citation(tx, root):
    root = str(root)
    query_string = """
                MATCH (n:Patent)-[:CITED]->(c:Patent)
                WHERE c.id = $root 
                RETURN n.id AS id,
                n.date AS date,
                n.country AS country,
                n.num_claims AS claims,
                n.kind AS kind
               """
    response = tx.run(query_string, root=root)
    result_df = pd.DataFrame([dict(_) for _ in response])
    return result_df

# Build a citation tree based on a root with a default max depth of 3
# Returns a pd.Dataframe
def citation_tree(tx, root, max_depth=3):
    root = str(root)
    query_string = """
                    MATCH p=(n:Patent)-[:CITED*%s]->(c:Patent)
                    WHERE c.id = $root
                    MATCH (n:Patent)-[:ASSIGNED_TO]->(a:Assignee)
                    MATCH (n:Patent)-[:LOCATED_IN]->(l:Location)
                    MATCH (n:Patent)-[:INVENTED_BY]->(i:Inventor)
                    RETURN n.id AS id,
                    n.date AS date,
                    n.country AS country,
                    n.num_claims AS claims,
                    n.kind AS kind,
                    a.id AS assignee,
                    l.id AS location,
                    i.id AS inventor,
                    [rel in relationships(p) | endNode(rel).id] as lineage,
                    [rel in relationships(p) | rel.sim] as similarity,
                    [rel in relationships(p) | endNode(rel).subcategory] as nber_lineage
                   """
    range_hops = '1..' + str(max_depth)
    response = tx.run(query_string % range_hops, root=root)
    result_df = pd.DataFrame([dict(_) for _ in response])
    return result_df

# Obtain detailed information of a patent
def patent_info(tx, root):
    root = str(root)
    query_string = """
                    MATCH (c:Patent)-[:ASSIGNED_TO]->(a:Assignee)
                    MATCH (c:Patent)-[:LOCATED_IN]->(l:Location)
                    MATCH (c:Patent)-[:INVENTED_BY]->(i:Inventor)
                    WHERE c.id = $root
                    RETURN c.id AS id,
                    c.date AS date,
                    c.country AS country,
                    c.num_claims AS claims,
                    c.kind AS kind, 
                    l.county_fips AS county_fips,
                    l.city AS city,
                    l.state AS state,
                    a.organization AS organization,
                    a.type AS org_type,
                    i.id AS inventor_id,
                    i.attribution_stat AS attribution_stat
                   """
    response = tx.run(query_string, root=root)
    result_df = pd.DataFrame([dict(_) for _ in response])
    return result_df

# Creating coinventor relationship with a given citation tree
def relating_coinventors(tx, root, max_depth=3):
    root = str(root)
    query_string = """
                    MATCH r=(n:Patent)-[:CITED*%s]->(c:Patent)
                    WHERE c.id = $root
                    MATCH (i1:Inventor)<-[:INVENTED_BY]-(n)-[:INVENTED_BY]->(i2:Inventor)
                    MERGE (i1)-[:CO_INVENTOR]-(i2)
                   """
    range_hops = '1..' + str(max_depth)
    tx.run(query_string % range_hops, root=root)

# Querying for coinventors in a given citation tree
def coinventors(tx,root,max_depth=3):
    root = str(root)
    query_string = """
                    MATCH (n:Patent)-[:CITED*%s]->(c:Patent)
                    WHERE c.id = $root
                    MATCH (i1:Inventor)<-[:INVENTED_BY]-(n)-[:INVENTED_BY]->(i2:Inventor)
                    RETURN i1.id AS inventor1,
                    i2.id AS inventor2
                   """
    range_hops = '1..' + str(max_depth)
    response = tx.run(query_string % range_hops, root=root)
    result_df = pd.DataFrame([dict(_) for _ in response])
    return result_df

# Query related inventors with max_hop
def related_inventors(tx,inventor,max_depth=3):
    inventor = str(inventor)
    query_string = """
                    MATCH r=(i:Inventor)-[:CO_INVENTOR*%s]-(j:Inventor)
                    WHERE i.id = $inventor
                    RETURN i.id as inventor,
                    j.id as related,
                    [rel in relationships(r) | endNode(rel).id] as hops
                   """
    range_hops = '1..' + str(max_depth)
    response = tx.run(query_string % range_hops, inventor=inventor)
    result_df = pd.DataFrame([dict(_) for _ in response])
    return result_df

# Given root of the tree, retrieve the inventors of each
def inventor_tree(tx,root,max_depth=3):
    root = str(root)
    
    # Descendents of root node
    query_string = """
                    MATCH r=(n:Patent)-[:CITED*%s]->(c:Patent)
                    WHERE c.id = $root
                    MATCH (n)-[:INVENTED_BY]->(i:Inventor)
                    RETURN n.id AS patent,
                    i.id AS inventor
                   """
    range_hops = "1.." + str(max_depth)
    response= tx.run(query_string % range_hops, root=root)
    result_df = pd.DataFrame([dict(_) for _ in response])
    
    # Root node itself
    root_string = """
                    MATCH (c:Patent)
                    WHERE c.id = $root
                    MATCH (c)-[:INVENTED_BY]->(i:Inventor)
                    RETURN c.id AS patent,
                    i.id AS inventor
                   """
    response= tx.run(root_string, root=root)
    root_df = pd.DataFrame([dict(_) for _ in response])
    
    # Concatenating Data
    frames = [result_df, root_df]
    result_df = pd.concat(frames)
    
    
    # Changing into list format
    result_df = result_df.groupby("patent").agg({"inventor": lambda x: (','.join(x)).split(",")}).reset_index()
    
    # Remove Duplicates
    result_df["inventor"] = result_df["inventor"].apply(lambda x: list(set(x)))
    
    return result_df

# Returns NBER category, subcategory and lineage given root and max depth 
def nber_category(tx,root,max_depth=3):
    root = str(root)
    
    query_string = """
                    MATCH p=(n:Patent)-[:CITED*%s]->(c:Patent)
                    WHERE c.id = $root 
                    RETURN n.id AS id,
                    n.subcategory AS nber,
                    [rel in relationships(p) | endNode(rel).id] as lineage,
                    [rel in relationships(p) | endNode(rel).subcategory] as nber_lineage
                   """
    range_hops = "1.." + str(max_depth)
    response= tx.run(query_string % range_hops, root=root)
    result_df = pd.DataFrame([dict(_) for _ in response])
    
    return result_df

# Returns geocoordinates of patent origin
def geo_coordinate(tx,root,max_depth=3):
    root = str(root)
    
    query_string = """
                    MATCH p=(n:Patent)-[:CITED*%s]->(c:Patent)
                    WHERE  c.id = $root
                    MATCH (n)-[:LOCATED_IN]->(l:Location)
                    RETURN n.id AS id,
                    l.latitude AS latitude,
                    l.longitude AS longitude,
                    l.country AS country,
                    [r in relationships(p) | endnode(r).id] as lineage
                    """
    range_hops = "1.." + str(max_depth)
    response = tx.run(query_string % range_hops, root=root)
    result_df = pd.DataFrame([dict(_) for _ in response])
    
    root_query = """
                  MATCH (c:Patent)
                  WHERE c.id = $root
                  MATCH (c)-[:LOCATED_IN]->(l:Location)
                  RETURN l.latitude AS latitude,
                  l.longitude AS longitude,
                  l.country AS country
                 """
    response = tx.run(root_query, root=root)
    response = pd.DataFrame([dict(_) for _ in response])
    print(response)
    result_df = result_df.append({'id': root, 
                                  'latitude':response.loc[0,'latitude'],
                                  'longitude':response.loc[0,'longitude'],
                                  'country': response.loc[0,'country'],
                                  'lineage': [None]}, ignore_index=True)
    
    return result_df
