# identify files that have the same root folder than the mannualy classified file. 

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

for line in results:

    project_name  = line[0]
    version_name  = line[1]
    version_order = line[2]
    file_name     = line[3]

    cursor.execute("select file_directory from file_directory_per_version where project_name = %s and file_name = %s and version_name = %s ", (project_name, file_name, version_name))
    file_directory_results = cursor.fetchall()

    cursor.execute("select class_name from technical_debt_summary where project_name = %s and file_name = %s", (project_name, file_name))
    class_name_result = cursor.fetchall()

    incomplete_file_directory = class_name_result[0][0].replace('.', '/')+".java"

    for file_directory_line in file_directory_results:
        file_directory = file_directory_line[0]
        print file_directory_line
        if incomplete_file_directory in file_directory:
            cursor.execute("update file_directory_per_version set matched_analyzed_file_directory = 'True' where file_name = %s and version_name = %s and file_directory = %s", (file_name, version_name, file_directory))  
        else:
            cursor.execute("update file_directory_per_version set matched_analyzed_file_directory = 'False' where file_name = %s and version_name = %s and file_directory = %s", (file_name, version_name, file_directory))
        connection.commit()