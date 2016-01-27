select a.processed_comment_id, a.version_introduced_author from technical_debt_summary a , technical_debt_summary_temp b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author is null


select a.processed_comment_id, a.version_introduced_author, b.version_introduced_author from technical_debt_summary a , technical_debt_summary_temp b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author is not null and a.version_introduced_author != b.version_introduced_author 


update technical_debt_summary_temp  set version_introduced_author = 'Thomas E. Enebo' where version_introduced_author = 'Thomas Enebo';
update technical_debt_summary_temp  set version_removed_author    = 'Thomas E. Enebo' where version_removed_author    = 'Thomas Enebo';

update technical_debt_summary  set version_introduced_author = 'Marcin Mielyski' where version_introduced_author = 'Marcin Mielżyński';
update technical_debt_summary  set version_removed_author    = 'Marcin Mielyski' where version_removed_author    = 'Marcin Mielżyński';


with temp as (
 select b.processed_comment_id, b.version_introduced_author, b.version_introduced_commit_hash from technical_debt_summary a , technical_debt_summary_temp b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author is not null and a.version_introduced_author != b.version_introduced_author 
)
update technical_debt_summary set version_introduced_author = t.version_introduced_author, version_introduced_commit_hash = t.version_introduced_commit_hash from temp t where t.processed_comment_id = technical_debt_summary.processed_comment_id 



select a.processed_comment_id, a.version_removed_author, b.version_removed_author from technical_debt_summary a , technical_debt_summary_temp b where a.processed_comment_id = b.processed_comment_id and b.version_removed_author is not null and a.version_removed_author != b.version_removed_author and a.version_removed_name != 'not removed' 

pg_restore -U evermal -d comment_classification -t technical_debt_summary -c  /Users/evermal/git/msr16_td_removal/datasets/PSQL/before_merging_authors.dump





with temp as (
 select b.processed_comment_id, b.version_removed_author, b.version_removed_commit_hash from technical_debt_summary a , technical_debt_summary_temp b where a.processed_comment_id = b.processed_comment_id and b.version_removed_author is not null and a.version_removed_author != b.version_removed_author and b.version_removed_author != 'not removed' 
)
update technical_debt_summary set version_removed_author = t.version_removed_author, version_removed_commit_hash = t.version_removed_commit_hash from temp t where t.processed_comment_id = technical_debt_summary.processed_comment_id 

select a.processed_comment_id, a.version_removed_author, b.version_removed_author from technical_debt_summary a , technical_debt_summary_temp b where a.processed_comment_id = b.processed_comment_id and b.version_removed_author is not null and a.version_removed_author != b.version_removed_author and a.version_removed_name != 'not removed' and b.version_removed_author = 'not removed' 


77937 | Charles Oliver Nutter, Thomas Enebo | not removed
79353 | Subramanya Sastry, Thomas E. Enebo  | not removed
77846 | Thomas E. Enebo, Thomas Enebo       | not removed

