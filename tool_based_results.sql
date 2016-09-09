#################################################################################################################
table: repositories

  1 | abdera | trunk         | git://git.apache.org/abdera.git             | 2016-03-02 16:11:31.269583
  2 | ant    | master        | https://github.com/apache/ant.git           | 2016-03-15 14:05:07.444965
  3 | jmeter | trunk         | https://github.com/apache/jmeter.git        | 2016-03-15 14:06:17.311904
  4 | jruby  | master        | https://github.com/jruby/jruby.git          | 2016-03-15 14:07:18.291681
  5 | camel  | master        | https://github.com/apache/camel             | 2016-03-29 15:42:13.551677
  6 | hadoop | trunk         | https://github.com/apache/hadoop            | 2016-03-29 15:43:32.239268
  7 | tomcat | trunk         | https://github.com/apache/tomcat            | 2016-03-29 15:44:26.829478
  8 | log4j  | trunk         | https://github.com/apache/log4j             | 2016-03-29 15:45:07.198918
  9 | gerrit | master        | https://github.com/gerrit-review/gerrit.git | 2016-04-05 14:26:39.899985
#################################################################################################################


#################################################################################################################
-- RQ1. How much self-admitted technical debt gets removed?
#################################################################################################################

-- 1- total number of self-admitted technical debt found per project:
select repository_id, count(*) from processed_comments where  is_introduced_version = true group by 1 order by 1 ; 
-- 2- total number of self-admitted technical debt removed per project:
 select repository_id, count(*) from processed_comments where  is_introduced_version = true and has_removed_version = true  group by 1 order by 1 ;
-- 3  resulting table:

repository_id     TD      Removed TD
2             |   854  |   728
3             |  1260  |   981
5             |  4331  |  3926
6             |  1164  |   472
7             |  1317  |  1009
8             |   135  |   118
9             |   271  |   208

#################################################################################################################
-- RQ2. Who removes self-admitted technical debt? Is it most likely to be self-removed or removed by others?
#################################################################################################################

-- 1- total number of self-admitted technical debt removed per project:
 select repository_id, count(*) from processed_comments where  is_introduced_version = true and has_removed_version = true  group by 1 order by 1 ;
-- 2- total number of self-admitted technical debt self-removed per project:
select repository_id, count(*) from processed_comments where  is_introduced_version = true and has_removed_version = true and introduced_version_author = removed_version_author group by 1 order by 1 ;
-- 3- total number of self-admitted technical debt non self-removed per project:
select repository_id, count(*) from processed_comments where  is_introduced_version = true and has_removed_version = true and introduced_version_author != removed_version_author group by 1 order by 1 ;
-- 4- resulting table:

repository_id    Removed TD   self-removed      non self-removal
2             |   728       |    372          |   356
3             |   981       |    663          |   318
5             |  3926       |   2652          |  1274
6             |   472       |    116          |   356
7             |  1009       |    578          |   431
8             |   118       |     72          |    46
9             |   208       |    149          |    59


################################################################################################################
-- RQ3. How long does self-admitted technical debt survive in a project?
#################################################################################################################
-- 1- Use the r script to select the results per project

repository_id    Removed TD  median in days  self-removed median in days non self-removal median in days
2             |   728       | 91.91         |    372     |  54.9      |   356           |   179.0
3             |   981       | 227.99        |    663     |  148.8     |   318           |   385.9
5             |  3926       | 18.16         |   2652     |  18.1      |  1274           |   28.0
6             |   472       | 159.03        |    116     |  52.9      |   356           |   376.7
7             |  1009       | 164.90        |    578     |  8.7       |   431           |   1301.4
8             |   118       | 172.75        |     72     |  68.0      |    46           |   830.7
9             |   208       | 10.84         |    149     |  10.7      |    59           |   190.1
                              30.05                         18.1                            126.9  

#################################################################################################################
-- RQ4. What activities lead to the removal of self-admitted technical debt?
#################################################################################################################
-- 1- (total) numer of self-admitted technical debt removals that was made by file edidion or by file removal 
select repository_id , removal_type, count(*) from processed_comments where has_removed_version is true group by 1,2 order by 1

repository_id   Removed TD  FILE EDITION   % FILE EDITION    FILE_REMOVAL  % FILE_REMOVAL
2             |  728       |   393       |   53.9          |    335       | 46.0
3             |  981       |   759       |   77.3          |    222       | 22.6  
5             | 3926       |  3839       |   97.7          |     87       | 2.2
6             |  472       |   382       |   80.9          |     90       | 19.0
7             | 1009       |   659       |   65.3          |    350       | 34.6
8             |  118       |    65       |   55.0          |     53       | 44.9
9             |  208       |   194       |   93.2          |     14       | 6.7
                                             74.8                           25.2

-- 2- (self-removal) numer of self-admitted technical debt removals that was made by file edidion or by file removal 
select repository_id , removal_type, count(*) from processed_comments where has_removed_version is true and introduced_version_author = removed_version_author group by 1,2 order by 1

repository_id  self-removed  FILE EDITION   % FILE EDITION    FILE_REMOVAL  % FILE_REMOVAL
2             |  372        |    173      |   46.5          |   199        |  53.4
3             |  663        |    514      |   77.5          |   149        |  22.4
5             | 2652        |   2608      |   98.3          |    44        |  1.6
6             |  116        |    114      |   98.2          |     2        |  1.7
7             |  578        |    424      |   73.3          |   154        |  26.6
8             |   72        |     45      |   62.5          |    27        |  37.5
9             |  149        |    145      |   97.3          |     4        |  2.6
                                              79.1                            20.9

-- 3- (non self-removal) numer of self-admitted technical debt removals that was made by file edidion or by file removal 
select repository_id , removal_type, count(*) from processed_comments where has_removed_version is true and introduced_version_author != removed_version_author group by 1,2 order by 1
repository_id  non self-removed  FILE EDITION   % FILE EDITION    FILE_REMOVAL  % FILE_REMOVAL
2             |  356            |   220       |   61.7         |   136        |  38.2
3             |  318            |   245       |   77.0         |    73        |  22.9
5             | 1274            |  1231       |   96.6         |    43        |  3.3
6             |  356            |   268       |   75.2         |    88        |  24.7
7             |  431            |   235       |   54.5         |   196        |  45.4
8             |   46            |    20       |   43.4         |    26        |  56.5
9             |   59            |    49       |   83.0         |    10        |  16.9
                                                  70.2                           29.8

-- 4 - classification of the changes per project 
-- Ant
-- (introduction)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 2 and a.is_introduced_version = true and b.commit_hash = a.commit_hash group by 1 order by 2;
-- (general removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 2 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash  group by 1 order by 2;
-- (self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 2 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author = a.removed_version_author group by 1 order by 2;
-- (non self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 2 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author != a.removed_version_author group by 1 order by 2;

-- (introduction of TD)       (general removal)            (self-removal)              (non self-removal)
  classification  | count     classification  | count      classification  | count      classification  | count
------------------+-------  ------------------+-------   ------------------+-------   ------------------+-------
 Non Functional   |    12    Merge            |     4     Non Functional   |     1     Merge            |     3
 Merge            |    18    Non Functional   |     6     Merge            |     1     Non Functional   |     5
 Perfective       |    22    Perfective       |    23     Preventative     |     5     Perfective       |     9
 Preventative     |    24    Corrective       |    43     Perfective       |    14     Corrective       |    22
 Corrective       |    80    Preventative     |    47     Corrective       |    21     Preventative     |    42
 None             |   256    Feature Addition |   108     Feature Addition |    63     Feature Addition |    45
 Feature Addition |   442    None             |   497     None             |   267     None             |   230

-- Jmeter
-- (introduction)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 3 and a.is_introduced_version = true and b.commit_hash = a.commit_hash group by 1 order by 2;
-- (general removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 3 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash  group by 1 order by 2;
-- (self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 3 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author = a.removed_version_author group by 1 order by 2;
-- (non self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 3 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author != a.removed_version_author group by 1 order by 2;

-- (introduction)              (general removal)            (self-removal)              (non self-removal)
  classification  | count      classification  | count     classification  | count     classification  | count
------------------+-------   ------------------+-------  ------------------+-------   ------------------+-------
 Perfective       |     4     Perfective       |     1    Perfective       |     1    Merge            |    10
 Merge            |    16     Merge            |    14    Merge            |     4    Non Functional   |    13
 Non Functional   |    55     Non Functional   |    25    Non Functional   |    12    Preventative     |    30
 Preventative     |   135     Preventative     |    80    Preventative     |    50    None             |    70
 Feature Addition |   255     Corrective       |   223    Corrective       |   135    Corrective       |    88
 Corrective       |   356     None             |   305    Feature Addition |   222    Feature Addition |    99
 None             |   424     Feature Addition |   321    None             |   235

-- Camel
-- (introduction)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 5 and a.is_introduced_version = true and b.commit_hash = a.commit_hash group by 1 order by 2;
-- (general removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 5 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash  group by 1 order by 2;
-- (self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 5 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author = a.removed_version_author group by 1 order by 2;
-- (non self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 5 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author != a.removed_version_author group by 1 order by 2;


-- (introduction)               -- (general removal)        (self-removal)             (non self-removal)
  classification  | count       classification  | count     classification  | count    classification  | count
------------------+-------    ------------------+-------  ------------------+-------  ------------------+-------
 Merge            |     3      Merge            |     2    Merge            |     2   Non Functional   |     5
 Perfective       |     4      Non Functional   |    10    Non Functional   |     5   Perfective       |     6
 Preventative     |   442      Perfective       |    13    Perfective       |     7   Preventative     |     8
 Corrective       |   490      Preventative     |    85    Preventative     |    77   Corrective       |   312
 Feature Addition |   972      Corrective       |   407    Corrective       |    95   None             |   386
 None             |  2416      Feature Addition |  1154    Feature Addition |   597   Feature Addition |   557
                               None             |  2254    None             |  1868

-- Hadoop
-- (introduction)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 6 and a.is_introduced_version = true and b.commit_hash = a.commit_hash group by 1 order by 2;
-- (general removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 6 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash  group by 1 order by 2;
-- (self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 6 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author = a.removed_version_author group by 1 order by 2;
-- (non self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 6 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author != a.removed_version_author group by 1 order by 2;

 -- (introduction)           (general removal)            (self-removal)              (non self-removal)   
  classification  | count    classification  | count      classification  | count     classification  | count
------------------+------- ------------------+-------   ------------------+-------   ------------------+-------
 Perfective       |     7   Non Functional   |     1     Perfective       |     3    Non Functional   |     1
 Merge            |    18   Perfective       |     6     Preventative     |     9    Perfective       |     3
 Preventative     |    19   Merge            |     6     Feature Addition |    21    Preventative     |     4
 Corrective       |    72   Preventative     |    13     Corrective       |    22    Merge            |     6
 Feature Addition |   144   Feature Addition |    66     None             |    61    Feature Addition |    45
 Non Functional   |   219   Corrective       |    82                                 Corrective       |    60
 None             |   680   None             |   297                                 None             |   236

-- Tomcat
-- (introduction)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 7 and a.is_introduced_version = true and b.commit_hash = a.commit_hash group by 1 order by 2;
-- (general removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 7 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash  group by 1 order by 2;
-- (self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 7 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author = a.removed_version_author group by 1 order by 2;
-- (non self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 7 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author != a.removed_version_author group by 1 order by 2;

-- (introduction)             -- (general removal)        -- (self-removal)           -- (non self-removal)
  classification  | count     classification  | count     classification  | count     classification  | count
------------------+-------  ------------------+-------  ------------------+-------  ------------------+-------
 Perfective       |    10    Non Functional   |    14    Non Functional   |     5    Preventative     |     2
 Preventative     |    41    Perfective       |    20    Perfective       |     8    Non Functional   |     9
 Non Functional   |    68    Preventative     |    30    Preventative     |    28    Perfective       |    12
 Corrective       |   215    Feature Addition |   185    Corrective       |   103    Feature Addition |    26
 None             |   367    Corrective       |   187    Feature Addition |   159    Corrective       |    84
 Feature Addition |   616    None             |   573    None             |   275    None             |   298

-- Log4j
-- (introduction)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 8 and a.is_introduced_version = true and b.commit_hash = a.commit_hash group by 1 order by 2;
-- (general removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 8 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash  group by 1 order by 2;
-- (self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 8 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author = a.removed_version_author group by 1 order by 2;
-- (non self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 8 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author != a.removed_version_author group by 1 order by 2;

-- (introduction)              -- (general removal)       -- (self-removal)            -- (non self-removal)
  classification  | count      classification  | count     classification  | count     classification  | count
------------------+-------   ------------------+-------  ------------------+-------  ------------------+-------
 Non Functional   |     3     Preventative     |     1    Corrective       |     7    Preventative     |     1
 Preventative     |     4     Corrective       |    33    Feature Addition |    29    None             |     9
 Corrective       |    16     Feature Addition |    39    None             |    36    Feature Addition |    10
 None             |    46     None             |    45                                Corrective       |    26
 Feature Addition |    66  


-- Gerrit
-- (introduction)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 9 and a.is_introduced_version = true and b.commit_hash = a.commit_hash group by 1 order by 2;
-- (general removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 9 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash  group by 1 order by 2;
-- (self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 9 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author = a.removed_version_author group by 1 order by 2;
-- (non self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 9 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author != a.removed_version_author group by 1 order by 2;

-- (introduction)               (general removal)          (self-removal)            (non self-removal)
  classification  | count     classification  | count    classification  | count     classification  | count
------------------+-------  ------------------+------- ------------------+-------  ------------------+-------
 Perfective       |     4    Non Functional   |     2   Non Functional   |     1    Non Functional   |     1
 Non Functional   |     4    Merge            |     2   Perfective       |     1    Merge            |     1
 Corrective       |    45    Perfective       |     3   Merge            |     1    Perfective       |     2
 Merge            |    50    Feature Addition |    36   Feature Addition |    30    Feature Addition |     6
 None             |    71    None             |    79   None             |    44    Corrective       |    10
 Feature Addition |    87    Corrective       |    81   Corrective       |    71    None             |    35



-- All projects 
-- (introduction)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id in (2,3,5,6,7,8,9) and a.is_introduced_version = true and b.commit_hash = a.commit_hash group by 1 order by 2;
-- (general removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id in (2,3,5,6,7,8,9) and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash  group by 1 order by 2;
-- (self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id in (2,3,5,6,7,8,9) and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author = a.removed_version_author group by 1 order by 2;
-- (non self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id in (2,3,5,6,7,8,9) and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author != a.removed_version_author group by 1 order by 2;


-- (non self-removal)        -- (general removal)       -- (self-removal)           -- (non self-removal)
  classification  | count    classification  | count    classification  | count     classification  | count
------------------+------- ------------------+------- ------------------+-------  ------------------+-------
 Perfective       |    51   Merge            |    28   Merge            |     8    Merge            |    20
 Merge            |   105   Non Functional   |    58   Non Functional   |    24    Perfective       |    32
 Non Functional   |   361   Perfective       |    66   Perfective       |    34    Non Functional   |    34
 Preventative     |   665   Preventative     |   256   Preventative     |   169    Preventative     |    87
 Corrective       |  1274   Corrective       |  1056   Corrective       |   454    Corrective       |   602
 Feature Addition |  2582   Feature Addition |  1909   Feature Addition |  1121    Feature Addition |   788
 None             |  4260   None             |  4050   None             |  2786    None             |  1264