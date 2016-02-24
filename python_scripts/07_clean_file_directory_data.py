# choose manually between the files that was more than two files with the same name per version
import os
import re
import sys
import subprocess
import shutil
import datetime
import psycopg2

def get_repository_directory (project_name):
    switcher = {
        "jruby": "/Users/evermal/git/mined_repos/jruby/",
        "apache-ant": "/Users/evermal/git/mined_repos/ant/",
        "apache-jmeter": "/Users/evermal/mined_repos/git/jmeter/",
    }
    return switcher.get(project_name)

def checkout_repository(project_name, version_name):
    command = "git checkout " + version_name 
    process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True, cwd=get_repository_directory(project_name))
    process.communicate()[0].strip().decode('utf-8')


connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()
cursor.execute("select project_name, version_name, version_order,  file_name, count(*) from file_directory_per_version group by 1,2,3,4 having count(*) > 1 ")
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

    file_repository_directory_list = []
    for file_directory_result_line in file_directory_results:
        file_repository_directory_list.append(get_repository_directory(project_name) + file_directory_result_line[0])

    file_names =  ' '.join(file_repository_directory_list)
    subprocess.call("subl -n " + file_names , shell=True)

    cursor.execute("select comment_text, comment_type, class_name from technical_debt_summary where project_name = %s and file_name = %s" , (project_name, file_name))
    technical_debt_summary_results = cursor.fetchall()

    for technical_debt_summary_line in technical_debt_summary_results:
        comment_text = technical_debt_summary_line[0]
        class_name   = technical_debt_summary_line[2]

    print comment_text
    print class_name

    researcher_choise = input("Choose file index to keep\n")
    file_repository_directory_list.pop(researcher_choise)

    for repository_directory_item in file_repository_directory_list:
        # print repository_directory_item
        cursor.execute("delete from file_directory_per_version where project_name=%s and file_name=%s and version_name =%s and repository_directory = %s", (project_name, file_name, version_name, repository_directory_item.replace(get_repository_directory(project_name), '')))
        # print cursor.query
        connection.commit()

    subprocess.call("osascript -e 'quit app \"Sublime Text\"'", shell=True)
    counter = counter + 1

    print str(counter) + " out of: "+ str(total)