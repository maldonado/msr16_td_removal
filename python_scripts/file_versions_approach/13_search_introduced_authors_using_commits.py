import os
import re
import sys
import subprocess
import shutil
import datetime
import psycopg2
import distance


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
        "jruby": "/Users/evermal/git/msr16_td_removal/datasets/file_version_per_commit/jruby/",
        "apache-ant": "/Users/evermal/git/msr16_td_removal/datasets/file_version_per_commit/apache-ant/",
        "apache-jmeter": "/Users/evermal/git/msr16_td_removal/datasets/file_version_per_commit/apache-jmeter/",
    }
    return switcher.get(project_name)


##### CONFIGURATIONS 
connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()


cursor.execute("select processed_comment_id, project_name, file_name, comment_type, comment_text from technical_debt_summary where processed_comment_id in ('80216','79669','78668','77649','78675','77300','79082','17577','79027','4913','15165','78961','78655','81750','79042','78683','79820') order by 2,3 ")
# cursor.execute("select processed_comment_id, project_name, file_name, comment_type, comment_text from technical_debt_summary order by 2,3 ")
# cursor.execute("select processed_comment_id, project_name, file_name, comment_type, comment_text from technical_debt_summary where file_name not in ('PropertyHelper.java', 'JavaConstructor.java', 'JavaMethod.java') order by 2,3 ")
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

    print file_name


    if 'MULTLINE' == comment_type or 'LINE' == comment_type:
        comment = parse_line_comment(comment_text)
        # print comment
    else:
        comment = parse_block_comment(comment_text)
        # print comment

    cursor.execute("select commit_hash, author_name from git_commit where project_name = %s and file_name = %s and commit_hash not in ('2ebc17d579e5e8a3ca1db259e25ecd370e945a34', '5f836b1236b44148df75df38a82e4862c3bdbc75', '5f836b1236b44148df75df38a82e4862c3bdbc75') order by author_date", (project_name, file_name))
    commit_list = cursor.fetchall()

    for commit in commit_list:


        commit_hash = commit[0]
        author_name = commit[1]

        # print commit_hash

        found_in_version = False
        with open (get_repository_directory(project_name) + file_name.replace('.java','') + "/" + commit_hash + ".java" ,'r') as f:
            
            comment_index = 0
            comment_total_distance = 0

            java_file = []
            
            for line in f:
    
                if comment[comment_index] in line:

                    
    
                    comment_index = comment_index + 1
                    if comment_index == len(comment):
                        found_in_version = True
                        break

            if found_in_version:
                print author_name 
                print commit_hash
                
                cursor.execute("update technical_debt_summary_temp set version_introduced_author = %s , version_introduced_commit_hash = %s where processed_comment_id = %s", (author_name, commit_hash, processed_comment_id))
                connection.commit()
                
                break