import neo4j
from patent_neo4j.queries import direct_citation
from patent_neo4j.queries import citation_tree
from patent_neo4j.queries import patent_info
from patent_neo4j.queries import relating_coinventors
from patent_neo4j.queries import coinventors
from patent_neo4j.queries import related_inventors
from patent_neo4j.queries import inventor_tree

"""
Neo4j Connection for Patent Graph Data
Contains functions to work with the dataset
Implementation of Algorithm is done in patent_neo4j/queries.py
INITIALIZE: 
        1. uri (i.e. "neo4j://localhost:7687")
        2. user 
        3. pwd (password)
"""
class Neo4jConnection:
    def __init__(self, uri, user, pwd):
        self.uri = uri
        self.user = user
        self.pwd = pwd
        self.driver = neo4j.GraphDatabase.driver(uri, auth=(user,pwd))
        
    # Close driver
    def close(self):
        if self.driver is not None:
            self.driver.close()
    
    # Obtain Direct Descendants of node given root
    def query_direct_citation(self, root, direct_citation=direct_citation):
        with self.driver.session() as session:
            result = session.read_transaction(direct_citation, root)
        return result
    
    # Obtain citation given root, initialized with depth of 3
    def query_citation_tree(self, root, citation_tree=citation_tree, max_depth=3):
        with self.driver.session() as session:
            result = session.read_transaction(citation_tree, root, max_depth)
        return(result)
        return df    
    
    # Obtain Direct Information from Single Patent
    def query_patent_info(self, root, patent_info=patent_info):
        with self.driver.session() as session:
            result = session.read_transaction(patent_info, root)
        return result
    
    # Construct citation tree and relates co-inventors
    def write_relating_coinventors(self, root, relating_coinventors=relating_coinventors, max_depth=3):
        with self.driver.session() as session:
            result = session.write_transaction(relating_coinventors, root, max_depth)
        return result
    
    # Query for coinventors relationship from a citation tree
    def query_coinventors(self, root, coinventors=coinventors, max_depth=3):
        with self.driver.session() as session:
            result = session.read_transaction(coinventors, root, max_depth)
        return result
    
    def query_related_inventors(self, inventors, related_inventors=related_inventors, max_depth=3):
        with self.driver.session() as session:
            result = session.read_transaction(related_inventors, inventors, max_depth)
        return result
    
    def query_inventor_tree(self, root, inventor_tree=inventor_tree, max_depth=3):
        with self.driver.session() as session:
            result = session.read_transaction(inventor_tree, root,  max_depth)
        return result