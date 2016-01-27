
-- show all comments that the TD was removed
select project_name, file_name , version_introduced_author, version_removed_author from technical_debt_summary where version_removed_name != 'not_removed' order by 1,2;

RQ1 - How much of self-admitted technical debt gets removed ? [repeat]
(consistency of code and comment co-change) 

-- total of TD comments
select count(*) from technical_debt_summary;
1127

-- found in 491 files:
select count(distinct(file_name)) from technical_debt_summary;
491

-- of these comments, 439 was removed
select count(*) from technical_debt_summary where version_removed_name != 'not_removed';
439

--  still 688 technical debt comments remains in the code
select count(*) from technical_debt_summary where version_removed_name = 'not_removed';
688

-- meaning that 376 files remains with technical debt (make the percentage of the total , separate per project)
select count(distinct(file_name)) from technical_debt_summary where version_removed_name = 'not_removed';
376

-- and 155 files got technical debt removed from them (which does not mean that more td comments were not introduced) 
select count(distinct(file_name)) from technical_debt_summary where version_removed_name != 'not_removed';
155

RQ2 - How long does it take to remove technical debt in case of self-removal?

-- average days from self removal (plot these values)
select  avg(a.epoch_time_to_remove)/86400 from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author = b.version_removed_author;
 ?column?
-----------------------
 1833.9384720865885417

-- average days from self removal per project (plot these values)
select  a.project_name, avg(a.epoch_time_to_remove)/86400 from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author = b.version_removed_author group by 1  
project_name  |       ?column?
---------------+-----------------------
 jruby         | 1871.7270381191658565
 apache-ant    |  730.6279629629629630
 apache-jmeter |  978.7876554232804233

-- average days from NON self removal (plot these values)
select  avg(a.epoch_time_to_remove)/86400 from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author != b.version_removed_author and b.version_removed_name != 'not_removed' 
       ?column?
-----------------------
 1878.7273883070229167


-- average days from NON self removal per project (plot these values)
select  a.project_name, avg(a.epoch_time_to_remove)/86400 from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author != b.version_removed_author and b.version_removed_name != 'not_removed'  group by 1  
project_name  |       ?column?
---------------+-----------------------
 apache-ant    | 1991.5555823206018519
 jruby         | 1942.5938311708089120
 apache-jmeter | 1111.1973603395061728

-- which tells us that NON self removal actually takes longer than self removal

-- Determine number of versions and time it takes to remove TD (this needs to be normalized because we have different number of versions from different projects)
-- All Projects
select avg(a.number_of_releases_to_remove) from time_to_remove_td a,  where version_removed_name != 'not_removed';
 ---------------------
 60.5034168564920273

-- All projects self removal
select avg(number_of_releases_to_remove) from time_to_remove_td a,  technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author = b.version_removed_author 
--------------------
 61.5546875000000000

-- per project self removal
select a.project_name, avg(a.number_of_releases_to_remove) from time_to_remove_td a,  technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author = b.version_removed_author group by 1 ;
 project_name  |         avg
---------------+---------------------
 jruby         | 62.4512195121951220
 apache-ant    |  5.0000000000000000
 apache-jmeter | 54.2857142857142857

-- All projects NON self removal
select avg(number_of_releases_to_remove) from time_to_remove_td a,  technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author != b.version_removed_author and b.version_removed_name != 'not_removed'
--------------------- (these averages are meaningless)
 59.0327868852459016

-- per project NON self removal
select a.project_name, avg(a.number_of_releases_to_remove) from time_to_remove_td a,  technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author != b.version_removed_author and b.version_removed_name != 'not_removed' group by 1 ;
 ---------------+---------------------
 apache-ant    | 21.1250000000000000
 jruby         | 63.0855263157894737
 apache-jmeter | 58.4000000000000000

-- can one observe difference in self-removal rate/speed between different kinds of technical debt?

All projects
select comment_classification, avg(epoch_time_to_remove)/86400 from time_to_remove_td where version_removed_name != 'not_removed' group by 1;
 comment_classification |       days
------------------------+-----------------------
 IMPLEMENTATION         | 1686.4107040644540509
 TEST                   | 1182.8492997685185185
 DESIGN                 | 1773.5135108190271991
 DEFECT                 | 2123.8535318518518519

 Apache ant
select comment_classification, avg(epoch_time_to_remove)/86400 from time_to_remove_td where version_removed_name != 'not_removed' and project_name = 'apache-ant' group by 1;
 comment_classification |       days
------------------------+-----------------------
 TEST                   |  860.7374131944444444
 DESIGN                 | 1813.5656990740740741
 DEFECT                 | 2565.9064467592592593
 -- (deffect debt being the one that takes more time to be removed is counter intuitive )

Apache jmeter
select comment_classification, avg(epoch_time_to_remove)/86400 from time_to_remove_td where version_removed_name != 'not_removed' and project_name = 'apache-jmeter' group by 1;
 comment_classification |          days
------------------------+----------------------------
 DESIGN                 | 1058.4887997685185185
 DEFECT                 | 1174.8489988425925926

 Jruby
 select comment_classification, avg(epoch_time_to_remove)/86400 from time_to_remove_td where version_removed_name != 'not_removed' and project_name = 'jruby' group by 1;
 comment_classification |       days
------------------------+-----------------------
IMPLEMENTATION          | 1686.4107040644540509
 TEST                   | 1504.9611863425925926
 DESIGN                 | 1842.7039724209689815
 DEFECT                 | 2132.2328974403122685

RQ3 - Who removes it ? -- non-self-removal?

same dev that introduced it or another dev. 
-- number of TD comments removed by the same author 
select count(*) from technical_debt_summary where version_removed_name != 'not_removed' and version_introduced_author = version_removed_author;
 count
-------
   256

-- number of TD comments removed by different authors 
select count(*) from technical_debt_summary where version_removed_name != 'not_removed' and version_introduced_author != version_removed_author;
 count
-------
   183

-- number of TD comments removed by the same author per project (put this in percentage , how many TD comment we have per project)
select project_name, count(*) from technical_debt_summary where version_removed_name != 'not_removed' and version_introduced_author = version_removed_author group by 1;
 project_name  | count
---------------+-------
 jruby         |   246
 apache-ant    |     3
 apache-jmeter |     7

-- number of TD comments removed by different authors per project
select project_name, count(*) from technical_debt_summary where version_removed_name != 'not_removed' and version_introduced_author != version_removed_author group by 1 ;
project_name  | count
---------------+-------
 apache-ant    |    16
 jruby         |   152
 apache-jmeter |    15


-- different devs that introduced TD comments (compare with the total devs that participes in the project)
 select project_name , count(distinct(version_introduced_author)) from technical_debt_summary group by 1;
 project_name  | count
---------------+-------
 apache-ant    |    19
 apache-jmeter |    16
 jruby         |    15

-- create a statistic like the top 5 contributors inserted more than x percent of the debt
select project_name , version_introduced_author, count(*) from technical_debt_summary group by 1,2 order by 1,3 desc; 
project_name  | version_introduced_author | count
---------------+---------------------------+-------
 apache-ant    | Stefan Bodewig            |    39
 apache-ant    | Matthew Jason Benson      |    11
 apache-ant    | Costin Manolache          |    11
 apache-ant    | Conor MacNeill            |    10
 apache-ant    | Peter Donald              |     9
 apache-ant    | Peter Reilly              |     7
 apache-ant    | Antoine Levy-Lambert      |     7
 apache-ant    | Stephane Bailliez         |     6
 apache-ant    | Jesse N. Glick            |     5
 apache-ant    | Charles Oliver Nutter     |     5
 apache-ant    | Steve Loughran            |     4
 apache-ant    | Magesh Umasankar          |     4
 apache-ant    | Sam Ruby                  |     3
 apache-ant    | Jan Materne               |     3
 apache-ant    | Jon Skeet                 |     2
 apache-ant    | Sebastian Bazley          |     2
 apache-ant    | Erik Hatcher              |     1
 apache-ant    | Vladimir Sizikov          |     1
 apache-ant    | Jacobus Martinus Kruithof |     1
 apache-jmeter | Sebastian Bazley          |   302
 apache-jmeter | Philippe Mouawad          |    24
 apache-jmeter | Jordi Salvat i Alabart    |    19
 apache-jmeter | Michael Stover            |     4
 apache-jmeter | Jeremy Arnold             |     4
 apache-jmeter | Alf Hoegemark             |     3
 apache-jmeter | Bruno Demion              |     3
 apache-jmeter | Charles Oliver Nutter     |     3
 apache-jmeter | Peter Lin                 |     3
 apache-jmeter | Davanum Srinivas          |     2
 apache-jmeter | Sam Ruby                  |     2
 apache-jmeter | Stefan Bodewig            |     1
 apache-jmeter | Antoine Levy-Lambert      |     1
 apache-jmeter | Thomas E. Enebo           |     1
 apache-jmeter | Scott Eade                |     1
 apache-jmeter | Bill Dortch               |     1
 jruby         | Charles Oliver Nutter     |   327
 jruby         | Thomas E. Enebo           |   111
 jruby         | Vladimir Sizikov          |    52
 jruby         | Subramanya Sastry         |    43
 jruby         | Ola Bini                  |    27
 jruby         | Marcin Mielyski           |    23
 jruby         | Bill Dortch               |    20
 jruby         | Nick Sieger               |     4
 jruby         | Anders Bengtsson          |     4
 jruby         | Stefan Matthias Aust      |     4
 jruby         | Hiro Asari                |     2
 jruby         | MenTaLguY                 |     2
 jruby         | Wayne Meissner            |     1
 jruby         | Jan Arne Petersen         |     1
 jruby         | Sam Ruby                  |     1


-- different devs that removed TD comments (compare with the total devs that participes in the project)
select project_name , count(distinct(version_removed_author)) from technical_debt_summary where version_removed_name != 'not_removed' group by 1;
 project_name  | count
---------------+-------
 apache-ant    |    10
 apache-jmeter |     3
 jruby         |    26

select project_name , version_removed_author, count(*) from technical_debt_summary where version_removed_name != 'not_removed' group by 1,2 order by 1,3 desc; 
---------------+---------------------------+-------
 apache-ant    | Stefan Bodewig            |     6
 apache-ant    | Peter Reilly              |     4
 apache-ant    | Matthew Jason Benson      |     2
 apache-ant    | Nicolas Lalevee           |     1
 apache-ant    | Kevin Jackson             |     1
 apache-ant    | Jacobus Martinus Kruithof |     1
 apache-ant    | Jesse N. Glick            |     1
 apache-ant    | Antoine Levy-Lambert      |     1
 apache-ant    | Steve Loughran            |     1
 apache-ant    | Jan Materne               |     1
 apache-jmeter | Philippe Mouawad          |    11
 apache-jmeter | Sebastian Bazley          |    10
 apache-jmeter | Bruno Demion              |     1
 jruby         | Charles Oliver Nutter     |   244
 jruby         | Thomas E. Enebo           |    64
 jruby         | Subramanya Sastry         |    46
 jruby         | kares                     |     7
 jruby         | Hiro Asari                |     6
 jruby         | Christian Meier           |     3
 jruby         | Uwe Kubosch               |     3
 jruby         | David Calavera            |     3
 jruby         | Daniel Lucraft            |     2
 jruby         | Alex Tambellini           |     2
 jruby         | Chris Seaton              |     2
 jruby         | Vladimir Sizikov          |     2
 jruby         | Kevin Menard              |     1
 jruby         | Tim Felgentreff           |     1
 jruby         | Nicholas Jefferson        |     1
 jruby         | Lin Jen-Shin              |     1
 jruby         | Douglas Campos            |     1
 jruby         | Nick Sieger               |     1
 jruby         | kiichi                    |     1
 jruby         | Benoit Daloze             |     1
 jruby         | Dmitry Ratnikov           |     1
 jruby         | Lucas Allan Amorim        |     1
 jruby         | tduehr                    |     1
 jruby         | Hiroshi Nakamura          |     1
 jruby         | Rohit Arondekar           |     1
 jruby         | Pavel Rosick              |     1

(count the number of commits that the authors of the top five appears and make a percentage of the number of commits in the project)
experience/role of the person who removes it 


RQ4 - Why these TD's are removed and why some of them does not get removed ?
look into the commit (messages) and issue trackers to see the reason? - corrective , non functional, feature addition ... 
use topic modeling to see if we can get any specific patterns

stats




select a.file_name,a.version_introduced_name, a.version_removed_name, b.repository_directory, a.comment_text  from technical_debt_summary a , file_directory_per_version b where a.last_version_that_comment_was_found_hash = b.version_hash and a.file_name =  b.file_name and a.version_introduced_name = a.version_removed_name and a.version_removed_name != 'not_removed'  and a.project_name= 'apache-ant' order by 1,2 ;











