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

cursor.execute("select a.project_name, a.last_version_that_comment_was_found_name,  b.repository_directory, b.version_order,  a.comment_text, a.processed_comment_id, a.last_version_that_comment_was_found_lines  from technical_debt_summary a , file_directory_per_version b where a.last_version_that_comment_was_found_hash = b.version_hash and a.file_name =  b.file_name and a.version_removed_author like'%,%' order by 1,2")
results = cursor.fetchall()

total_files_to_process = len(results)
progress_counter = 0

for result in results:
    progress_counter = progress_counter + 1

    project_name                               = result[0]
    last_version_that_comment_was_found_name   = result[1]
    last_found_repository_directory            = result[2]
    last_found_version_order                   = str(result[3])
    comment_text                               = result[4]
    processed_comment_id                       = result[5]
    last_version_that_comment_was_found_lines  = result[6]
   
    blame_last_found_file_path = get_repository_directory(project_name) + last_found_version_order + "." + last_version_that_comment_was_found_name + "/src/" + last_found_repository_directory.replace('.java', '.txt')
    subprocess.call("subl " + blame_last_found_file_path , shell = True)
    print processed_comment_id
    print last_found_repository_directory
    print comment_text

    cursor.execute("select  a.version_removed_author, a.version_removed_commit_hash, a.version_removed_lines, b.version_order, a.version_removed_name, b.repository_directory from  technical_debt_summary a, file_directory_per_version b where a.version_removed_hash = b.version_hash and a.file_name =  b.file_name and b.matched_analyzed_file_directory != 'removed' and a.processed_comment_id =" +str(processed_comment_id))
    removed_version_results = cursor.fetchone()
    
    version_removed_author      = removed_version_results[0]
    version_removed_commit_hash = removed_version_results[1]
    version_removed_lines       = removed_version_results[2]
    version_removed_order       = str(removed_version_results[3])
    version_removed_name        = removed_version_results[4]
    version_removed_directory   = removed_version_results[5]

    # print version_removed_order
    # print version_removed_name
    # print version_removed_directory

    blame_removed_file_path = get_repository_directory(project_name) + version_removed_order + "." + version_removed_name + "/src/" + version_removed_directory.replace('.java', '.txt')
    subprocess.call("subl " + blame_removed_file_path , shell = True)
    print version_removed_author
    print version_removed_commit_hash
    print version_removed_lines
   

    new_removed_author = raw_input('New author:')
    new_removed_lines  = raw_input('New removed_lines:')
    new_removed_commit_hash = raw_input('New removed_commit_hash:')

    cursor.execute("update technical_debt_summary set version_removed_author = %s, version_removed_lines = %s , last_version_that_comment_was_found_lines = %s version_removed_commit_hash = %s where processed_comment_id = %s", (new_removed_author, new_removed_lines, new_removed_lines, new_removed_commit_hash, processed_comment_id))
    # connection.commit()

    print str(progress_counter) + ' out of :'+ str(total_files_to_process)