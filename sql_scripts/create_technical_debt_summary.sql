-- 1
drop table if exists technical_debt_summary;
CREATE TABLE technical_debt_summary (
  project_name   text,
  version_name   text, 
  version_hash   text,
  file_name      text,
  class_id       integer, 
  class_name     text,
  class_access   text,
  is_class_abstract   text,
  is_class_enum       text,
  is_class_interface  text,
  class_start_line integer, 
  class_end_line   integer,
  processed_comment_id integer, 
  comment_location text,
  comment_type     text, 
  function_signature text,
  comment_start_line integer,
  comment_end_line   integer,
  comment_classification text,
  comment_text text,
  version_introduced_name text, 
  version_introduced_hash text,
  version_introduced_dependencies_number  integer, 
  version_removed_name    text, 
  version_removed_hash    text,
  last_version_that_comment_was_found_name text,
  last_version_that_comment_was_found_hash text,
  last_version_that_comment_was_found_dependencies_number text
);

alter table technical_debt_summary add column version_introduced_commit_hash text;
alter table technical_debt_summary add column version_introduced_author text;
alter table technical_debt_summary add column version_introduced_lines text;
alter table technical_debt_summary add column version_removed_commit_hash text;
alter table technical_debt_summary add column version_removed_author text ;
alter table technical_debt_summary add column version_removed_lines text;
alter table technical_debt_summary add column last_version_that_comment_was_found_lines text;


-- 2
insert into technical_debt_summary (project_name, file_name, class_id, class_name, class_access, is_class_abstract, is_class_enum, is_class_interface, class_start_line, class_end_line, processed_comment_id, comment_location, comment_type, function_signature,comment_start_line,comment_end_line,comment_classification,comment_text) 
    select b.projectname, b.filename, b.id , b.classname, b.access, b.isabstract, b.isenum, b.isinterface, b.startline, b.endline, a.id, a.location, a.type, a.description,   a.startline, a.endline, a.classification , a.commenttext from processed_comment a , comment_class b where a.commentclassid = b.id and b.projectname in ('apache-ant-1.7.0','apache-jmeter-2.10','jruby-1.4.0') and a.classification not in ('WITHOUT_CLASSIFICATION', 'BUG_FIX_COMMENT') order by 1, 2, 4,  9, 5;

-- 3
drop table if exists tags_information;
CREATE TABLE tags_information (
  project_name text, 
  version_name text,
  version_hash text,
  version_date timestamp without time zone, 
  version_order numeric
);

-- 4 
--(18, november 2015 21:23)
-- for some reasson the old tags that I had before was not matching if the current tags (even old ones), so I ran the tag extactor again. 
-- run populate_tags_information.py in each git repository

-- 5
update technical_debt_summary set comment_classification = 'REQUIREMENT' where comment_classification = 'IMPLEMENTATION';
update technical_debt_summary set project_name = 'apache-ant' where project_name = 'apache-ant-1.7.0';
update technical_debt_summary set version_name = 'ANT_170', version_hash = '6bfe7759b0d7662f764a6efd97436b48aa74da2a' where project_name = 'apache-ant';
update technical_debt_summary set project_name = 'apache-jmeter' where project_name = 'apache-jmeter-2.10';
update technical_debt_summary set version_name = 'v2_10', version_hash = '05e19dd900305b43296a89a8fbbd4669b987546b' where project_name = 'apache-jmeter';
update technical_debt_summary set project_name = 'jruby' where project_name = 'jruby-1.4.0';
update technical_debt_summary set version_name = '1.4.0', version_hash = '69fbfa336591fb1a65d4000556b3fedda30baf8f' where project_name = 'jruby';

--6
drop table if exists file_directory_per_version;
CREATE TABLE file_directory_per_version (
  project_name text, 
  version_name text,
  version_hash text,
  version_order text,
  file_name text,
  file_directory text, 
  matched_analyzed_file_directory text
);

--7
alter table file_directory_per_version add column repository_directory text;

--8
drop table if exists file_blame_per_version;
CREATE TABLE file_blame_per_version (
  project_name text, 
  version_name text,
  version_hash text,
  version_order text,
  file_name text,
  file_directory text, 
  commit_short_hash text,
  author_name text,
  author_date timestamp with time zone,
  file_line numeric,
  line_content text
);

create index CONCURRENTLY idx_version_hash_file_name on file_blame_per_version (version_hash, file_name);

-- aux --
pg_dump -Fc -Uevermal comment_classification > ~/Downloads/technical_debt_summary_investigation.dump

-- create script to clean the file directory before copying the csv file
copy (select * from technical_debt_summary) to '/Users/evermal/Downloads/technical_debt_summary.csv' (format csv,  header true);


with temp as (
  select file_directory, version_introduced_name, version_introduced_hash, version_introduced_file_directory, version_removed_name,version_removed_hash,version_removed_file_directory,last_version_that_comment_was_found_name,last_version_that_comment_was_found_hash,last_version_that_comment_was_found_file_directory,last_version_that_comment_was_found_dependencies_number, processed_comment_id
    from technical_debt_summary_temp   
  )
update technical_debt_summary set file_directory = t.file_directory, version_introduced_name = t.version_introduced_name, version_introduced_hash = t.version_introduced_hash, version_introduced_file_directory = t.version_introduced_file_directory, version_removed_name = t.version_removed_name,version_removed_hash = t.version_removed_hash,version_removed_file_directory = t.version_removed_file_directory,last_version_that_comment_was_found_name = t.last_version_that_comment_was_found_name,last_version_that_comment_was_found_hash = t.last_version_that_comment_was_found_hash,last_version_that_comment_was_found_file_directory = t.last_version_that_comment_was_found_file_directory   from temp t where t.processed_comment_id = technical_debt_summary.processed_comment_id;

update technical_debt_summary set version_introduced_name  = null, version_introduced_hash = null, version_removed_name = null, version_removed_hash = null, last_version_that_comment_was_found_name = null, last_version_that_comment_was_found_hash = null;

select * from file_directory_per_version where version_hash = '92dd8b805b5fc4ae4821ad9713840a99bc0ff2eb' and file_name = 'RubyIO.java';

select * from file_directory_per_version where file_name ='IR_Builder.java';


-

drop table if exists time_to_remove_td;
CREATE TABLE time_to_remove_td (
  project_name text,
  processed_comment_id numeric,
  file_name text,
  comment_classification  text,
  version_introduced_name text,
  version_introduced_hash text,
  version_introduced_date timestamp without time zone,
  version_removed_name text,
  version_removed_hash text,
  version_removed_date timestamp without time zone,
  interval_time_to_remove text, 
  epoch_time_to_remove numeric,
  number_of_releases_to_remove numeric
);

insert into time_to_remove_td (project_name, processed_comment_id, file_name, comment_classification, version_introduced_name, version_introduced_hash, version_removed_name, version_removed_hash) 
    select a.project_name, a.processed_comment_id, a.file_name, b.classification, a.version_introduced_name, a.version_introduced_hash, a.version_removed_name, a.version_removed_hash from technical_debt_summary a, processed_comment b where a.processed_comment_id = b.id order by 1,3,2 

with temp as (select version_date, version_name, project_name from tags_information)
update time_to_remove_td set version_introduced_date = t.version_date from temp t where t.version_name = time_to_remove_td.version_introduced_name and t.project_name =  time_to_remove_td.project_name

with temp as (select version_date, version_name, project_name from tags_information)
update time_to_remove_td set version_removed_date = t.version_date from temp t where t.version_name = time_to_remove_td.version_removed_name and t.project_name =  time_to_remove_td.project_name and time_to_remove_td.version_removed_name != 'not_removed'

with temp as (select version_introduced_date, version_removed_date, processed_comment_id from time_to_remove_td)
update time_to_remove_td set interval_time_to_remove = age(t.version_removed_date, t.version_introduced_date) from temp t where t.processed_comment_id = time_to_remove_td.processed_comment_id

drop table if exists git_log_files;
CREATE TABLE git_log_files (
  project_name text,
  file_name text,
  repository_directory  text,
  file_directory text,
  oldest_version_order  text,
  newest_version_order  text
  -- commit_hash text,
  -- author_name text,
  -- author_email text, 
  -- author_date timestamp with time zone,
  -- commit_message text
);

alter table git_log_files drop column commit_hash;
alter table git_log_files drop column author_name;
alter table git_log_files drop column author_email;
alter table git_log_files drop column author_date;
alter table git_log_files drop column commit_message;

drop table if exists git_commit;
CREATE TABLE git_commit (
  project_name text,
  file_name text,
  file_directory text,
  commit_hash text,
  author_name text,
  author_email text, 
  author_date timestamp without time zone,
  commit_message text
);

alter table git_commit add column file_checkout boolean

insert into technical_debt_summary_temp (processed_comment_id) select processed_comment_id from technical_debt_summary 

-- fixing the data
select a.version_introduced_commit_hash, b.version_introduced_commit_hash, a.version_introduced_author,  b.version_introduced_author from technical_debt_summary a, technical_debt_summary_temp b where a.processed_comment_id = b.processed_comment_id and a.version_introduced_commit_hash like '%,%';
with temp as (select version_introduced_commit_hash, processed_comment_id from technical_debt_summary_temp)
update technical_debt_summary set version_introduced_commit_hash = t.version_introduced_commit_hash from temp t where t.processed_comment_id = technical_debt_summary.processed_comment_id 

select a.version_removed_commit_hash, b.version_removed_commit_hash, a.version_removed_author,  b.version_removed_author from technical_debt_summary a, technical_debt_summary_temp b where a.processed_comment_id = b.processed_comment_id and a.version_removed_commit_hash like '%,%';
with temp as (select version_removed_commit_hash, processed_comment_id from technical_debt_summary_temp)
update technical_debt_summary set version_removed_commit_hash = t.version_removed_commit_hash from temp t where t.processed_comment_id = technical_debt_summary.processed_comment_id and technical_debt_summary.version_removed_name != 'not_removed' and t.version_removed_commit_hash != 'not removed'


drop table if exists git_commit_analysis;
CREATE TABLE git_commit_analysis (
  processed_comment_id integer,
  project_name text,
  file_name text,
  version_introduced_name text,
  version_introduced_order numeric,
  version_introduced_author text,
  version_introduced_commit_hash text,
  version_introduced_message text,
  version_removed_name text, 
  version_removed_order numeric,
  version_removed_author text,
  version_removed_commit_hash text,
  version_removed_message text
);


insert into git_commit_analysis (processed_comment_id,project_name,file_name,version_introduced_name,version_introduced_commit_hash,version_introduced_author,version_removed_name,version_removed_author,version_removed_commit_hash)
select processed_comment_id,project_name,file_name,version_introduced_name,version_introduced_commit_hash,version_introduced_author,version_removed_name,version_removed_author,version_removed_commit_hash from technical_debt_summary order by 1

with temp as (select commit_message, commit_hash from git_commit group by 2,1)
update git_commit_analysis set version_introduced_message = t.commit_message from temp t where t.commit_hash = git_commit_analysis.version_introduced_commit_hash 

with temp as (select commit_message, commit_hash from git_commit group by 2,1)
update git_commit_analysis set version_removed_message = t.commit_message from temp t where t.commit_hash = git_commit_analysis.version_removed_commit_hash 

with temp as (select project_name, version_name, version_order from tags_information )
update git_commit_analysis set version_introduced_order = t.version_order from temp t where t.project_name = git_commit_analysis.project_name and t.version_name = git_commit_analysis.version_introduced_name  

with temp as (select project_name, version_name, version_order from tags_information )
update git_commit_analysis set version_removed_order = t.version_order from temp t where t.project_name = git_commit_analysis.project_name and t.version_name = git_commit_analysis.version_removed_name  


