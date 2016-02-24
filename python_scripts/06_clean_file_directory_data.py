# keep the oldest file (number of commits) to duplicated file names
# number of files with same number of commits. = 44 (manually investigation of this files shown that they are exact matches from each other)
# number of files with number of commits equals to zero = 0 (expected behavior) 

import os
import re
import sys
import subprocess
import shutil
import datetime
import psycopg2
import distance


def get_repository_directory (project_name):
    switcher = {
        "jruby": "/Users/evermal/git/mined_repos/jruby/",
        "apache-ant": "/Users/evermal/git/mined_repos/ant/",
        "apache-jmeter": "/Users/evermal/mined_repos/git/jmeter/",
    }
    return switcher.get(project_name)

connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

cursor.execute("select project_name, version_name, version_order,  file_name, count(*) from file_directory_per_version group by 1,2,3,4 having count(*) =2 ")
results = cursor.fetchall()

counter = 0
total = len(results)

for line in results:

    project_name  = line[0]
    version_name  = line[1]
    version_order = line[2]
    file_name     = line[3]
    number_of_files = line[4]

    cursor.execute("select repository_directory from file_directory_per_version where project_name = %s and version_name = %s and file_name = %s" , (project_name, version_name, file_name))
    file_directory_results = cursor.fetchall()
    

    first_file_repository_directory = file_directory_results[0][0]
    second_file_repository_directory = file_directory_results[1][0]

    command = "git checkout " + version_name + " ; git log -- "+ first_file_repository_directory +" | grep -o \"^commit\s[a-z0-9]*$\" | wc -l"
    process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True, cwd=get_repository_directory(project_name))
    first_file_repository_directory_commit_counter = process.communicate()[0].strip().decode('utf-8')

    command = "git log -- "+ second_file_repository_directory +" | grep -o \"^commit\s[a-z0-9]*$\" | wc -l"
    process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True, cwd=get_repository_directory(project_name))
    second_file_repository_directory_commit_counter = process.communicate()[0].strip().decode('utf-8')
        
    if first_file_repository_directory_commit_counter >= second_file_repository_directory_commit_counter :
        cursor.execute("delete from file_directory_per_version where project_name=%s and file_name=%s and version_name =%s and repository_directory = %s", (project_name, file_name, version_name, second_file_repository_directory))

    else:
        cursor.execute("delete from file_directory_per_version where project_name=%s and file_name=%s and version_name =%s and repository_directory = %s", (project_name, file_name, version_name, first_file_repository_directory))   

    connection.commit()
    counter = counter + 1 
    print  str(counter) + " out of: " + str(total)


