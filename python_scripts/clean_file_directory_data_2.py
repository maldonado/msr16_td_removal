import os
import re
import sys
import subprocess
import shutil
import datetime
import psycopg2


connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

cursor.execute("select project_name, version_name, version_order,  file_name, count(*) from file_directory_per_version group by 1,2,3,4 having count(*) > 1 ")
results = cursor.fetchall()

delete_counter = 0

for line in results:

    project_name = line[0]
    version_name = line[1]
    version_order = line[2]
    file_name = line[3]
    number_of_files = line[4]

    cursor.execute("select file_directory, matched_analyzed_file_directory from file_directory_per_version where project_name = '"+project_name+"' and file_name = '"+file_name+"' and version_name = '"+version_name+"' ")
    file_directory_results = cursor.fetchall()

    matched_counter = 0
    non_matchet_counter = 0
    

    for file_directory_line in file_directory_results:
        file_directory = file_directory_line[0]
        matched_analyzed_file_directory = file_directory_line[1]

        if matched_analyzed_file_directory == 'True':
            matched_counter = matched_counter + 1
        else :
            non_matchet_counter = non_matchet_counter + 1

    
    if matched_counter >= 1 and non_matchet_counter != 0:

        for file_directory_line in file_directory_results:
            file_directory = file_directory_line[0]
            matched_analyzed_file_directory = file_directory_line[1]

            if matched_analyzed_file_directory == 'False':

                delete_counter = delete_counter + 1
                cursor.execute("delete from file_directory_per_version where matched_analyzed_file_directory = 'False'  and file_name = '"+file_name+"' and version_name = '"+version_name+"' and file_directory = '"+file_directory+"'")    
      
    connection.commit()

print delete_counter