import subprocess
import psycopg2

print 'dumping temporary database'
subprocess.call("pg_dump -Fc -Uevermal comment_classification > /Users/evermal/Downloads/technical_debt_summary_temp.dump", shell= True)

connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

print 'selecting directories names to be updated'
cursor.execute("select distinct(file_directory) from file_directory_per_version")
file_directory_per_version_list = cursor.fetchall()

for line in file_directory_per_version_list:
    original_file_directory =  line[0]

    if original_file_directory is not None:
        new_file_directory =  original_file_directory.replace('/Users/evermal/git/msr16_td_removal/tags/ant_tags/', '').replace('/Users/evermal/git/msr16_td_removal/tags/jmeter_tags/', '').replace('/Users/evermal/git/msr16_td_removal/tags/jruby_tags/', '')
    else:
        new_file_directory = ''

    cursor.execute("update file_directory_per_version set file_directory = '"+new_file_directory+" 'where file_directory = '"+original_file_directory+"'")

connection.commit()


print 'creating csv file'
cursor.execute("copy (select * from technical_debt_summary) to '/Users/evermal/git/msr16_td_removal/datasets/CSV/technical_debt_summary.csv' (format csv,  header true)")
cursor.execute("copy (select * from tags_information) to '/Users/evermal/git/msr16_td_removal/datasets/CSV/tags_information.csv' (format csv,  header true)")
cursor.execute("copy (select * from file_directory_per_version) to '/Users/evermal/git/msr16_td_removal/datasets/CSV/file_directory_per_version.csv' (format csv,  header true)")
cursor.execute("copy (select * from time_to_remove_td) to '/Users/evermal/git/msr16_td_removal/datasets/CSV/ftime_to_remove_td.csv' (format csv,  header true)")
cursor.execute("copy (select * from git_commit) to '/Users/evermal/git/msr16_td_removal/datasets/CSV/git_commit.csv' (format csv,  header true)")
cursor.execute("copy (select * from git_commit_analysis) to '/Users/evermal/git/msr16_td_removal/datasets/CSV/git_commit_analysis.csv' (format csv,  header true)")
connection.close()

print 'restoring database'
subprocess.call("pg_restore -Uevermal -dcomment_classification -c /Users/evermal/Downloads/technical_debt_summary_temp.dump", shell= True)


copy (select a.project_name, a.file_name, b.repository_directory , a.commit_hash, a.author_date , a.file_checkout from git_commit a, git_log_files b where a.file_directory = b.file_directory order by a.project_name, a.author_date) to '/Users/evermal/Downloads/crash.csv' (format csv,  header true)
