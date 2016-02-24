import os
import re
import sys
import subprocess
import shutil
import datetime
import psycopg2

# apache-ant
# apache-jmeter
# jruby
project_name = 'apache-jmeter'

def get_root_directory(project_name, version_order, tag):
    if project_name == 'apache-ant':
        return '/Users/evermal/git/msr16_td_interest/tags/ant_tags/'+version_order+'.'+tag+'/src/'
    if project_name == 'apache-jmeter':
        return '/Users/evermal/git/msr16_td_interest/tags/jmeter_tags/'+version_order+'.'+tag+'/src/'
    if project_name == 'jruby':
        return '/Users/evermal/git/msr16_td_interest/tags/jruby_tags/'+version_order+'.'+tag+'/src/'

connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

# get directory name and project name to create folders dynamically
directory = subprocess.check_output(["pwd"]).split()[0]
directory_name = directory.split('/')[-1]

# create folder to keep all the tags
subprocess.call(["mkdir", "../"+directory_name+"_blame_files"])

# get all tags from the git repository in order and with date
git_log_result = subprocess.check_output(["git", "log", "--tags", "--date-order",  "--reverse",  "--simplify-by-decoration", "--pretty=%ai %d"])
 
# #regex to eliminate folders that is not relevant for the analysis, like third party libraries and invisible files
file_regex = '\..*|git_tag_extractor\.py' 
tags_regex = '(\d\d\d\d\-\d\d\-\d\d\s\d\d:\d\d:\d\d)|\(tag:\s([A-Za-z0-9\-\_\.+]*)\)'
# directory_regex = '\..*|vendor|thirdparty|(:?ex|s)amples|doc(:?s|uments)|bin|node' 
directory_regex = '\..*' 

counter = 0
for line in git_log_result.split('\n'):
    # for each line has matches
    if re.search(tags_regex, line) is not None:
        m = re.findall(tags_regex, line)
        # has match fot tag and date (merge has date but not tag)
        if len(m) == 2:
            # get result from the first tuple, first item (date)
            tag_date = m[0][0]
            # get result from the second tuple, second item (tag)
            tag = m[1][1]
            
            # checkout into each of them
            subprocess.call(["git", "checkout" , tag])

            cursor.execute("select version_order, file_directory, file_name from file_directory_per_version where project_name = '"+project_name+"' and version_name = '"+tag+"' limit 1 ")
            file_directory_per_version_table = cursor.fetchall()
    
            for file_directory_per_version_line in file_directory_per_version_table:
                version_order = file_directory_per_version_line[0]
                
                database_directory = file_directory_per_version_line[1]
                repository_directory = database_directory.replace(get_root_directory(project_name, version_order, tag) ,'')
                # print "update file_directory_per_version set repository_directory = '"+repository_directory+"' where project_name = '"+project_name+"' and version_name = '"+tag+"' and file_directory = '"+database_directory+"' "
                cursor.execute("update file_directory_per_version set repository_directory = '"+repository_directory+"' where project_name = '"+project_name+"' and version_name = '"+tag+"' and file_directory = '"+database_directory+"' ")
                
                git_log_result = subprocess.check_output(["git", "blame" , repository_directory])
                
                file_name = file_directory_per_version_line[2].replace('.java', '.txt')
                # create directory to place all the tags
                folder_path = "../"+ directory_name +"_blame_files/"+database_directory.replace('/Users/evermal/git/msr16_td_interest/tags/', '').replace(database_directory.split('/')[-1], '')
                print folder_path
                subprocess.call(["mkdir", "-p", folder_path])

                with open (folder_path+file_name,'a') as blame_file:
                    for line in git_log_result:
                        blame_file.write(line)

                    blame_file.close()
            connection.commit()