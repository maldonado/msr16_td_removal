import psycopg2

##### CONFIGURATIONS 
connection = None
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()


cursor.execute("select processed_comment_id , project_name, was_td_removed, epoch_time_to_remove, epoch_time_in_the_system from time_to_remove_td")
results = cursor.fetchall()

total_files_to_process = len(results)
progress_counter = 0

for result in results:
    progress_counter = progress_counter + 1

    processed_comment_id      = result[0]
    project_name              = result[1]
    was_td_removed            = result[2]
    epoch_time_to_remove      = result[3]
    epoch_time_in_the_system  = result[4]

    
    if was_td_removed:
        
        cursor.execute("insert into survival_plot (processed_comment_id, project_name, was_td_removed, epoch_interval) values (%s,%s,%s,%s)", (processed_comment_id, project_name, '1', epoch_time_to_remove))

    else:
        
        cursor.execute("insert into survival_plot (processed_comment_id, project_name, was_td_removed, epoch_interval) values (%s,%s,%s,%s)", (processed_comment_id, project_name, '0', epoch_time_in_the_system))

    connection.commit()
    print str(progress_counter) + ' out of :'+ str(total_files_to_process)