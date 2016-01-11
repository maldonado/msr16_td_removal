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

cursor.execute("select project_name, version_name, version_order,  file_name, count(*) from file_directory_per_version group by 1,2,3,4 having count(*) > 1")
results = cursor.fetchall()

for line in results:

    project_name  = line[0]
    version_name  = line[1]
    version_order = line[2]
    file_name     = line[3]

    print file_name

    cursor.execute("select file_directory from file_directory_per_version where project_name = %s and file_name = %s and version_name = %s ", (project_name, file_name, version_name))
    file_directory_list = cursor.fetchall()

    print len(file_directory_list)

    # case 1 - the files in different directories are identical, so keep both of them and calculate the dependencies for both files. 
    java_file_list = []
    for file_directory_line in file_directory_list:
        print file_directory_line[0]
        temp = []    
        with open (file_directory_line[0] ,'r') as f:
            for line in f:
                temp.append(line)
        java_file_list.append(''.join(temp))

    for x in xrange(0, len(java_file_list) -1):
        value = distance.levenshtein(java_file_list[x].split('\n'),  java_file_list[x+1].split('\n'))
        if value == 0:
            print 'they are equal'
            # cursor.execute("update file_directory_per_version set matched_analyzed_file_directory = 'IGNORE' where ")
        else:
            print 'they are different'
        # pass
print '---------'
    # print java_file_list
# subl /Users/evermal/git/msr16_td_interest/tags/jruby_tags/90.jruby-openssl-0.9.5/src/core/src/main/java/org/jruby/RubyFile.java
# subl /Users/evermal/git/msr16_td_interest/tags/jruby_tags/90.jruby-openssl-0.9.5/src/core/src/main/java/org/jruby/truffle/runtime/core/RubyFile.java

    #     with open (older_file_directory,'r') as f:
    #         comment_index = 0
    #         # comment_distance_threshold = 0
    #         comment_total_distance = 0
    #         java_file = []
    #         for line in f:
    #             value = distance.levenshtein(comment[comment_index], line.strip())
    #             # print str(value)+' - '+line 
    #             if value < 10:
    #                 found_in_version = True
    #                 print str(value)+' - '+line 
    #                 print str(value)+' - '+comment[comment_index]
    #                 comment_total_distance = comment_total_distance + value
    #                 comment_index = comment_index + 1
    #                 if comment_index == len(comment):
    #                     break

# /src/src/functions/org/apache/jmeter/functions/FileWrapper.java
# /Users/evermal/git/msr16_td_interest/tags/jmeter_tags/57.v2_7/src/src/core/org/apache/jmeter/util/BSFJavaScriptEngine.java

    # cursor.execute("select class_name from technical_debt_summary where project_name = '"+project_name+"' and file_name = '"+file_name+"'")
    # class_name_result = cursor.fetchall()

    # incomplete_file_directory = class_name_result[0][0].replace('.', '/')+".java"

    # for file_directory_line in file_directory_list:
    #     file_directory = file_directory_line[0]
    #     print file_directory_line
    #     if incomplete_file_directory in file_directory:
    #         cursor.execute("update file_directory_per_version set matched_analyzed_file_directory = 'True' where file_name = '"+file_name+"' and version_name = '"+version_name+"' and file_directory = '"+file_directory+"'")
    #     else:
    #         cursor.execute("update file_directory_per_version set matched_analyzed_file_directory = 'False' where file_name = '"+file_name+"' and version_name = '"+version_name+"' and file_directory = '"+file_directory+"'")

    #     connection.commit()