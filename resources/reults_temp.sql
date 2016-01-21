
select project_name, file_name , version_introduced_author, version_removed_author from technical_debt_summary where version_removed_name != 'not_removed' order by 1,2;

select a.project_name, a.file_name, a.version_removed_name, a.version_removed_hash, b.repository_directory, a.comment_text, a.processed_comment_id, a.comment_type  from technical_debt_summary a , file_directory_per_version b where a.last_version_that_comment_was_found_hash = b.version_hash and a.file_name =  b.file_name and a.version_removed_author = '' and a.version_removed_name != 'not_removed'   order by 1,2 ;


select a.project_name, a.file_name, a.version_removed_name, a.version_removed_hash,  a.processed_comment_id, a.comment_type  from technical_debt_summary a where a.version_removed_author = '' and a.version_removed_name != 'not_removed'   order by 1,2 ;


select a.project_name, a.file_name, a.version_removed_name, a.version_removed_hash,  a.processed_comment_id, a.comment_type  from technical_debt_summary a where a.version_removed_author is null and a.version_removed_name != 'not_removed'   order by 1,2 ;


exceptions 
select count(*) from technical_debt_summary where version_removed_name != 'not_removed' and version_introduced_author is null or version_introduced_author = '' ;
select count(*) from technical_debt_summary where version_removed_name != 'not_removed' and version_removed_author is null or version_removed_author = '' ;

select a.project_name, a.file_name, a.version_removed_name, a.version_removed_hash, b.repository_directory, a.comment_text, a.processed_comment_id, a.comment_type  from technical_debt_summary a , file_directory_per_version b where a.last_version_that_comment_was_found_hash = b.version_hash and a.file_name =  b.file_name and version_removed_name != 'not_removed' and version_introduced_author is null or version_introduced_author = '' ;
select a.project_name, a.file_name, a.version_removed_name, a.version_removed_hash, b.repository_directory, a.comment_text, a.processed_comment_id, a.comment_type  from technical_debt_summary a , file_directory_per_version b where a.last_version_that_comment_was_found_hash = b.version_hash and a.file_name =  b.file_name and version_removed_name != 'not_removed' and version_removed_author is null or version_removed_author = '' ;

select * from technical_debt_summary where version_removed_name != 'not_removed' and version_removed_author is null or version_removed_author = '' ;    

update technical_debt_summary set 
    version_introduced_commit_hash = 'd9e4470c',
    version_introduced_author = 'Sebastian Bazley',
    version_introduced_lines  = '392',
    
    version_introduced_name = 'v2_6_RC1',
    version_introduced_hash = '56ce44dcb6567c5600fc976a79b4be8650d52381',

    version_removed_hash =  '-',
    version_removed_name =  'not_removed',

    last_version_that_comment_was_found_name = '',
    last_version_that_comment_was_found_hash = '',
    
    version_removed_commit_hash = '',
    version_removed_author = '',
    version_removed_lines  = '',
    last_version_that_comment_was_found_lines = ''
where
    processed_comment_id = 8527;



RQ1 - How much of self-admitted technical debt gets removed ? [repeat]
(consistency of code and comment co-change) 

select count(*) from technical_debt_summary;
1127

select count(*) from technical_debt_summary where version_removed_name = 'not_removed';
604

select count(*) from technical_debt_summary where version_removed_name != 'not_removed';
523

RQ2 - How long does it take to remove technical debt in case of self-removal?
Determine number of versions and time it takes to remove TD

All Projects
select avg(number_of_releases_to_remove) from time_to_remove_td where version_removed_name != 'not_removed';
avg | 48.5487571701720841 

select project_name, avg(number_of_releases_to_remove) from time_to_remove_td where version_removed_name != 'not_removed' group by 1 ;
 project_name  |         avg
---------------+---------------------
 jruby         | 60.5910224438902743
 apache-ant    | 14.4000000000000000
 apache-jmeter |  7.9019607843137255

select avg(epoch_time_to_remove) from time_to_remove_td where version_removed_name != 'not_removed';
avg | 128858016.70363289     seconds
    1491.41223036            days 
    49.032677126911252685    months


select project_name, avg(epoch_time_to_remove)/86400 from time_to_remove_td where version_removed_name != 'not_removed' group by 1;
 project_name  |       days
---------------+-----------------------
 jruby         | 1834.8585306121270833
 apache-ant    | 1419.9928836805555556
 apache-jmeter |  155.2006669843863471


-- can one observe difference in self-removal rate/speed between different kinds of technical debt?

All projects
select comment_classification, avg(epoch_time_to_remove)/86400 from time_to_remove_td where version_removed_name != 'not_removed' group by 1;
 comment_classification |       days
------------------------+-----------------------
 IMPLEMENTATION         | 1623.1703026620370370
 TEST                   |  374.6666468253968254
 DESIGN                 | 1252.6249647844565972
 DEFECT                 | 2026.5777975685608796

 Apache ant
select comment_classification, avg(epoch_time_to_remove)/86400 from time_to_remove_td where version_removed_name != 'not_removed' and project_name = 'apache-ant' group by 1;
 comment_classification |       days
------------------------+-----------------------
 TEST                   |  860.7374131944444444
 DESIGN                 | 1346.6606221064814815
 DEFECT                 | 2565.9064467592592593

Apache jmeter
select comment_classification, avg(epoch_time_to_remove)/86400 from time_to_remove_td where version_removed_name != 'not_removed' and project_name = 'apache-jmeter' group by 1;
 comment_classification |          days
------------------------+----------------------------
 IMPLEMENTATION         | 0.000000000000000000000000
 TEST                   | 0.000000000000000000000000
 DESIGN                 |       146.5301090730676328
 DEFECT                 |       335.6711425264550265

 Jruby
 select comment_classification, avg(epoch_time_to_remove)/86400 from time_to_remove_td where version_removed_name != 'not_removed' and project_name = 'jruby' group by 1;
 comment_classification |       days
------------------------+-----------------------
 IMPLEMENTATION         | 1664.7900540123457176
 TEST                   |  225.2979253472222222
 DESIGN                 | 1761.5394633037224537
 DEFECT                 | 2114.7555786088342593

RQ3 - Who removes it ? -- non-self-removal?

same dev that introduced it or another dev. 
experience/role of the person who removes it

RQ4 - Why these TD's are removed and why some of them does not get removed ?
look into the commit (messages) and issue trackers to see the reason? - corrective , non functional, feature addition ... 
use topic modeling to see if we can get any specific patterns

stats




select a.file_name,a.version_introduced_name, a.version_removed_name, b.repository_directory, a.comment_text  from technical_debt_summary a , file_directory_per_version b where a.last_version_that_comment_was_found_hash = b.version_hash and a.file_name =  b.file_name and a.version_introduced_name = a.version_removed_name and a.version_removed_name != 'not_removed'  and a.project_name= 'apache-ant' order by 1,2 ;











