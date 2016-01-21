# import difflib
# import distance
import psycopg2
import sys
import os

connection = None

# connect to the database to retrieve the file name linked with the commit
connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
cursor = connection.cursor()

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

# cursor.execute("select a.comment_type, a.comment_text, a.project_name, a.version_name, a.file_name, b.version_order, a.processed_comment_id from technical_debt_summary a, tags_information b where a.project_name = b.project_name and a.version_name = b.version_name and a.version_introduced_name = a.version_removed_name  ")
cursor.execute("select a.comment_type, a.comment_text, a.project_name, a.version_name, a.file_name, b.version_order, a.processed_comment_id from technical_debt_summary a, tags_information b where a.project_name = b.project_name and a.version_name = b.version_name and a.processed_comment_id = 77649  ")
results = cursor.fetchall()

for result in results:
    comment_type =   result[0]
    comment_text =   "* FIXME: Should this be renamed to match its ruby name?"
    project_name =   result[2]
    version_name =   result[3]
    file_name    = result[4]
    version_order =  result[5]
    processed_comment_id = result[6]
 
    if 'MULTLINE' == comment_type or 'LINE' == comment_type:
        comment = parse_line_comment(comment_text)
        # print comment
    else:
        comment = parse_block_comment(comment_text)
        # print comment

    cursor.execute("select version_name, version_order, version_hash from tags_information where project_name = '"+project_name+"' and  version_order <= "+str(version_order)+" order by 2 DESC")
    older_versions = cursor.fetchall()

    introduced_version_name  = older_versions[0][0]
    introduced_version_order = older_versions[0][1]
    introduced_version_hash  = older_versions[0][2]
    
    for older_version in older_versions:
        # print older_version
        older_version_name  = older_version[0]
        older_version_order = older_version[1]
        older_version_hash  = older_version[2]

        current_version_path = str(version_order) + '.' + version_name 
        older_version_path = str(older_version_order) + '.' + older_version_name 
        # print current_version_path
        # print older_version_path

        cursor.execute("select file_directory from file_directory_per_version where project_name = '"+project_name+"' and version_hash = '"+older_version_hash+"' and file_name = '"+file_name+"'")
        older_version_path_results = cursor.fetchall()
        
        for older_version_path_result in older_version_path_results:
            older_file_directory = older_version_path_result[0]
            # print older_file_directory

            # older_file_directory = file_directory.replace(current_version_path, older_version_path)
            print older_file_directory

            found_in_version = False
            try:
                with open (older_file_directory,'r') as f:
                    comment_index = 0
                    # comment_distance_threshold = 0
                    # comment_total_distance = 0
                    java_file = []
                    for line in f:
                        if comment[comment_index] in line.strip():
                        # value = distance.levenshtein(comment[comment_index], line.strip())
                        # print str(value)+' - '+line 
                        # if value < 10:
                            found_in_version = True
                            print line 
                            print comment[comment_index]
                            # comment_total_distance = comment_total_distance + value
                            comment_index = comment_index + 1
                            if comment_index == len(comment):
                                break

                    if found_in_version:
                        introduced_version_name  = older_version_name
                        introduced_version_order = older_version_order
                        introduced_version_hash  = older_version_hash
                        version_introduced_file_directory = older_file_directory

                print 'total comment distance = '+ str(comment_total_distance)

            except Exception, e:
                pass
            
    print "introduced version =  " + introduced_version_name + ' ' + str(introduced_version_order)
    # print "udpate technical_debt_summary set version_introduced_name = '"+introduced_version_name+"',  version_introduced_hash = '"+introduced_version_hash+"', version_introduced_file_directory = '"+version_introduced_file_directory+"' where processed_comment_id = '"+str(processed_comment_id)+"'"
    cursor.execute("update technical_debt_summary set version_introduced_name = '"+introduced_version_name+"',  version_introduced_hash = '"+introduced_version_hash+"' where processed_comment_id = '"+str(processed_comment_id)+"'")
    connection.commit()