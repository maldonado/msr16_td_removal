import os
import sys
import psycopg2


##### CONFIGURATIONS 
connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

cursor.execute("select processed_comment_id, version_introduced_author, version_removed_author, version_introduced_commit_hash, version_removed_commit_hash from technical_debt_summary_temp")
results = cursor.fetchall()

for result in results:

    processed_comment_id               = result[0]

    if result[1] is not None:
        version_introduced_author      = result[1].strip()
    if result[2] is not None:
        version_removed_author         = result[2].strip()
    if result[3] is not None:
        version_introduced_commit_hash = result[3].strip()
    if result[4] is not None:
        version_removed_commit_hash    = result[4].strip()
    
    cursor.execute("update technical_debt_summary_temp set version_introduced_author=%s, version_introduced_commit_hash=%s, version_removed_author = %s , version_removed_commit_hash = %s where processed_comment_id = %s", (version_introduced_author, version_introduced_commit_hash, version_removed_author, version_removed_commit_hash, processed_comment_id))

connection.commit()
                