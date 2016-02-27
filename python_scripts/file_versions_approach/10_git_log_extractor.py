import os
import re
import sys
import subprocess
import shutil
import datetime
import psycopg2


dataset_directory = '/Users/evermal/git/msr16_td_removal/datasets/git_log/'

def get_repository_directory (project_name):
    switcher = {
        "jruby": "/Users/evermal/git/mined_repos/jruby/",
        "apache-ant": "/Users/evermal/git/mined_repos/ant/",
        "apache-jmeter": "/Users/evermal/git/mined_repos/jmeter/",
    }
    return switcher.get(project_name)

connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

cursor.execute("select distinct(project_name, file_name) from technical_debt_summary where file_name not in (select distinct(file_name) from git_log_files)")
all_files = cursor.fetchall()

progress_counter = 0
number_of_files_to_process = len(all_files)

for project_and_file_name in all_files:

    result =  project_and_file_name[0].replace('(', '').replace(')', '').split(',')

    project_name = result[0]
    file_name    = result[1]
    
    print project_name
    print file_name    

    cursor.execute("select distinct(repository_directory) from file_directory_per_version where file_name =%s", (file_name,))
    repository_directories =  cursor.fetchall()

    for repository_directory in repository_directories:

        cursor.execute("select max(version_order), min(version_order) from file_directory_per_version where repository_directory = %s ", (repository_directory))
        version_range = cursor.fetchone()

        newest_version = version_range[0]
        oldest_version = version_range[1]

        # print newest_version
        # print oldest_version   

        cursor.execute("select version_name from file_directory_per_version where file_name = %s and version_order = %s" , (file_name, newest_version))
        tag = cursor.fetchone()

        git_log_file_path = dataset_directory + file_name.replace('.java', '') + "/" + repository_directory[0].replace(file_name, '') 
        subprocess.call(["mkdir", "-p", git_log_file_path ])
        git_log_file_name = str(oldest_version) + '_' + str(newest_version) + "_" + file_name.replace('.java', '.txt')

        git_checkout = "git checkout " + tag[0]
        git_log = "git log -a -- " + repository_directory[0] + " > " + git_log_file_path + git_log_file_name
        command = git_checkout +";"+ git_log
        
        print git_checkout
        print git_log
        # print command
        
        process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True, cwd=get_repository_directory(project_name))
        proc_stdout = process.communicate()[0].strip()
        # process.terminate()  

        file_full_path = git_log_file_path + git_log_file_name
        print file_full_path
        cursor.execute("insert into git_log_files (project_name, file_name, repository_directory, file_directory, oldest_version_order, newest_version_order ) values (%s, %s, %s, %s, %s, %s)", (project_name, file_name, repository_directory,file_full_path, oldest_version, newest_version))

    connection.commit()
    progress_counter = progress_counter + 1

    print str(progress_counter) + " of : " + str(number_of_files_to_process)