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
5             |  4331  |  3926
9             |   271  |   208
6             |  1164  |   472
3             |  1260  |   981
8             |   135  |   118
7             |  1317  |  1009

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

repository_id    Removed TD   self-removed | %             non self-removal | %
2             |   728       |    372   51.0989011        |   356     48.9010989
5             |  3926       |   2652   67.54966887       |  1274     32.45033113
9             |   208       |    149   71.63461538       |    59     28.36538462
6             |   472       |    116   24.57627119       |   356     75.42372881
3             |   981       |    663   67.58409786       |   318     32.41590214
8             |   118       |     72   61.01694915       |    46     38.98305085
7             |  1009       |    578   57.28444004       |   431     42.71555996
                                       57.24927766                   42.75072234

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

-- (introduction of TD)       (general removal)            (self-removal)  51.09%           (non self-removal) 48.90%
  classification  | count     classification  | count      classification  | count            classification  | count
------------------+-------  ------------------+-------   ------------------+-------         ------------------+-------
 Non Functional   |    12    Merge            |     4     Non Functional   |     1  0.26     Merge            |     3  0.84
 Merge            |    18    Non Functional   |     6     Merge            |     1  0.26     Non Functional   |     5  1.40
 Perfective       |    22    Perfective       |    23     Preventative     |     5  1.34     Perfective       |     9  2.52
 Preventative     |    24    Corrective       |    43     Perfective       |    14  3.76     Corrective       |    22  6.17
 Corrective       |    80    Preventative     |    47     Corrective       |    21  5.64     Preventative     |    42  11.79
 None             |   256    Feature Addition |   108     Feature Addition |    63  16.93    Feature Addition |    45  12.64
 Feature Addition |   442    None             |   497     None             |   267  71.77    None             |   230  64.60

-- Jmeter
-- (introduction)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 3 and a.is_introduced_version = true and b.commit_hash = a.commit_hash group by 1 order by 2;
-- (general removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 3 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash  group by 1 order by 2;
-- (self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 3 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author = a.removed_version_author group by 1 order by 2;
-- (non self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 3 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author != a.removed_version_author group by 1 order by 2;

-- (introduction)              (general removal)           (self-removal)  68.00%           (non self-removal) 31.99%
  classification  | count      classification  | count     classification  | count          classification  | count
------------------+-------   ------------------+-------  ------------------+-------        ------------------+-------
 Perfective       |     4     Perfective       |     1    Perfective       |     1  0.15    Merge            |    10   3.22  
 Merge            |    16     Merge            |    14    Merge            |     4  0.60    Non Functional   |    13   4.19
 Non Functional   |    55     Non Functional   |    25    Non Functional   |    12  1.82    Preventative     |    30   9.67
 Preventative     |   135     Preventative     |    80    Preventative     |    50  7.58    None             |    70   22.58
 Feature Addition |   255     Corrective       |   223    Corrective       |   135  20.48   Corrective       |    88   28.38
 Corrective       |   356     None             |   305    Feature Addition |   222  33.68   Feature Addition |    99   31.93
 None             |   424     Feature Addition |   321    None             |   235  35.66



-- Camel
-- (introduction)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 5 and a.is_introduced_version = true and b.commit_hash = a.commit_hash group by 1 order by 2;
-- (general removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 5 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash  group by 1 order by 2;
-- (self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 5 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author = a.removed_version_author group by 1 order by 2;
-- (non self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 5 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author != a.removed_version_author group by 1 order by 2;


-- (introduction)               -- (general removal)        (self-removal) 67.54%           (non self-removal) 32.45%
  classification  | count       classification  | count     classification  | count          classification  | count
------------------+-------    ------------------+-------  ------------------+-------       ------------------+-------
 Merge            |     3      Merge            |     2    Merge            |     2 0.07    Non Functional   |     5  0.39
 Perfective       |     4      Non Functional   |    10    Non Functional   |     5 0.18    Perfective       |     6  0.47
 Preventative     |   442      Perfective       |    13    Perfective       |     7 0.26    Preventative     |     8  0.62
 Corrective       |   490      Preventative     |    85    Preventative     |    77 2.90    Corrective       |   312  24.48
 Feature Addition |   972      Corrective       |   407    Corrective       |    95 3.58    None             |   386  30.29
 None             |  2416      Feature Addition |  1154    Feature Addition |   597 22.51   Feature Addition |   557  43.72
                               None             |  2254    None             |  1868 70.46

-- Hadoop
-- (introduction)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 6 and a.is_introduced_version = true and b.commit_hash = a.commit_hash group by 1 order by 2;
-- (general removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 6 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash  group by 1 order by 2;
-- (self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 6 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author = a.removed_version_author group by 1 order by 2;
-- (non self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 6 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author != a.removed_version_author group by 1 order by 2;

 -- (introduction)           (general removal)            (self-removal) 24.62%           (non self-removal) 75.37%
  classification  | count    classification  | count      classification  | count         classification  | count
------------------+------- ------------------+-------   ------------------+-------       ------------------+-------
 Perfective       |     7   Non Functional   |     1     Perfective       |     3 2.58    Non Functional   |     1  0.28
 Merge            |    18   Perfective       |     6     Preventative     |     9 7.75    Perfective       |     3  0.84
 Preventative     |    19   Merge            |     6     Feature Addition |    21 18.10   Preventative     |     4  1.12
 Corrective       |    72   Preventative     |    13     Corrective       |    22 18.96   Merge            |     6  1.69
 Feature Addition |   144   Feature Addition |    66     None             |    61 52.58   Feature Addition |    45  12.67
 Non Functional   |   219   Corrective       |    82                                      Corrective       |    60  16.90
 None             |   680   None             |   297                                      None             |   236  66.47


-- Tomcat
-- (introduction)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 7 and a.is_introduced_version = true and b.commit_hash = a.commit_hash group by 1 order by 2;
-- (general removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 7 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash  group by 1 order by 2;
-- (self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 7 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author = a.removed_version_author group by 1 order by 2;
-- (non self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 7 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author != a.removed_version_author group by 1 order by 2;

-- (introduction)             -- (general removal)        -- (self-removal) 57.28%           -- (non self-removal) 42.71%
  classification  | count     classification  | count     classification  | count             classification  | count
------------------+-------  ------------------+-------  ------------------+-------          ------------------+-------
 Perfective       |    10    Non Functional   |    14    Non Functional   |     5  0.86      Preventative     |     2  0.46
 Preventative     |    41    Perfective       |    20    Perfective       |     8  1.38      Non Functional   |     9  2.08
 Non Functional   |    68    Preventative     |    30    Preventative     |    28  4.84      Perfective       |    12  2.78
 Corrective       |   215    Feature Addition |   185    Corrective       |   103  17.82     Feature Addition |    26  6.03
 None             |   367    Corrective       |   187    Feature Addition |   159  27.50     Corrective       |    84  19.48
 Feature Addition |   616    None             |   573    None             |   275  47.57     None             |   298  69.14

-- Log4j
-- (introduction)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 8 and a.is_introduced_version = true and b.commit_hash = a.commit_hash group by 1 order by 2;
-- (general removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 8 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash  group by 1 order by 2;
-- (self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 8 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author = a.removed_version_author group by 1 order by 2;
-- (non self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id = 8 and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author != a.removed_version_author group by 1 order by 2;

-- (introduction)              -- (general removal)       -- (self-removal) 61.01%      -- (non self-removal) 38.98%
  classification  | count      classification  | count     classification  | count           classification  | count
------------------+-------   ------------------+-------  ------------------+-------        ------------------+-------
 Non Functional   |     3     Preventative     |     1    Corrective       |     7 9.72     Preventative     |     1   2.17
 Preventative     |     4     Corrective       |    33    Feature Addition |    29 40.27    None             |     9  19.56
 Corrective       |    16     Feature Addition |    39    None             |    36 50       Feature Addition |    10  21.73
 None             |    46     None             |    45                                      Corrective       |    26  56.52
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

-- (introduction)               (general removal)          (self-removal) 72.90%          (non self-removal) 27.09%
  classification  | count     classification  | count    classification  | count           classification  | count
------------------+-------  ------------------+------- ------------------+-------        ------------------+-------
 Perfective       |     4    Non Functional   |     2   Non Functional   |     1  0.67    Non Functional   |     1  1.81 
 Non Functional   |     4    Merge            |     2   Perfective       |     1  0.67    Merge            |     1  1.81
 Corrective       |    45    Perfective       |     3   Merge            |     1  0.67    Perfective       |     2  3.63
 Merge            |    50    Feature Addition |    36   Feature Addition |    30  20.27   Feature Addition |     6  10.90
 None             |    71    None             |    79   None             |    44  29.72   Corrective       |    10  18.18
 Feature Addition |    87    Corrective       |    81   Corrective       |    71  47.97   None             |    35  63.63


-- All projects 
-- (introduction)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id in (2,3,5,6,7,8,9) and a.is_introduced_version = true and b.commit_hash = a.commit_hash group by 1 order by 2;
-- (general removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id in (2,3,5,6,7,8,9) and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash  group by 1 order by 2;
-- (self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id in (2,3,5,6,7,8,9) and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author = a.removed_version_author group by 1 order by 2;
-- (non self-removal)
select b.classification, count(*) from processed_comments a , commit_guru b where a.repository_id in (2,3,5,6,7,8,9) and a.is_introduced_version = true and b.commit_hash = a.removed_version_commit_hash and a.introduced_version_author != a.removed_version_author group by 1 order by 2;


-- (introduction)               -- (general removal)       -- (self-removal) 61.91%         -- (non self-removal) 38.08%
  classification  | count         classification  | count    classification  | count          classification  | count
------------------+-------      ------------------+------- ------------------+-------       ------------------+-------
 Perfective       |    51 0.54   Merge            |    28   Merge            |     8 0.17    Merge            |    20   0.70
 Merge            |   105 1.12   Non Functional   |    58   Non Functional   |    24 0.52    Perfective       |    32   1.13
 Non Functional   |   361 3.88   Perfective       |    66   Perfective       |    34 0.73    Non Functional   |    34   1.20
 Preventative     |   665 7.15   Preventative     |   256   Preventative     |   169 3.67    Preventative     |    87   3.07
 Corrective       |  1274 13.70  Corrective       |  1056   Corrective       |   454 9.87    Corrective       |   602   21.29
 Feature Addition |  2582 27.76  Feature Addition |  1909   Feature Addition |  1121 24.39   Feature Addition |   788   27.87
 None             |  4260 45.81  None             |  4050   None             |  2786 60.61   None             |  1264   44.71
