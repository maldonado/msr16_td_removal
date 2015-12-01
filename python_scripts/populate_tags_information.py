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

 # apache-ant
 # apache-jmeter
 # jruby
project_name = 'jruby'
tags_regex = '([a-z0-9]{40})|(\d\d\d\d\-\d\d\-\d\d\s\d\d:\d\d:\d\d)|\(tag:\s([A-Za-z0-9\-\_\.+]*)\)'

# get all tags from the git repository in order and with date
git_log_result = subprocess.check_output(["git", "log", "--tags", "--date-order",  "--reverse",  "--simplify-by-decoration", "--pretty=%H %ai %d"])

version_order = 0
for line in git_log_result.split('\n'):
    # print line
    # for each line has matches
    if re.search(tags_regex, line) is not None:
        m = re.findall(tags_regex, line)
        # has match fot tag and date (merge has date but not tag)
        if len(m) == 3:
            # get result from the first tuple, first item (commit_hash)
            version_hash = m[0][0]
            print version_hash
            # get result from the second tuple, second item (date)
            version_date = m[1][1]
            print version_date
            # get result from the third tuple, third item (tag)
            version_name = m[2][2]
            print version_name

            cursor.execute("insert into tags_information (project_name, version_name, version_hash, version_date, version_order) values ('"+project_name+"', '"+version_name+"', '"+version_hash+"', to_timestamp('"+version_date+"', 'YYYY-MM-DD HH24:MI:SS'), '"+str(version_order)+"')")
            version_order = version_order + 1

connection.commit()