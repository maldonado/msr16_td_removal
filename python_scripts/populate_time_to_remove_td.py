import psycopg2

##### CONFIGURATIONS 
connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

cursor.execute("select processed_comment_id , interval_time_to_remove, project_name, version_introduced_hash, version_removed_hash  from time_to_remove_td  where version_removed_name != 'not_removed'")
results = cursor.fetchall()

total_files_to_process = len(results)
progress_counter = 0

for result in results:
    progress_counter = progress_counter + 1

    processed_comment_id      = result[0]
    interval_time_to_remove   = result[1]
    project_name              = result[2]
    version_introduced_hash   = result[3]
    version_removed_hash      = result[4]
    
    # print processed_comment_id
    # print interval_time_to_remove
    # print project_name
    # print version_introduced_hash
    # print version_removed_hash

    cursor.execute('select version_order from tags_information where project_name = %s and version_hash = %s', (project_name, version_introduced_hash))
    version_introduced_order = cursor.fetchone()

    # print version_introduced_order

    cursor.execute('select version_order from tags_information where project_name = %s and version_hash = %s', (project_name, version_removed_hash))
    version_removed_order = cursor.fetchone()

    # print version_removed_order

    number_of_releases_to_remove = version_removed_order[0] - version_introduced_order[0]
    # print number_of_releases_to_remove

    cursor.execute("update time_to_remove_td set number_of_releases_to_remove = %s , epoch_time_to_remove = extract (epoch from interval '"+interval_time_to_remove+"') where processed_comment_id = %s", (number_of_releases_to_remove, processed_comment_id))
    connection.commit()

    print str(progress_counter) + ' out of :'+ str(total_files_to_process)