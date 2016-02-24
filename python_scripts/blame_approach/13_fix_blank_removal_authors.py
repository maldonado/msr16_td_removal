import os
import re
import sys
import subprocess
import shutil
import datetime
import psycopg2
from sets import Set

def parse_line_comment (comment):
    result = []
    for line in comment.split('//'):
        if '' is not line:
            result.append(('//'+line).strip())
    return result

def parse_block_comment (comment):
    result = []
    for line in comment.split('\n'):
        if len(comment.split('\n')) is 1:
            new_line = line.strip()
        else:
            new_line = (line.replace('/**', '').replace('*/', '').replace('/*', '')).strip()
        if '' is not new_line:
            result.append(new_line)
    return result

def get_repository_directory (project_name):
    switcher = {
        "jruby": "/Users/evermal/git/jruby/",
        "apache-ant": "/Users/evermal/git/ant/",
        "apache-jmeter": "/Users/evermal/git/jmeter/",
    }
    return switcher.get(project_name)

connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

git_log_regex = 'commit\s(.{40})\nAuthor:\s(.*?)\<'

# cursor.execute("select a.project_name, a.file_name, a.version_removed_name, a.version_removed_hash, b.repository_directory, a.comment_text, a.processed_comment_id, a.comment_type  from technical_debt_summary a , file_directory_per_version b where a.last_version_that_comment_was_found_hash = b.version_hash and a.file_name =  b.file_name and a.version_removed_author is null and a.version_removed_name != 'not_removed' order by 1,2 ")
cursor.execute("select a.project_name, a.file_name, a.version_removed_name, a.version_removed_hash, b.repository_directory, a.comment_text, a.processed_comment_id, a.comment_type  from technical_debt_summary a , file_directory_per_version b where a.last_version_that_comment_was_found_hash = b.version_hash and a.file_name =  b.file_name and a.version_removed_author = '' and a.version_removed_name != 'not_removed' order by 1,2 ")
results = cursor.fetchall()

total_files_to_process = len(results)
progress_counter = 0

for result in results:
    progress_counter = progress_counter + 1

    project_name           = result[0]
    file_name              = result[1]
    version_removed_name   = result[2]
    version_removed_hash   = result[3]
    repository_directory   = result[4]
    comment_text           = result[5]
    processed_comment_id   = result[6]
    comment_type           = result[7]
    
    # check if the file was removed. 
    cursor.execute("select count(*) from file_blame_per_version where file_name = %s and version_hash = %s", (file_name, version_removed_hash))
    file_blame_count_result = cursor.fetchone()

    if file_blame_count_result[0] == 0:
        # it means that is not blame file. so, we need to find the last commit made. 
        git_checkout = "git checkout " + version_removed_name
        git_log = "git log -1 -- " + repository_directory
        command = git_checkout +";"+ git_log
        
        # print git_checkout
        # print git_log
        # print command
        
        process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True, cwd=get_repository_directory(project_name))
        proc_stdout = process.communicate()[0].strip()
        
        git_log_matcher =  re.match(git_log_regex, proc_stdout)
      
        if git_log_matcher is not None:

            git_commit_hash   = git_log_matcher.group(1).strip()
            git_commit_author = git_log_matcher.group(2).strip()
            
            print git_commit_hash
            print git_commit_author

            cursor.execute("update technical_debt_summary set version_removed_commit_hash = %s , version_removed_author = %s where processed_comment_id = %s" , (git_commit_hash, git_commit_author, processed_comment_id))
        else:
            print '----------> ERROR'

    else:
        # the blame file exists but the last know position of the comment does not exist in the file.
        
        author_set = Set([])
        comment_text_list = []
        commit_hash_set = Set([])

        if "MULTLINE" == comment_type or "LINE" == comment_type:
            comment_text_list = parse_line_comment(comment_text)
        else:
            comment_text_list = parse_block_comment(comment_text)

        for comment in comment_text_list:
            
            git_checkout = "git checkout " + version_removed_name
            git_pickaxe = 'git log -1 -S "' + comment + '" '+ repository_directory 
            command = git_checkout +";"+ git_pickaxe

            # print git_checkout
            # print git_pickaxe

            process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True, cwd=get_repository_directory(project_name))
            proc_stdout = process.communicate()[0].strip()
            
            # print proc_stdout

            git_log_matcher =  re.match(git_log_regex, proc_stdout)
            if git_log_matcher is not None:

                git_commit_hash   = git_log_matcher.group(1).strip()
                git_commit_author = git_log_matcher.group(2).strip()
                
                commit_hash_set.add(git_commit_hash)
                author_set.add(git_commit_author)
            else:
                print '----------> ERROR'

        version_removed_commit_hash =  ', '.join(commit_hash_set)
        version_removed_author =  ', '.join(author_set)
        
        print version_removed_commit_hash 
        print version_removed_author

        cursor.execute("update technical_debt_summary set version_removed_commit_hash = %s , version_removed_author = %s where processed_comment_id = %s" , (version_removed_commit_hash, version_removed_author, processed_comment_id))

    connection.commit()
    print str(progress_counter) + ' out of :'+ str(total_files_to_process)