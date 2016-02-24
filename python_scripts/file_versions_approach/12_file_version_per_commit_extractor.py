import os
import re
import sys
import subprocess
import shutil
import datetime
import psycopg2


def get_repository_directory (project_name):
    switcher = {
        "jruby": "/Users/evermal/git/jruby/",
        "apache-ant": "/Users/evermal/git/ant/",
        "apache-jmeter": "/Users/evermal/git/jmeter/",
    }
    return switcher.get(project_name)

file_version_per_commit_path = '/Users/evermal/git/msr16_td_removal/datasets/file_version_per_commit/'

##### CONFIGURATIONS 
connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

cursor.execute("select a.project_name, a.file_name, b.repository_directory , a.commit_hash, a.author_date from git_commit a, git_log_files b where a.file_directory = b.file_directory and a.file_checkout is false order by a.project_name, a.author_date")
results = cursor.fetchall()

total_files_to_process = len(results)
progress_counter = 0

for result in results:
    progress_counter = progress_counter + 1

    project_name         = result[0]
    file_name            = result[1]
    repository_directory = result[2]
    commit_hash          = result[3]

    git_checkout = "git checkout " + commit_hash
    copy_file = "cp " + repository_directory + " " + file_version_per_commit_path + project_name +"/"+ commit_hash + ".java"
    command = git_checkout +";"+ copy_file
        
    # print git_checkout
    # print copy_file
    # print command
    
    process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True, cwd=get_repository_directory(project_name))
    proc_stdout = process.communicate()[0].strip()

    cursor.execute("update git_commit set file_checkout = True where commit_hash = %s and project_name = %s", (commit_hash, project_name))
    connection.commit()

    print str(progress_counter) + ' out of :'+ str(total_files_to_process)