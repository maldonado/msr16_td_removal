#!/usr/bin/python

import os
import sys
import psycopg2
import csv

try:
    print "executing"   

    connection = None

    # connect to the database to retrieve the file name linked with the commit
    connection = psycopg2.connect(host='localhost', port='5432', database='comment_classification', user='evermal', password='')
    cursor = connection.cursor()

    csv.field_size_limit(sys.maxsize)

    project_name = 'log4j'
    with open('/Users/evermal/Downloads/log4j.csv', 'rb') as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            if row['commit_hash']:
                commit_hash = row['commit_hash']
            if row['author_name']:
                author_name = row['author_name'].replace('\'', '')
            if row['author_date_unix_timestamp']:
                author_date_unix_timestamp = row['author_date_unix_timestamp']
            if row['author_email']:
                author_email = row['author_email']
            if row['author_date']:
                author_date = row['author_date']
            if row['commit_message']:
                commit_message = row['commit_message'].replace('\'', '')
            if row['fix']:
                fix = row['fix']
            if row['classification']:
                classification = row['classification']
            if row['linked']:
                linked = row['linked']
            if row['contains_bug']:
                contains_bug = row['contains_bug']
            if row['fixes']:
                fixes = row['fixes']
            else:
                fixes = "-"    
            if row['ns']:
                ns = row['ns']
            if row['nd']:
                nd = row['nd']
            if row['nf']:
                nf = row['nf']
            if row['entrophy']:
                entrophy = row['entrophy']
            if row['la']:
                la = row['la']
            if row['ld']:
                ld = row['ld']
            if row['fileschanged']:
                fileschanged = row['fileschanged']
            if row['lt']:
                lt = row['lt']
            if row['ndev']:
                ndev = row['ndev']
            if row['age']:
                age = row['age']
            if row['nuc']:
                nuc = row['nuc']
            if row['exp']:
                exp = row['exp']
            if row['rexp']:
                rexp = row['rexp']
            if row['sexp']:
                sexp = row['sexp']
            if row['glm_probability']:
                glm_probability = row['glm_probability']
            if row['repository_id']:
                repository_id = row['repository_id']
            
            cursor.execute("insert into commit_guru (project_name,commit_hash,author_name,author_date_unix_timestamp,author_email,author_date,commit_message,fix,classification,linked,contains_bug,fixes,ns,nd,nf,entrophy,la,ld,fileschanged,lt,ndev,age,nuc,exp,rexp,sexp,glm_probability,repository_id) values (%s,%s,%s,%s,%s,to_timestamp(%s, 'Dy Mon DD HH24:MI:SS YYYY +-####'),%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", (project_name,commit_hash,author_name,author_date_unix_timestamp,author_email,author_date,commit_message,fix,classification,linked,contains_bug,fixes,ns,nd,nf,entrophy,la,ld,fileschanged,lt,ndev,age,nuc,exp,rexp,sexp,glm_probability,repository_id))

except Exception, e:
    print  e
    connection.rollback()

finally:
    connection.commit()
    print 'done'







