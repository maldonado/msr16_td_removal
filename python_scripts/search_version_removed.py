
# import difflib
import distance
import psycopg2
import sys
import os

connection = None

# connect to the database to retrieve the file name linked with the commit
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

# controal to keep running even after finding the first removal, sometimes the comment can come back to the project and that way we van find it
not_removed_already = True

def parse_line_comment (comment):
    result = []
    for line in comment.split('//'):
        if '' is not line:
            result.append(('//'+line).strip())
    return result

def parse_block_comment (comment):
    result = []
    for line in comment.split('\n'):
        if len(comment.split('\n')) is 1:
            new_line = line.strip()
        else:
            new_line = (line.replace('/**', '').replace('*/', '').replace('/*', '')).strip()
        if '' is not new_line:
            result.append(new_line)
    return result

# cursor.execute("select a.comment_type, a.comment_text, a.project_name, a.version_name, a.file_name, b.version_order, a.processed_comment_id from technical_debt_summary a, tags_information b where a.project_name = b.project_name and a.version_name = b.version_name and a.processed_comment_id = '18402'")
cursor.execute("select a.comment_type, a.comment_text, a.project_name, a.version_name, a.file_name, b.version_order, a.processed_comment_id from technical_debt_summary a, tags_information b where a.project_name = b.project_name and a.version_name = b.version_name and a.version_removed_name = 'not_removed'")
results = cursor.fetchall()

for result in results:
    comment_type =   result[0]
    comment_text =   result[1]
    project_name =   result[2]
    version_name =   result[3]
    file_name    =   result[4]
    version_order =  result[5]
    processed_comment_id = result[6]
 
    if 'MULTLINE' == comment_type or 'LINE' == comment_type:
        comment = parse_line_comment(comment_text)
        # print comment
    else:
        comment = parse_block_comment(comment_text)
        # print comment

    removed_version_name  = 'not_removed'
    removed_version_order = '-'
    removed_version_hash  = '-'
   
    cursor.execute("select version_name, version_order, version_hash from tags_information where project_name = '"+project_name+"' and  version_order >= "+str(version_order)+" order by 2 ASC")
    newer_versions = cursor.fetchall()

    for newer_version in newer_versions:
        # print newer_version
        newer_version_name  = newer_version[0]
        newer_version_order = newer_version[1]
        newer_version_hash  = newer_version[2]

        newer_version_path  = str(newer_version_order) + '.' + newer_version_name
        current_version_path = str(version_order) + '.' + version_name 
        
        print current_version_path
        print newer_version_path

        cursor.execute("select file_directory from file_directory_per_version where project_name = '"+project_name+"' and version_hash = '"+newer_version_hash+"' and file_name = '"+file_name+"'")
        newer_version_path_results = cursor.fetchall()

        if not newer_version_path_results :  
            if not_removed_already == True:
                removed_version_name  = newer_version_name
                removed_version_order = newer_version_order
                removed_version_hash  = newer_version_hash
                not_removed_already = False 
        
        for newer_version_path_result in newer_version_path_results:
            newer_file_directory = newer_version_path_result[0]
            print newer_file_directory

            not_found_in_version = True

            # this is necessary as the file can not exist in a future version
            try:
                with open (newer_file_directory,'r') as f:
                    comment_index = 0
                    # comment_distance_threshold = 0
                    comment_total_distance = 0
                    java_file = []
                    for line in f:
                        value = distance.levenshtein(comment[comment_index], line.strip())
                        # print str(value)+' - '+line 
                        if value < 10:
                            not_found_in_version = False
                            print str(value)+' - '+line 
                            print str(value)+' - '+comment[comment_index]
                            comment_total_distance = comment_total_distance + value
                            comment_index = comment_index + 1
                            if not_removed_already == False:
                                not_removed_already = True 
                            if comment_index == len(comment):
                                break
                print 'total comment distance = '+ str(comment_total_distance)
            except Exception, e:
                # file not found exception
                pass
            
            if not_found_in_version and not_removed_already:
                removed_version_name  = newer_version_name
                removed_version_order = newer_version_order
                removed_version_hash  = newer_version_hash
                not_removed_already = False
            
    if removed_version_name != 'not_removed':
        # get version removed -1 
        cursor.execute("select version_name, version_order, version_hash from tags_information where project_name= '"+project_name+"' and version_order < '"+str(removed_version_order)+"' order by version_order DESC limit 1 ")
        last_version_that_comment_was_found_result = cursor.fetchone()

        last_version_that_comment_was_found_name  = last_version_that_comment_was_found_result[0]
        last_version_that_comment_was_found_order = last_version_that_comment_was_found_result[1]
        last_version_that_comment_was_found_hash  = last_version_that_comment_was_found_result[2]

        cursor.execute("update technical_debt_summary set last_version_that_comment_was_found_name= '"+last_version_that_comment_was_found_name+"', last_version_that_comment_was_found_hash = '"+last_version_that_comment_was_found_hash+"' where processed_comment_id = '"+str(processed_comment_id)+"'")

    print "removed version =  " + removed_version_name + ' ' + str(removed_version_order)
    # print "udpate technical_debt_summary set version_removed_name = '"+removed_version_name+"',  version_removed_hash = '"+removed_version_hash+"' where processed_comment_id = '"+str(processed_comment_id)+"'"
    cursor.execute("update technical_debt_summary set version_removed_name = '"+removed_version_name+"',  version_removed_hash = '"+removed_version_hash+"' where processed_comment_id = '"+str(processed_comment_id)+"'")
    connection.commit()