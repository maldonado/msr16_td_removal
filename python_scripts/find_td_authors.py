import os
import re
import sys
import subprocess
import shutil
import datetime
import psycopg2
from sets import Set

##### CONFIGURATIONS 
connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

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


cursor.execute("select version_introduced_hash, file_name , comment_text, comment_type, class_id, comment_start_line, comment_end_line, version_removed_name, version_removed_hash, last_version_that_comment_was_found_hash from technical_debt_summary where version_introduced_hash is not null and version_introduced_commit_hash is null")
results = cursor.fetchall()

total_files_to_process = len(results)
progress_counter = 0

for result in results:
    progress_counter = progress_counter + 1

    version_introduced_hash   = result[0]
    file_name      = result[1]
    comment_text   = result[2]
    comment_type   = result[3]
    class_id       = result[4]
    comment_start_line = result[5]
    comment_end_line   = result[6]
    version_removed_name = result[7]
    version_removed_hash = result[8]
    last_version_that_comment_was_found_hash = result[9]
    
    if 'MULTLINE' == comment_type or 'LINE' == comment_type:
        comment_list = parse_line_comment(comment_text)
        # print comment
    else:
        comment_list = parse_block_comment(comment_text)
        # print comment
    
    # start find author that introduced the td
    version_introduced_commit_hash_list = Set([])
    version_introduced_author_list = Set([])
    version_introduced_lines_list   = Set([])

    # print file_name
    # print version_removed_name
    # print last_version_that_comment_was_found_hash

    for comment in comment_list:
        cursor.execute('select commit_short_hash, author_name, file_line from file_blame_per_version where file_name = %s and version_hash = %s and line_content like %s' , (file_name, version_introduced_hash, '%'+comment+'%') )
        blame_file_results = cursor.fetchall()

        for blame_line in blame_file_results:
            version_introduced_commit_hash_list.add(str(blame_line[0]))
            version_introduced_author_list.add(str(blame_line[1]))
            version_introduced_lines_list.add(str(blame_line[2]))

    version_introduced_commit_hash =  ', '.join(version_introduced_commit_hash_list)
    version_introduced_author =  ', '.join(version_introduced_author_list)
    version_introduced_lines  =  ', '.join(version_introduced_lines_list)
    
    # print version_introduced_commit_hash
    # print version_introduced_author
    # print version_introduced_lines

    cursor.execute('update technical_debt_summary set version_introduced_commit_hash = %s, version_introduced_author = %s, version_introduced_lines = %s where class_id = %s and comment_start_line = %s and comment_end_line = %s', (version_introduced_commit_hash, version_introduced_author, version_introduced_lines, class_id , comment_start_line , comment_end_line ))
    # end find author that introduced the td
    
    if 'not_removed' not in version_removed_name:

        # start find what lines the file was comment was last seem
        last_version_that_comment_was_found_lines_list = Set([])

        for comment in comment_list:
            cursor.execute('select file_line from file_blame_per_version where file_name = %s and version_hash = %s and line_content like %s' , (file_name, last_version_that_comment_was_found_hash, '%'+comment+'%') )
            blame_file_results = cursor.fetchall()

            for blame_line in blame_file_results:
                last_version_that_comment_was_found_lines_list.add("'"+ str(blame_line[0]) +"'")

        if len(last_version_that_comment_was_found_lines_list) > 0:
            
            last_version_that_comment_was_found_lines  =  ', '.join(last_version_that_comment_was_found_lines_list)

            # print last_version_that_comment_was_found_lines
            cursor.execute('update technical_debt_summary set last_version_that_comment_was_found_lines = %s where class_id = %s and comment_start_line = %s and comment_end_line = %s', (last_version_that_comment_was_found_lines, class_id , comment_start_line , comment_end_line ))
            # end find what lines the file was comment was last seem

            # start find author that removed the td
            version_removed_commit_hash_list = Set([])
            version_removed_author_list  = Set([])
            version_removed_lines_list   = Set([])

            for comment in comment_list:
                cursor.execute('select commit_short_hash, author_name, file_line from file_blame_per_version where file_name = %s and version_hash = %s and file_line in ('+last_version_that_comment_was_found_lines+')' , (file_name, version_removed_hash) )
                blame_file_results = cursor.fetchall()

                for blame_line in blame_file_results:
                    version_removed_commit_hash_list.add(str(blame_line[0]))
                    version_removed_author_list.add(str(blame_line[1]))
                    version_removed_lines_list.add(str(blame_line[2]))

            version_removed_commit_hash =  ', '.join(version_removed_commit_hash_list)
            version_removed_author =  ', '.join(version_removed_author_list)
            version_removed_lines  =  ', '.join(version_removed_lines_list)
            
            cursor.execute('update technical_debt_summary set version_removed_commit_hash = %s, version_removed_author = %s, version_removed_lines = %s where class_id = %s and comment_start_line = %s and comment_end_line = %s', (version_removed_commit_hash, version_removed_author, version_removed_lines, class_id , comment_start_line , comment_end_line ))
            # end find author that removed the td
        
        else:
            cursor.execute('update technical_debt_summary set version_introduced_commit_hash = %s where class_id = %s and comment_start_line = %s and comment_end_line = %s', ("error", class_id , comment_start_line , comment_end_line ))

    connection.commit() 
    print str(progress_counter) + ' out of :'+ str(total_files_to_process)