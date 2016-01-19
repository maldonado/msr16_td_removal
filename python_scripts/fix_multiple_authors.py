import os
import sys
import subprocess
import psycopg2

def get_repository_directory (project_name):
    switcher = {
        "jruby": "/Users/evermal/git/msr16_td_removal/datasets/blame_files/jruby_tags/",
        "apache-ant": "/Users/evermal/git/msr16_td_removal/datasets/blame_files/ant_tags/",
        "apache-jmeter": "/Users/evermal/git/msr16_td_removal/datasets/blame_files/jmeter_tags/",
    }
    return switcher.get(project_name)

connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

cursor.execute("select a.project_name, a.file_name, a.version_introduced_name, a.version_introduced_hash, b.repository_directory, b.version_order,  a.comment_text, a.processed_comment_id, a.comment_type, a.version_introduced_author, a.version_introduced_lines , a.version_introduced_commit_hash  from technical_debt_summary a , file_directory_per_version b where a.version_introduced_hash = b.version_hash and a.file_name =  b.file_name and a.version_introduced_author like'%,%' order by 1,2 limit 1")
results = cursor.fetchall()

total_files_to_process = len(results)
progress_counter = 0

for result in results:
    progress_counter = progress_counter + 1

    project_name              = result[0]
    file_name                 = result[1]
    version_introduced_name   = result[2]
    version_introduced_hash   = result[3]
    repository_directory      = result[4]
    version_order             = result[5]
    comment_text              = result[6]
    processed_comment_id      = result[7]
    comment_type              = result[8]
    version_introduced_author = result[9]
    version_introduced_lines  = result[10]
    version_introduced_commit_hash = result[11]
    
    blame_file_path = get_repository_directory(project_name) + version_order + "." + version_introduced_name + "/src/" + repository_directory.replace('.java', '.txt')
    subprocess.call("subl " + blame_file_path , shell = True)
    print version_introduced_author
    print version_introduced_commit_hash
    print version_introduced_lines
    print comment_text

    new_introduced_author = raw_input('New author:')
    new_introduced_lines  = raw_input('New introduced_lines:')
    new_introduced_commit_hash = raw_input('New introduced_commit_hash:')

    cursor.execute("update technical_debt_summary set version_introduced_author = %s, version_introduced_lines = %s , version_introduced_commit_hash = %s where processed_comment_id = %s", (new_introduced_author, new_introduced_lines, new_introduced_commit_hash, processed_comment_id))
    connection.commit()

    print str(progress_counter) + ' out of :'+ str(total_files_to_process)
    