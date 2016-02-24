import os
import re
import sys
import subprocess
import shutil
import datetime
import psycopg2

##### CONFIGURATIONS 
connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

git_log_file_regex  = 'commit\s([a-z0-9]{40})\n|Author:\s(.*?)\<(.*?)\>|Date:\s*([A-Za-z]{3}\s[A-Za-z]{3}\s\d{1,2}\s\d{2}:\d{2}:\d{2}\s\d{4}\s.\d{3,4})'

cursor.execute("select project_name, file_name, file_directory from git_log_files where file_name not in (select distinct(file_name) from  git_commit) order by 1, 2 ")
results = cursor.fetchall()

total_files_to_process = len(results)
progress_counter = 0

for result in results:
    progress_counter = progress_counter + 1

    project_name   = result[0]
    file_name      = result[1]
    file_directory = result[2]
    
    commit_hash    = ''
    author_name    = ''
    author_email   = ''
    author_date    = ''
    commit_message = ''

    with open (file_directory, 'r') as git_log_file:
        for line in git_log_file:
            # removes non ascii characters
            stripped = (c for c in line if 0 < ord(c) < 127)
            stripped_line = ''.join(stripped)
            
            git_log_file_matcher = re.match(git_log_file_regex, stripped_line)
            
            if git_log_file_matcher is not None:
               
                if git_log_file_matcher.group(1):
                    
                    if commit_hash is not '':
                        
                        cursor.execute("insert into git_commit (project_name, file_name, file_directory, commit_hash, author_name, author_email, author_date, commit_message) values ( %s, %s, %s, %s, %s, %s, to_timestamp(%s, 'Dy Mon DD HH24:MI:SS YYYY +-####'), %s)", (project_name, file_name, file_directory, commit_hash, author_name, author_email, author_date, commit_message))

                        # print commit_hash
                        # print author_name
                        # print author_email
                        # print author_date
                        # print commit_message
                        commit_message =  ''

                    commit_hash  = git_log_file_matcher.group(1)  
                if git_log_file_matcher.group(2):
                    author_name  = git_log_file_matcher.group(2)
                if git_log_file_matcher.group(3):
                    author_email = git_log_file_matcher.group(3) 
                if git_log_file_matcher.group(4):
                    author_date  = git_log_file_matcher.group(4)
            else:
                if commit_hash is not None:
                    commit_message = commit_message + stripped_line
            
    connection.commit()
    print str(progress_counter) + ' out of :'+ str(total_files_to_process)