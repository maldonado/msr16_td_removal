import os
import sys
import psycopg2
import subprocess
import re

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

def get_versions_directory (project_name):
    switcher = {
        "jruby": "/Users/evermal/git/msr16_td_removal/datasets/file_version_per_commit/jruby/",
        "apache-ant": "/Users/evermal/git/msr16_td_removal/datasets/file_version_per_commit/apache-ant/",
        "apache-jmeter": "/Users/evermal/git/msr16_td_removal/datasets/file_version_per_commit/apache-jmeter/",
    }
    return switcher.get(project_name)

def get_repository_directory (project_name):
    switcher = {
        "jruby": "/Users/evermal/git/mined_repos/jruby/",
        "apache-ant": "/Users/evermal/git/mined_repos/ant/",
        "apache-jmeter": "/Users/evermal/git/mined_repos/jmeter/",
    }
    return switcher.get(project_name)

##### CONFIGURATIONS 
connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

# WARNING: using technical_debt_summary_temp in this script !!! 
cursor.execute("select a.processed_comment_id, a.project_name, a.file_name, a.comment_type, a.comment_text, b.version_introduced_commit_hash from technical_debt_summary a , technical_debt_summary_temp b where  a.processed_comment_id = b.processed_comment_id and  a.version_removed_name != 'not_removed' order by 2,3 ")
results = cursor.fetchall()

total_files_to_process = len(results)
progress_counter = 0

for result in results:
    progress_counter = progress_counter + 1

    processed_comment_id = result[0]
    project_name         = result[1]
    file_name            = result[2]
    comment_type         = result[3]
    comment_text         = result[4]
    version_introduced_commit_hash = result[5]

    print file_name

    if 'MULTLINE' == comment_type or 'LINE' == comment_type:
        # comment = 'Adding implicit nils caused multiple problems'
        comment = parse_line_comment(comment_text)
        # print comment
    else:
        comment = parse_block_comment(comment_text)
        # print comment
    
    cursor.execute("select commit_hash, author_name from git_commit where project_name = %s and file_name = %s and  author_date >= (select author_date from git_commit where commit_hash = %s and file_name = %s ) order by author_date", (project_name, file_name, version_introduced_commit_hash, file_name))
    # cursor.execute("select commit_hash, author_name from git_commit where project_name = %s and file_name = %s and commit_hash not in ('a6f20b63a56aff2e1bce74f89078234bc4c34446', '75f48785fa21e4aff89581353bb425648c2ec7c4') order by author_date", (project_name, file_name))
    commit_list = cursor.fetchall()

    removed_author_name = ''
    removed_commit_hash = ''

    for commit in commit_list:

        commit_hash = commit[0]
        author_name = commit[1]

        # print commit_hash
        found_in_version = False
        with open (get_versions_directory(project_name) + file_name.replace('.java','') + "/" + commit_hash + ".java" ,'r') as f:
            
            comment_index = 0
            comment_total_distance = 0

            java_file = []
            
            for line in f:
                if comment[comment_index] in line:
                    # print comment[comment_index]
                    # print line

                    comment_index = comment_index + 1
                    if comment_index == len(comment):
                        # print commit_hash
                        found_in_version = True
                        break

        if not found_in_version:
            print author_name
            print commit_hash
            removed_author_name = author_name
            removed_commit_hash = commit_hash
            cursor.execute("update technical_debt_summary_temp set version_removed_author = %s , version_removed_commit_hash = %s where processed_comment_id = %s", (removed_author_name, removed_commit_hash, processed_comment_id))
            connection.commit()
            break

    # this means that the all the versions that we have from the file contains the TD, so we search for the commit that removed the file
    if removed_author_name == '':

        cursor.execute("select a.version_removed_name, b.repository_directory from technical_debt_summary a, file_directory_per_version b  where  a.file_name = b.file_name and a.last_version_that_comment_was_found_name = b.version_name and a.processed_comment_id  = %s", (processed_comment_id,))
        technical_debt_summary_result = cursor.fetchall()

        for technical_debt_summary_line in technical_debt_summary_result:
            version_removed_name = technical_debt_summary_line[0]
            repository_directory = technical_debt_summary_line[1]


            git_checkout = "git checkout " + version_removed_name
            git_log = "git log -1 -- " + repository_directory
            command = git_checkout +";"+ git_log
            
            # print git_checkout
            # print git_log
            # print command
            
            process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True, cwd=get_repository_directory(project_name))
            proc_stdout = process.communicate()[0].strip()
            
            git_log_matcher =  re.match('commit\s(.{40})\nAuthor:\s(.*?)\<', proc_stdout)
          
            if git_log_matcher is not None:

                git_commit_hash   = git_log_matcher.group(1).strip()
                git_commit_author = git_log_matcher.group(2).strip()
                
                print git_commit_hash
                print git_commit_author

                cursor.execute("update technical_debt_summary_temp set version_removed_author = %s , version_removed_commit_hash = %s where processed_comment_id = %s", (git_commit_author, git_commit_hash, processed_comment_id))
                connection.commit()