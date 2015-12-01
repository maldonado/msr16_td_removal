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

# apache-ant    || ant_tags/52.ANT_170 
# apache-jmeter || jmeter_tags/67.v2_10
# jruby         || jruby_tags/35.1.4.0
project_name = 'jruby'
root_folder = '/Users/evermal/git/msr16_td_removal/tags/jruby_tags/35.1.4.0'
##### 

cursor.execute("select distinct(class_name) from technical_debt_summary where project_name = '"+project_name+"'")
results = cursor.fetchall()

for result in results:
    class_name = result[0]
    incomplete_file_directory = class_name.replace('.', '/')+".java"

    for root, dirs, files in os.walk(root_folder):
        for f in files:
            # print file_directory
            file_directory = os.path.join(root, f)  

            if incomplete_file_directory in file_directory :
                print file_directory
                print incomplete_file_directory
                cursor.execute("update technical_debt_summary set file_directory = '"+file_directory+"' where class_name = '"+class_name+"' and project_name = '"+project_name+"'")
                

connection.commit()