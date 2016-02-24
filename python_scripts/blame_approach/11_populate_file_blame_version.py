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

blame_root_folder = '/Users/evermal/git/msr16_td_interest/datasets/blame_files/'
tags_root_folder  = '/Users/evermal/git/msr16_td_interest/tags/'
blame_file_regex  = '([a-z0-9]{8,})\s{1,}(?:.*)\((.+?)(\d\d\d\d-\d\d-\d\d\s\d\d:\d\d\:\d\d\s.{1}\d\d\d\d)\s*(\d*)\)(.*)'

cursor.execute("select project_name,version_name,version_hash,version_order,file_name,file_directory from file_directory_per_version order by 1,4,5 ")
results = cursor.fetchall()

total_files_to_process = len(results)
progress_counter = 0

for result in results:
    progress_counter = progress_counter + 1

    project_name   = result[0]
    version_name   = result[1]
    version_hash   = result[2]
    version_order  = result[3]
    file_name      = result[4]
    file_directory = result[5]

    with open (file_directory.replace(tags_root_folder,blame_root_folder).replace('.java','.txt'), 'r') as blame_file:
        for line in blame_file:
            # print line
            blame_file_matcher = re.match(blame_file_regex, line)
            if blame_file_matcher is not None:
                commit_short_hash = blame_file_matcher.group(1).strip()
                author_name = blame_file_matcher.group(2).strip()
                author_date = blame_file_matcher.group(3).strip()
                file_line = blame_file_matcher.group(4).strip()

                line_content = blame_file_matcher.group(5)
                
                
                # removes non ascii characters
                stripped = (c for c in line_content if 0 < ord(c) < 127)
                stripped_line = ''.join(stripped)

                # print stripped_line
                # print line_content
                # print commit_short_hash
                # print author_name
                # print author_date
                # print file_line
                # print file_name
                # print version_hash
                # print line_content
                       
                cursor.execute("insert into file_blame_per_version (project_name, version_name, version_hash, version_order, file_name, file_directory, commit_short_hash, author_name, author_date, file_line, line_content) values ('"+project_name+"','"+version_name+"','"+version_hash+"','"+str(version_order)+"','"+file_name+"','"+file_directory+"','"+commit_short_hash+"', $escape$"+author_name+"$escape$ ,'"+author_date+"','"+str(file_line)+"', $escape_tag$ "+stripped_line+" $escape_tag$)")    
        blame_file.close()


    connection.commit()
    print str(progress_counter) + ' out of :'+ str(total_files_to_process)
