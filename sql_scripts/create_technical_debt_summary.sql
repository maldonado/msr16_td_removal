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
-- 'apache-ant-1.7.0',
-- 'apache-jmeter-2.10',
-- 'jruby-1.4.0'
insert into technical_debt_summary (project_name, file_name, class_id, class_name, class_access, is_class_abstract, is_class_enum, is_class_interface, class_start_line, class_end_line, processed_comment_id, comment_location, comment_type, function_signature,comment_start_line,comment_end_line,comment_classification,comment_text) 
    select b.projectname, b.filename, b.id , b.classname, b.access, b.isabstract, b.isenum, b.isinterface, b.startline, b.endline, a.id, a.location, a.type, a.description,   a.startline, a.endline, a.classification , a.commenttext from processed_comment a , comment_class b where a.commentclassid = b.id and b.projectname in ('emf-2.4.1','hibernate-distribution-3.3.2.GA','sql12') and a.classification not in ('WITHOUT_CLASSIFICATION', 'BUG_FIX_COMMENT') order by 1, 2, 4,  9, 5;

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

-- after creation of the table
alter table time_to_remove_td add column was_td_removed boolean;
alter table time_to_remove_td add column max_version_analyzed_name text;
alter table time_to_remove_td add column max_version_analyzed_hash text;
alter table time_to_remove_td add column max_version_analyzed_date timestamp;
alter table time_to_remove_td add column interval_time_in_the_system text;
alter table time_to_remove_td add column epoch_time_in_the_system numeric;
alter table time_to_remove_td add column number_of_releases_in_the_system numeric;


insert into time_to_remove_td (project_name, processed_comment_id, file_name, comment_classification, version_introduced_name, version_introduced_hash, version_removed_name, version_removed_hash) 
    select a.project_name, a.processed_comment_id, a.file_name, b.classification, a.version_introduced_name, a.version_introduced_hash, a.version_removed_name, a.version_removed_hash from technical_debt_summary a, processed_comment b where a.processed_comment_id = b.id order by 1,3,2 

with temp as (select version_date, version_name, project_name from tags_information)
update time_to_remove_td set version_introduced_date = t.version_date from temp t where t.version_name = time_to_remove_td.version_introduced_name and t.project_name =  time_to_remove_td.project_name

with temp as (select version_date, version_name, project_name from tags_information)
update time_to_remove_td set version_removed_date = t.version_date from temp t where t.version_name = time_to_remove_td.version_removed_name and t.project_name =  time_to_remove_td.project_name and time_to_remove_td.version_removed_name != 'not_removed'

with temp as (select version_introduced_date, version_removed_date, processed_comment_id from time_to_remove_td)
update time_to_remove_td set interval_time_to_remove = age(t.version_removed_date, t.version_introduced_date) from temp t where t.processed_comment_id = time_to_remove_td.processed_comment_id

-- after creation of the table
update time_to_remove_td set was_td_removed = false where version_removed_name = 'not_removed'
update time_to_remove_td set was_td_removed = true where version_removed_name != 'not_removed'

-- for apache-ant
with temp as (select version_date, version_name, version_hash, project_name from tags_information where project_name = 'apache-ant' and version_order = 66)
update time_to_remove_td set max_version_analyzed_name = t.version_name, max_version_analyzed_hash = t.version_hash, max_version_analyzed_date = t.version_date from temp t where t.project_name = time_to_remove_td.project_name 

-- for apache-jmeter
with temp as (select version_date, version_name, version_hash, project_name from tags_information where project_name = 'apache-jmeter' and version_order = 75)
update time_to_remove_td set max_version_analyzed_name = t.version_name, max_version_analyzed_hash = t.version_hash, max_version_analyzed_date = t.version_date from temp t where t.project_name = time_to_remove_td.project_name 

-- for jruby
with temp as (select version_date, version_name, version_hash, project_name from tags_information where project_name = 'jruby' and version_order = 107)
update time_to_remove_td set max_version_analyzed_name = t.version_name, max_version_analyzed_hash = t.version_hash, max_version_analyzed_date = t.version_date from temp t where t.project_name = time_to_remove_td.project_name 


-- preciso colocar o intervalo que o debt tecnico esta no sistema.
-- para comments que ainda nao foram removidos do sistema essa conta eh feita pelo intervalo do data_max - data introduced.
with temp as (select version_introduced_date, max_version_analyzed_date, processed_comment_id from time_to_remove_td where was_td_removed = false)
update time_to_remove_td set interval_time_in_the_system = age(t.max_version_analyzed_date, t.version_introduced_date) from temp t where t.processed_comment_id = time_to_remove_td.processed_comment_id

-- para comments removidos esse numero eh igual o tempo removido. 
update time_to_remove_td set interval_time_in_the_system = interval_time_to_remove , epoch_time_in_the_system = epoch_time_to_remove , number_of_releases_in_the_system = number_of_releases_to_remove where was_td_removed = true




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

--commit table
drop table commit_guru
CREATE TABLE commit_guru (
  project_name text,
  version text,
  commit_hash text,
  author_name text,
  author_date_unix_timestamp numeric,
  author_email text,
  author_date timestamp,
  commit_message text,
  fix text,
  classification text, 
  linked text, 
  contains_bug text, 
  fixes text, 
  ns numeric,
  nd numeric,
  nf numeric,
  entrophy numeric,
  la numeric,
  ld numeric,
  fileschanged text,
  lt numeric,
  ndev numeric,
  age numeric, 
  nuc numeric,
  exp numeric,
  rexp numeric,
  sexp numeric,
  glm_probability numeric,
  repository_id text
); 

--suvival plot table
drop table survival_plot;
CREATE TABLE survival_plot (
  processed_comment_id numeric,
  project_name text,
  was_td_removed numeric, 
  epoch_interval numeric
); 


-- fixing table with modified scripts (09_search_version_removed) version is still not perfect manual investigation necessary
keep original
78857 IR_ScopeImpl.java
76715 RubyFile.java
77300 RubyModule.java
78016 RubyWarnings.java
76105 RubyArray.java
77649 RubyObject.java
79417 TextAreaReadline.java
288   InputTest.java
17639 ReportTreeModel.java
78655 AbstractVariableCompiler.java
78668 AbstractVariableCompiler.java
17508 DataSet.java
17697 JTLData.java
17670 AbstractTable.java
17696 Table.java
17413 ReportMenuBar.java

keep temp
2013  Jar.java
78171 ASTCompiler.java
1811  CopyPath.java
79431 ASTInterpreter.java
2545  Javadoc.java
76720 RubyFile.java
4276  WLJspc.java
77263 RubyModule.java
79426 ASTInterpreter.java
79185 CodeVersion.java
79312 Range.java
398   JUnitTestRunnerTest.java
1173  UnknownElement.java
79309 StringLiteral.java
12254 Sample.java
14875 HTTPHC4Impl.java
1285 DirectoryScanner.java

investigate 
18704

*****************************************************************************************************************************
select a.processed_comment_id , a.project_name, a.file_name, a.class_name,  a.version_removed_name , a.comment_text,  b.version_removed_name from technical_debt_summary a , technical_debt_summary_temp b where a.processed_comment_id = b.processed_comment_id and a.version_removed_name != b.version_removed_name and a.processed_comment_id in ('2013','17697','78171','1811','79431','2545','76720','4276','17413','77263','79426','79185','79312','398','1173','79309','12254','17696','17508','14875','17670')
update technical_debt_summary_temp set version_removed_name = null, version_removed_hash =  null where processed_comment_id in ('78857','76715','77300','78016','76105','77649','79417','288','17639','78655','78668','17508','17697','17670','17696','17413')
update technical_debt_summary_temp set version_removed_name = null, version_removed_hash =  null where processed_comment_id not in ('2013','78171','1811','79431','2545','76720','4276','77263','79426','79185','79312','398','1173','79309','12254','14875','1285')

select processed_comment_id, version_removed_name , version_removed_hash from technical_debt_summary_temp where version_removed_name != 'not_removed' and processed_comment_id in ('2013','78171','1811','79431','2545','76720','4276','77263','79426','79185','79312','398','1173','79309','12254','14875','1285')
update technical_debt_summary_temp set last_version_that_comment_was_found_name = '1.7.22' , last_version_that_comment_was_found_hash = 'c28f4926e498e07a0d141846a3f04e13c3c125cd' where processed_comment_id in ('78171','79431','79426','79312','79185');
update technical_debt_summary_temp set last_version_that_comment_was_found_name = '1.7.0' , last_version_that_comment_was_found_hash = 'ff1ebbe9317706fd44e5be7631011bde8f54a935' where processed_comment_id in ('76720');
update technical_debt_summary_temp set last_version_that_comment_was_found_name = 'ANT_180_RC1' , last_version_that_comment_was_found_hash = '03ce8558d603de7b653145c0efde5f719e78a71a' where processed_comment_id in ('1285');

with temp as (select processed_comment_id, version_removed_name, version_removed_hash, last_version_that_comment_was_found_name, last_version_that_comment_was_found_hash from technical_debt_summary_temp where  version_removed_name is not null )
update technical_debt_summary set version_removed_name = t.version_removed_name, version_removed_hash= t.version_removed_hash, last_version_that_comment_was_found_name = t.last_version_that_comment_was_found_name , last_version_that_comment_was_found_hash = t.last_version_that_comment_was_found_hash from temp t where t.processed_comment_id = technical_debt_summary.processed_comment_id 

select * from technical_debt_summary where version_removed_name = 'not_removed' and version_removed_author is not null;
update technical_debt_summary set version_removed_commit_hash = null, version_removed_author= null where version_removed_name = 'not_removed'  and version_removed_author is not null;
*****************************************************************************************************************************

Package test 
1- deleting old information 

update technical_debt_summary set version_introduced_name = null, version_introduced_hash = null, version_introduced_dependencies_number = null, version_removed_name = null, version_removed_hash = null, last_version_that_comment_was_found_name = null, last_version_that_comment_was_found_hash = null, last_version_that_comment_was_found_dependencies_number = null, version_introduced_commit_hash = null, version_introduced_author = null, version_introduced_lines = null, version_removed_commit_hash = null, version_removed_author = null, version_removed_lines = null, last_version_that_comment_was_found_lines = null where processed_comment_id in ('18704','18047','18046','17997');
update technical_debt_summary_temp set version_introduced_name = null, version_introduced_hash = null, version_introduced_dependencies_number = null, version_removed_name = null, version_removed_hash = null, last_version_that_comment_was_found_name = null, last_version_that_comment_was_found_hash = null, last_version_that_comment_was_found_dependencies_number = null, version_introduced_commit_hash = null, version_introduced_author = null, version_introduced_lines = null, version_removed_commit_hash = null, version_removed_author = null, version_removed_lines = null, last_version_that_comment_was_found_lines = null where processed_comment_id in ('18704','18047','18046','17997');



with temp as (select processed_comment_id , version_introduced_commit_hash, version_introduced_author, version_introduced_lines, version_removed_commit_hash, version_removed_author, version_removed_lines, last_version_that_comment_was_found_lines from technical_debt_summary_temp)
update technical_debt_summary set version_introduced_commit_hash = t.version_introduced_commit_hash, version_introduced_author = t.version_introduced_author, version_introduced_lines = t.version_introduced_lines, version_removed_commit_hash = t.version_removed_commit_hash, version_removed_author = t.version_removed_author, version_removed_lines = t.version_removed_lines, last_version_that_comment_was_found_lines = t.last_version_that_comment_was_found_lines from temp t where t.processed_comment_id = technical_debt_summary.processed_comment_id

 
with temp as (select processed_comment_id , version_introduced_commit_hash, version_introduced_author, version_removed_commit_hash, version_removed_author from technical_debt_summary_temp where processed_comment_id in ('80216','79669','78668','77649','78675','77300','79082','17577','79027','4913','15165','78961','78655','81750','79042','78683','79820'))
update technical_debt_summary set version_introduced_commit_hash = t.version_introduced_commit_hash, version_introduced_author = t.version_introduced_author, version_removed_commit_hash = t.version_removed_commit_hash, version_removed_author = t.version_removed_author  from temp t where t.processed_comment_id = technical_debt_summary.processed_comment_id
update technical_debt_summary set version_removed_commit_hash = '564c53fe61a99b37894d7e1d8f94016cf2537b59' , version_removed_author = 'kares' where processed_comment_id = '77709'
  update technical_debt_summary set version_introduced_author = 'Subramanya Sastry', version_introduced_commit_hash = 'ddaf4c565c871ce4a59cf23683c59bcc2429fec9', version_removed_commit_hash = '53945eb6cd55a8e2a78c00f7166574fc09d4e845' , version_removed_author = 'Subramanya Sastry' where processed_comment_id = '79353'


