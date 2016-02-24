# remove files that has been identified having the same root folder than the manually classified file

import os
import re
import sys
import subprocess
import shutil
import datetime
import psycopg2
import distance


connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

cursor.execute("select project_name, version_name, version_order,  file_name, count(*) from file_directory_per_version group by 1,2,3,4 having count(*) > 1 ")
results = cursor.fetchall()

delete_counter = 0

for line in results:

    project_name  = line[0]
    version_name  = line[1]
    version_order = line[2]
    file_name     = line[3]
    number_of_files = line[4]

    cursor.execute("select file_directory, matched_analyzed_file_directory from file_directory_per_version where project_name = %s and file_name = %s and version_name = %s ", (project_name, file_name, version_name))
    file_directory_results = cursor.fetchall()

    matched_counter = 0
    non_matched_counter = 0
    
    for file_directory_line in file_directory_results:
        file_directory = file_directory_line[0]
        matched_analyzed_file_directory = file_directory_line[1]

        if matched_analyzed_file_directory == 'True':
            matched_counter = matched_counter + 1
        else :
            non_matched_counter = non_matched_counter + 1

    # this means that the we find exactly the file that we are looking for
    if matched_counter >= 1 and non_matched_counter != 0:
        for file_directory_line in file_directory_results:
            file_directory = file_directory_line[0]
            matched_analyzed_file_directory = file_directory_line[1]

            if matched_analyzed_file_directory == 'False':
                
                delete_counter = delete_counter + 1
                cursor.execute("delete from file_directory_per_version where matched_analyzed_file_directory = 'False'  and file_name = %s and version_name = %s and file_directory = %s", (file_name, version_name, file_directory))    

    # this means that the file was moved 
    # if non_matched_counter >=1 and matched_counter == 0:

        # cursor.execute("select file_directory from file_directory_per_version where project_name = %s and file_name = %s and version_name = %s ", (project_name, file_name, version_name))
        # file_directory_list = cursor.fetchall()

        # # print len(file_directory_list)

        # # case 1 - the files in different directories are identical, so keep both of them and calculate the dependencies for both files. 
        # java_file_list = []
        # for file_directory_line in file_directory_list:
        #     # print file_directory_line[0]
        #     temp = []    
        #     with open (file_directory_line[0] ,'r') as f:
        #         for line in f:
        #             temp.append(line)
        #     java_file_list.append(''.join(temp))

        # for x in xrange(0, len(java_file_list) -1):
        #     value = distance.levenshtein(java_file_list[x].split('\n'),  java_file_list[x+1].split('\n'))
        #     if value == 0:
        #         print 'they are equal'
        #         # cursor.execute("update file_directory_per_version set matched_analyzed_file_directory = 'IGNORE' where ")
        #     else:
        #         print 'they are different'

        # cursor.execute("select max(author_date) from file_blame_per_version where file_name = %s and version_order = %s", (file_name, version_order))
        # current_blame_date_result = cursor.fetchone()


        # print "here"

      
    connection.commit()

print delete_counter