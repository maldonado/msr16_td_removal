import os
import re
import sys
import subprocess
import shutil
import datetime
import psycopg2

def get_root_folder(project_name):
    if project_name == 'apache-ant':
        return '/Users/evermal/git/msr16_td_interest/tags/ant_tags/' 
    elif project_name == 'apache-jmeter':
        return '/Users/evermal/git/msr16_td_interest/tags/jmeter_tags/'
    else:
        return '/Users/evermal/git/msr16_td_interest/tags/jruby_tags/'

connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

cursor.execute("select distinct(project_name) from technical_debt_summary")
project_name_result = cursor.fetchall()

for project_name_line in project_name_result:
    project_name = project_name_line[0]

    cursor.execute("select distinct(file_name) from technical_debt_summary where project_name = '"+project_name+"'")
    file_names = cursor.fetchall()

    cursor.execute("select version_name, version_order, version_hash from tags_information where project_name = '"+project_name+"' order by 2 ")
    ordered_versions = cursor.fetchall()

    for line in file_names:
        file_name = line[0]
        
        for version in ordered_versions:
            version_name =  version[0]
            version_order = version[1]
            version_hash = version[2]

            version_name_pattern = str(version_order)+'.'+version_name+'/'
            root_folder = get_root_folder(project_name)

            for root, dirs, files in os.walk(root_folder+version_name_pattern):
                for f in files:
                    file_directory = os.path.join(root, f)  
                    if file_name == f :
                        print file_directory
                        cursor.execute("insert into file_directory_per_version (project_name,version_name,version_hash, version_order, file_name,file_directory) values ('"+project_name+"','"+version_name+"','"+version_hash+"','"+str(version_order)+"','"+file_name+"','"+file_directory+"')")

        connection.commit()                

    