
-- show all comments that the TD was removed
select project_name, file_name , version_introduced_author, version_removed_author from technical_debt_summary where version_removed_name != 'not_removed' order by 1,2;

RQ1 - How much of self-admitted technical debt gets removed ? [repeat]
(consistency of code and comment co-change) 




-- total of TD comments
select count(*) from technical_debt_summary;
1127

-- per project
select project_name, count(*) from technical_debt_summary group by 1;
---------------+-------
 jruby         |   622
 apache-ant    |   131
 apache-jmeter |   374

-- removed per project
 select project_name, count(*) from technical_debt_summary where version_removed_name != 'not_removed' group by 1;
project_name  | count
---------------+-------
 jruby         |   398
 apache-ant    |    19
 apache-jmeter |    22

-- self removal per project
 select project_name, count(*) from technical_debt_summary where version_removed_name != 'not_removed' and version_removed_author = version_introduced_author group by 1;

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

select count(*) from technical_debt_summary where version_introduced_author = version_removed_author and version_removed_name != 'not_removed'
257
select count(*) from technical_debt_summary where version_introduced_author != version_removed_author and version_removed_name != 'not_removed'
183
-- average days from self removal
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
select comment_classification, epoch_time_to_remove)/86400 from time_to_remove_td where version_removed_name != 'not_removed' and comment_classification='TEST' group by 1;
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
 apache-ant    | Stefan Bodewig            |    39  | 29.77
 apache-ant    | Matthew Jason Benson      |    11  | 8.39
 apache-ant    | Costin Manolache          |    11  | 8.39
 apache-ant    | Conor MacNeill            |    10  | 7.63
 apache-ant    | Peter Donald              |     9  | 6.87
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
 apache-jmeter | Sebastian Bazley          |   302  |80.74
 apache-jmeter | Philippe Mouawad          |    24  |6.41
 apache-jmeter | Jordi Salvat i Alabart    |    19  |5.08
 apache-jmeter | Michael Stover            |     4  |1.06
 apache-jmeter | Jeremy Arnold             |     4  |1.06
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
 jruby         | Charles Oliver Nutter     |   327 | 52.57
 jruby         | Thomas E. Enebo           |   111 | 17.84
 jruby         | Vladimir Sizikov          |    52 | 8.36
 jruby         | Subramanya Sastry         |    43 | 6.91
 jruby         | Ola Bini                  |    27 | 4.34
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
 apache-ant    | Stefan Bodewig            |     6  | 31.57
 apache-ant    | Peter Reilly              |     4  | 21.05
 apache-ant    | Matthew Jason Benson      |     2  | 10.52
 apache-ant    | Nicolas Lalevee           |     1  | 5.26
 apache-ant    | Kevin Jackson             |     1  | 5.26
 apache-ant    | Jacobus Martinus Kruithof |     1
 apache-ant    | Jesse N. Glick            |     1
 apache-ant    | Antoine Levy-Lambert      |     1
 apache-ant    | Steve Loughran            |     1
 apache-ant    | Jan Materne               |     1
 apache-jmeter | Philippe Mouawad          |    11 |50 
 apache-jmeter | Sebastian Bazley          |    10 |45.45 
 apache-jmeter | Bruno Demion              |     1 |4.55 
 jruby         | Charles Oliver Nutter     |   244 | 61.30
 jruby         | Thomas E. Enebo           |    64 | 16.08
 jruby         | Subramanya Sastry         |    46 | 11.55
 jruby         | kares                     |     7 | 1.75
 jruby         | Hiro Asari                |     6 | 1.50
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

pareto principle


select author_name, count(*) from commit_guru where project_name = 'apache-ant' group by 1 order by 2 desc;

select count(*) from commit_guru where project_name = 'apache-ant';
 count
-------
 13206

        author_name        | count | %
---------------------------+-------
 Stefan Bodewig            |  4304 | 32.59 
 Peter Donald              |  1546 | 11.70
 Peter Reilly              |  1095 | 8.29
 Matthew Jason Benson      |   975 | 7.38
 Conor MacNeill            |   918 | 6.95
 Steve Loughran            |   727 | 5.50
 Antoine Levy-Lambert      |   691 | 5.23
 Jan Materne               |   443 | 3.35
 Stephane Bailliez         |   348 | 2.63
 Jesse N. Glick            |   274 | 2.07
 Jacobus Martinus Kruithof |   244 | 1.84
 Magesh Umasankar          |   231 | 1.74
 Erik Hatcher              |   188 | 1.42
 Kevin Jackson             |   169 | 1.27
 Costin Manolache          |   154 | 1.16
 adammurdoch               |   148 | 1.12
 Sam Ruby                  |   104 | 0.78
 Diane Holt                |    90 | 0.68
 metasim                   |    90 | 0.68
 Nicolas Lalevee           |    71 | 0.53
 Jon Skeet                 |    37 | 0.28
 Nico Seessle              |    36 | 0.27
 glennm                    |    34 | 0.25
 Steven M. Cohen           |    27 | 0.20
 Stefano Mazzocchi         |    27 | 0.20
 Christoph Wilhelms        |    24 | 0.18
 Jesse Stockall            |    22 | 0.16
 Jon Scott Stevens         |    22 | 0.16
 James Duncan Davidson     |    19 | 0.14
 Bruce Atherton            |    18 | 0.13
 Darrell DeBoer            |    18 | 0.13
 nickdavis                 |    17 | 0.12
 Arnout J. Kuiper          |    14 | 0.10
 Scokart Gilles            |    13 | 0.09
 mclarke                   |    12 | 0.09
 Alexey N. Solofnenko      |     8 | 0.06
 Maarten Coene             |     8 | 0.06
 Dominique Devienne        |     7 | 0.05
 Jonathan K. Schneider     |     4 | 0.03
 YOUR NAME                 |     4 | 0.03
 Ville Skyttu00c3u00a4     |     3 | 0.02
 Jason Hunter              |     3 | 0.02
 Craig R. McClanahan       |     3 | 0.02
 Razzi Abuissa             |     2 | 0.01
 pkures                    |     2 | 0.01
 Reinhard Pointner         |     2 | 0.01
 preston                   |     1 | 0.00
 No Author                 |     1 | 0.00
 Vitold S                  |     1 | 0.00
 cduffy                    |     1 | 0.00
 Daniel Ferrin             |     1 | 0.00
 akv                       |     1 | 0.00
 Vladislav Bauer           |     1 | 0.00
 Xavier Hanin              |     1 | 0.00
 Pier Fumagalli            |     1 | 0.00
 Martin von Gagern         |     1 | 0.00

select author_name, count(*) from commit_guru where project_name = 'apache-jmeter' group by 1 order by 2 desc;

elect count(*) from commit_guru where project_name = 'apache-jmeter';
 count
-------
 11722
------------------------+------- | %
 Sebastian Bazley       |  7191  | 61.34
 Philippe Mouawad       |  2025  | 17.27
 Bruno Demion           |   490  | 4.18
 Peter Lin              |   453  | 3.86
 Michael Stover         |   450  | 3.83
 Felix Schumacher       |   375  | 3.19
 Jordi Salvat i Alabart |   246  | 2.09
 Jeremy Arnold          |   119  | 1.01
 khammond               |    76  | 0.64
 William Thad Smith     |    67  | 0.57
 burns                  |    28  | 0.23
 kcassell               |    24  | 0.20
 mstover                |    22  | 0.18
 Stefano Mazzocchi      |    21  | 0.17
 Berin Loritsch         |    19  | 0.16
 Martijn Blankestijn    |    17  | 0.14
 Rainer Jung            |    17  | 0.14
 Alf Hoegemark          |    16  | 0.13
 Scott Eade             |    14  | 0.11
 Andrey Pokhilko        |    10  | 0.08
 fschumacher            |     6  | 0.05
 tusharbhatia           |     5  | 0.04
 No Author              |     5  | 0.04
 bburns                 |     5  | 0.04
 dgulino                |     3  | 0.02
 Oliver Rossmueller     |     3  | 0.02
 asf-sync-process       |     3  | 0.02
 Jon Scott Stevens      |     3  | 0.02
 jboutcher              |     3  | 0.02
 Wolfram Rittmeyer      |     2  | 0.01
 pajor                  |     1  | 0.00
 Davanum Srinivas       |     1  | 0.00
 pmouawad               |     1  | 0.00
 Michal Kostrzewa       |     1  | 0.00

select author_name, count(*) from commit_guru where project_name = 'jruby' group by 1 order by 2 desc;

select count(*) from commit_guru where project_name = 'jruby';
 count
-------
 33368

              author_name             | count
-------------------------------------+-------
 Charles Oliver Nutter               |  8942  | 26.79
 Thomas E. Enebo                     |  4509  | 13.51
 Chris Seaton                        |  3038  | 9.10
 Benoit Daloze                       |  2126  | 6.37
 Subramanya Sastry                   |  1249  | 3.74
 Christian Meier                     |  1212  | 3.63
 Wayne Meissner                      |  1202  | 3.60
 Kevin Menard                        |  1116  | 3.34
 Ola Bini                            |  1002  | 3.00
 Marcin Mielzynski                   |   937  | 2.80
 Hiro Asari                          |   853  | 2.55
 kares                               |   815  | 2.44
 Vladimir Sizikov                    |   752  | 2.25
 Nick Sieger                         |   748  | 2.24
 Anders Bengtsson                    |   612  | 1.83
 Jan Arne Petersen                   |   406  | 1.21
 Tim Felgentreff                     |   380  | 1.13
 Brandon Fish                        |   314  | 0.94
 Hiroshi Nakamura                    |   301  | 0.90
 Petr Chalupa                        |   227  | 0.68
 David Calavera                      |   169  | 0.50
 Alex Tambellini                     |   158  | 0.47
 Lucas Allan Amorim                  |   151  | 0.45
 Yoko Harada                         |   141  | 0.42
 MenTaLguY                           |   125  | 0.37
 Uwe Kubosch                         |   107  | 0.32
 Benoit Cerrina                      |    91  | 0.27
 Douglas Campos                      |    75  | 0.22
 Chris Heald                         |    69  | 0.20
 Daniel Marcotte                     |    57  | 0.17
 Stefan Matthias Aust                |    57  | 0.17
 David Corbin                        |    50  | 0.14
 Bill Dortch                         |    48  | 0.14
 Maximilian Konzack                  |    48  | 0.14
 Dmitry Ratnikov                     |    45  | 0.13
 Prathamesh Sonpatki                 |    41  | 0.12
 tduehr                              |    41  | 0.12
 Su00c3u00a9bastien Le Callonnec     |    34  | 0.10
 NAKAMURA                            |    32  | 0.09
 Alan Moore                          |    32  | 0.09
 kiichi                              |    28  | 0.08
 Chad Fowler                         |    26  | 0.07
 Smit Shah                           |    26  | 0.07
 Peter Vandenabeele                  |    23  | 0.06
 Atsuhiko Yamanaka                   |    21  | 0.06
 Daniel Lucraft                      |    21  | 0.06
 Thomas Wuerthinger                  |    20  | 0.05
 Karol Bucek                         |    19  | 0.05
 Chris Sinjakli                      |    19  | 0.05
 Teemu                               |    19  | 0.05
 Ben Browning                        |    18  | 0.05
 Gustav Munkby                       |    17  | 0.05
 josedonizetti                       |    17  | 0.05
 Pavel Rosicku00c3u00bd              |    16  | 0.04
 Joey Gibson                         |    16  | 0.04
 Brian Belleville                    |    14  | 0.04
 Matt Hauck                          |    14  | 0.04
 Matt Wilson                         |    13  | 0.03
 David Hudson                        |    13  | 0.03
 Charlie Somerville                  |    12  | 0.03
 areman                              |    12  | 0.03
 Aaron Patterson                     |    11  | 0.03
 Jason Voegele                       |    11  | 0.03
 Matthias Grimmer                    |    11  | 0.03
 Theo                                |    11  | 0.03
 ryenus                              |    10  | 0.02
 Fabio Niephaus                      |     9  | 0.02
 Koichiro Ohba                       |     9  | 0.02
 Josef Haider                        |     9  | 0.02
 Ben Lovell                          |     9  | 0.02
 Joe Kutner                          |     9  | 0.02
 Luca Simone                         |     8  | 0.02
 Ian Dees                            |     8  | 0.02
 Aman Gupta                          |     8  | 0.02
 Reuben Sutton                       |     8  | 0.02
 Robin Dupret                        |     7  | 0.02
 David Grayson                       |     7  | 0.02
 Chris Price                         |     7  | 0.02
 Lars Westergren                     |     6  | 0.01
 Erik Michaels-Ober                  |     6  | 0.01
 Josh Ballanco                       |     6  | 0.01
 Stephen Bannasch                    |     6  | 0.01
 David Kellum                        |     6  | 0.01
 Alex Dowad                          |     6  | 0.01
 Andy Lindeman                       |     6  | 0.01
 mkristian                           |     6  | 0.01
 Kristian Meier                      |     6  | 0.01
 Aliaksei Palkanau                   |     6  | 0.01
 Brandur                             |     6  | 0.01
 Christoffer Sawicki                 |     6  | 0.01
 David Masover                       |     6  | 0.01
 Rajarshi Das                        |     6  | 0.01
 Tobias Crawley                      |     6  | 0.01
 Bruce Adams                         |     5  | 0.01
 Andrew Kiellor                      |     5  | 0.01
 Kenichi Kamiya                      |     5  | 0.01
 Martin Ott                          |     5  | 0.01
 James Abley                         |     5  | 0.01
 Anthony W. Juckel                   |     5  | 0.01
 sglee77                             |     5  | 0.01
 John F. Douthat                     |     4  | 0.01
 Edward Anderson                     |     4  | 0.01
 Stefan Huber                        |     4  | 0.01
 Sakumatti Luukkonen                 |     4  | 0.01
 Mark McCraw                         |     4  | 0.01
 Kohsuke Kawaguchi                   |     4  | 0.01
 Nick Klauer                         |     4  | 0.01
 Sebastien Le Callonnec              |     4  | 0.01
 Martin Traverso                     |     4  | 0.01
 Lin Jen-Shin                        |     4  | 0.01
 Daniel Luz                          |     4  | 0.01
 Andreas Woess                       |     4  | 0.01
 Bob Beaty                           |     4  | 0.01
 Patrick Plenefisch                  |     4  | 0.01
 Jake Goulding                       |     4  | 0.01
 Chris Jester-Young                  |     4  | 0.01
 Gerard Fowley                       |     4  | 0.01
 timfel                              |     4  | 0.01
 Samu Voutilainen                    |     4  | 0.01
 Isaiah Peng                         |     4  | 0.01
 Ranjeet Singh                       |     4  | 0.01
 Phil Smith                          |     3  | 0.00
 Ryan Brown                          |     3  | 0.00
 Bob McWhirter                       |     3  | 0.00
 James Pickering                     |     3  | 0.00
 Bohuslav Kabrda                     |     3  | 0.00
 Greg Mefford                        |     3  | 0.00
 Anil Wadghule                       |     3  | 0.00
 Matthias Springer                   |     3  | 0.00
 Sean Griffin                        |     3  | 0.00
 rogerdpack                          |     3  | 0.00
 Kubo Takehiro                       |     3  | 0.00
 David Pollak                        |     3  | 0.00
 Michael Klishin                     |     3  | 0.00
 donv                                |     3  | 0.00
 Dario Bertini                       |     3  | 0.00
 r6p                                 |     3  | 0.00
 Leonardo Bianconi                   |     3  | 0.00
 Vu00c3u00adt Ondruch                |     3  | 0.00
 unknown                             |     3  | 0.00
 Jeremy Evans                        |     2  | 0.00
 Colin Jones                         |     2  | 0.00
 Patrick Toomey                      |     2  | 0.00
 Jeff Stone                          |     2  | 0.00
 jc00ke                              |     2  | 0.00
 Conrad Irwin                        |     2  | 0.00
 Ori Kremer                          |     2  | 0.00
 Yosuke                              |     2  | 0.00
 jonforums                           |     2  | 0.00
 Bernhard Urban                      |     2  | 0.00
 Chris White                         |     2  | 0.00
 Michael Kohl                        |     2  | 0.00
 Mike Dalessio                       |     2  | 0.00
 Mark Triggs                         |     2  | 0.00
 Garrett Conaty                      |     2  | 0.00
 Theo Hultberg                       |     2  | 0.00
 Thomas Hurst                        |     2  | 0.00
 Jez Ng                              |     2  | 0.00
 Rohit Arondekar                     |     2  | 0.00
 kristian                            |     2  | 0.00
 yousuke                             |     2  | 0.00
 Hongli Lai (Phusion)                |     2  | 0.00
 Joel Segerlind                      |     2  | 0.00
 Ron Dahlgren                        |     2  | 0.00
 mohamed                             |     2  | 0.00
 Ryan Blue                           |     2  | 0.00
 Jon Zeppieri                        |     2  | 0.00
 Jordan Sissel                       |     2  | 0.00
 Nick Howard                         |     2  | 0.00
 Nick Muerdter                       |     2  | 0.00
 Javier                              |     2  | 0.00
 Clayton Wheeler                     |     2  | 0.00
 Ryan Fowler                         |     2  | 0.00
 Clayton ONeill                      |     2  | 0.00
 Steven Cook                         |     2  | 0.00
 Michal Papis                        |     2  | 0.00
 Kamil Bednarz                       |     2  | 0.00
 hmalphettes                         |     2  | 0.00
 Manish                              |     2  | 0.00
 peter royal                         |     2  | 0.00
 Matt Wilbur                         |     2  | 0.00
 lfstad-bren                         |     2  | 0.00
 Daniel Berger                       |     2  | 0.00
 Tristan Hill                        |     2  | 0.00
 John Shahid                         |     2  | 0.00
 Matthaus Owens                      |     2  | 0.00
 Scott Blum                          |     2  | 0.00
 Joe                                 |     2  | 0.00
 Jeff Pace                           |     2  | 0.00
 Pierrick Rouxel                     |     2  | 0.00
 Vipul A M                           |     2  | 0.00
 Seamus Abshere                      |     2  | 0.00
 Andrey Fadeyev                      |     2  | 0.00
 Pablo Varela                        |     2  | 0.00
 Brian Browning                      |     2  | 0.00
 Genadi Samokovarov                  |     2  | 0.00
 William Thurston                    |     2  | 0.00
 john muhl                           |     1  | 0.00
 Ole Christian Rynning               |     1  | 0.00
 Dwayne Litzenberger                 |     1  | 0.00
 Satoru Chinen                       |     1  | 0.00
 Tiago Stu00c3u00bcrmer Daitx        |     1  | 0.00
 bitfurry                            |     1  | 0.00
 Rick Ohnemus                        |     1  | 0.00
 Joseph LaFata                       |     1  | 0.00
 Bruno Oliveira                      |     1  | 0.00
 Pekka Enberg                        |     1  | 0.00
 NARUSE, Yui                         |     1  | 0.00
 Steven Parkes                       |     1  | 0.00
 Seth Wright                         |     1  | 0.00
 arkxu                               |     1  | 0.00
 Vitor de Lima                       |     1  | 0.00
 Iain Barnett                        |     1  | 0.00
 Nicholas Jefferson                  |     1  | 0.00
 GennadySpb                          |     1  | 0.00
 Arlandis Lawrence                   |     1  | 0.00
 Stefanos Kornilios Mitsis Poiitidis |     1  | 0.00
 John Firebaugh                      |     1  | 0.00
 Joshua Go                           |     1  | 0.00
 williamd                            |     1  | 0.00
 Mark Rada                           |     1  | 0.00
 Syver Enstad                        |     1  | 0.00
 Kyrylo Silin                        |     1  | 0.00
 Jan Xie                             |     1  | 0.00
 Ed Sinjiashvili                     |     1  | 0.00
 Kouhei Sutou                        |     1  | 0.00
 John Croisant                       |     1  | 0.00
 Lelon Stoldt                        |     1  | 0.00
 Ketan Padegaonkar                   |     1  | 0.00
 Brice Figureau                      |     1  | 0.00
 Don Schwartz                        |     1  | 0.00
 u00c3u008dgor Bonadio               |     1  | 0.00
 Mateusz Lenik                       |     1  | 0.00
 Zach Anker                          |     1  | 0.00
 Bernerd Schaefer                    |     1  | 0.00
 the8472                             |     1  | 0.00
 Sebastian Staudt                    |     1  | 0.00
 Travis Tilley                       |     1  | 0.00
 Xavier Shay                         |     1  | 0.00
 Pedro Andrade                       |     1  | 0.00
 Mark Warren                         |     1  | 0.00
 Arun Agrawal                        |     1  | 0.00
 Robin Message                       |     1  | 0.00
 //de                                |     1  | 0.00
 Elia Schito                         |     1  | 0.00
 cngshow                             |     1  | 0.00
 Pierre-Yves Ritschard               |     1  | 0.00
 Arne Hormann                        |     1  | 0.00
 uid41545                            |     1  | 0.00
 Jason Karns                         |     1  | 0.00
 Dave Thomas                         |     1  | 0.00
 retnuh                              |     1  | 0.00
 Matjaz Gregoric                     |     1  | 0.00
 Martin Harriman                     |     1  | 0.00
 Dennis Ranke                        |     1  | 0.00
 commitguru                          |     1  | 0.00
 Anoop Sankar                        |     1  | 0.00
 Unbit                               |     1  | 0.00
 rohit                               |     1  | 0.00
 Bob Potter                          |     1  | 0.00
 Konstantin Haase                    |     1  | 0.00
 Olov Lassus                         |     1  | 0.00
 Jose Rivera                         |     1  | 0.00
 eregon                              |     1  | 0.00
 Shugo Maeda                         |     1  | 0.00
 tnarik                              |     1  | 0.00
 Paul Phillips                       |     1  | 0.00
 Xb                                  |     1  | 0.00
 Ted Pennings                        |     1  | 0.00
 wayne                               |     1  | 0.00
 rdp                                 |     1  | 0.00
 geemus                              |     1  | 0.00
 Matthew Kerwin                      |     1  | 0.00
 Christian                           |     1  | 0.00
 Keith Amidon                        |     1  | 0.00
 Sadayuki Furuhashi                  |     1  | 0.00
 Michael J. Cohen                    |     1  | 0.00
 Jay                                 |     1  | 0.00
 Daniel Noll                         |     1  | 0.00
 Deepak Giridharagopal               |     1  | 0.00
 Peter Suschlik                      |     1  | 0.00
 Aditya Bhardwaj                     |     1  | 0.00
 Daniel Azuma                        |     1  | 0.00
 simonjsmithuk                       |     1  | 0.00
 thedarkone                          |     1  | 0.00
 elcubo                              |     1  | 0.00
 Paul Mucur                          |     1  | 0.00
 Naoto Kevin IMAI TOYODA             |     1  | 0.00
 Antoine Toulme                      |     1  | 0.00
 Frederic Jean                       |     1  | 0.00
 Leonardo Borges                     |     1  | 0.00
 Jacob Evans                         |     1  | 0.00
 zszugyi                             |     1  | 0.00
 takeru                              |     1  | 0.00
 Jonathan Adams                      |     1  | 0.00
 Juergen Herzog                      |     1  | 0.00
 james                               |     1  | 0.00
 Alexey Noskov                       |     1  | 0.00
 Alexander Zolotko                   |     1  | 0.00
 Malte Swart                         |     1  | 0.00
 Vishnu Gopal                        |     1  | 0.00
 Elias Levy                          |     1  | 0.00
 Hironobu Nishikokura                |     1  | 0.00
 Josh Matthews                       |     1  | 0.00
 Patrick Mahoney                     |     1  | 0.00
 Tobi Vollebregt                     |     1  | 0.00
 Aslak Hellesu00c3u00b8y             |     1  | 0.00
 Andrew Grimm                        |     1  | 0.00
 cdwijayarathna                      |     1  | 0.00
 Daniel Pittman                      |     1  | 0.00
 Alexey Gaziev                       |     1  | 0.00
 wpc                                 |     1  | 0.00
 Matthew Denner                      |     1  | 0.00
 Loren Segal                         |     1  | 0.00
 qbproger                            |     1  | 0.00
 Brad Heller                         |     1  | 0.00
 Heiko W. Rupp                       |     1  | 0.00
 Daniel Hahn                         |     1  | 0.00
 Micah Martin                        |     1  | 0.00
 Eric Sendelbach                     |     1  | 0.00
 Dirk Gadsden                        |     1  | 0.00
 Paul Brown                          |     1  | 0.00
 Gustavo Frederico Temple Pedrosa    |     1  | 0.00
 Ryan T. Hosford                     |     1  | 0.00
 Jason Staten                        |     1  | 0.00
 Jeff Simpson                        |     1  | 0.00
 Jan Graichen                        |     1  | 0.00
 Alex Coles                          |     1  | 0.00
 Rhett Sutphin                       |     1  | 0.00
 Akinori MUSHA                       |     1  | 0.00
 Robert Glaser                       |     1  | 0.00
 Chris Andrews                       |     1  | 0.00
 Scott Clasen                        |     1  | 0.00
 Gino Lucero                         |     1  | 0.00
 Philip Jenvey                       |     1  | 0.00
 Riley Lynch                         |     1  | 0.00
 amuino                              |     1  | 0.00

-- treating same authors from commit
-- first observe differences 
 select author_name, author_email from commit_guru where project_name = 'apache-ant' group by 2,1 order by 1;

 -- then update accordingly , in this case using the email to update same authors 
update commit_guru set author_name = 'Jan Materne' where author_name in ('Jan Matu00c3u00a8rne','Jan Matu00e8rne') and project_name = 'apache-ant'
update commit_guru set author_name = 'Marcin Mielzynski' where author_name in ('Marcin Mielu00c5u00bcyu00c5u0084ski') and project_name = 'jruby'
update commit_guru set author_name = 'Nick Klauer' where author_name in ('Nick Klauer (a03182)') and project_name = 'jruby'
update commit_guru set author_name = 'Thomas E. Enebo' where author_name in ('Thomas E Enebo', 'Thomas Enebo', '@tom_enebo', 'enebo') and project_name = 'jruby'

 
RQ4 - Why these TD's are removed and why some of them does not get removed ?
look into the commit (messages) and issue trackers to see the reason? - corrective , non functional, feature addition ... 
use topic modeling to see if we can get any specific patterns

stats




select a.file_name,a.version_introduced_name, a.version_removed_name, b.repository_directory, a.comment_text  from technical_debt_summary a , file_directory_per_version b where a.last_version_that_comment_was_found_hash = b.version_hash and a.file_name =  b.file_name and a.version_introduced_name = a.version_removed_name and a.version_removed_name != 'not_removed'  and a.project_name= 'apache-ant' order by 1,2 ;



select processed_comment_id, project_name, file_name, version_introduced_name, version_introduced_order, version_introduced_author, version_introduced_commit_hash, version_introduced_message,  


-- commit classification analysis
select b.classification , count(*) from git_commit_analysis a, commit_guru b where a.version_introduced_commit_hash = b.commit_hash group by 1 ; 
select b.classification , count(*) from git_commit_analysis a, commit_guru b where a.version_removed_commit_hash = b.commit_hash group by 1 ;

classification    | introduced | removed
------------------+------------+--------
 Corrective       |   357      |   217   
 Feature Addition |   188      |    44  
 Merge            |    13      |     3
 Non Functional   |    28      |     1
 None             |   477      |   162
 Perfective       |    22      |     5
 Preventative     |    42      |     4


-- introduced vs removed ant
select b.classification , count(*) from git_commit_analysis a, commit_guru b where a.version_introduced_commit_hash = b.commit_hash and a.project_name = 'apache-ant' group by 1 ;
select b.classification , count(*) from git_commit_analysis a, commit_guru b where a.version_removed_commit_hash = b.commit_hash and a.project_name = 'apache-ant' group by 1 ;
classification    | introduced | removed
------------------+------------+--------
 Corrective       |    39      |    3
 Feature Addition |    34      |    1
 Merge            |     2      |    1
 Non Functional   |     3      |    1
 None             |    47      |   11
 Perfective       |     1      |    -
 Preventative     |     5      |    2


-- introduced vs removed jmeter
select b.classification , count(*) from git_commit_analysis a, commit_guru b where a.version_introduced_commit_hash = b.commit_hash and a.project_name = 'apache-jmeter' group by 1 ; 
select b.classification , count(*) from git_commit_analysis a, commit_guru b where a.version_removed_commit_hash = b.commit_hash and a.project_name = 'apache-jmeter' group by 1 ; 
  classification  | introduced | removed
------------------+------------+--------
 Corrective       |   118      |   12
 Feature Addition |    64      |    4
 Merge            |     6      |    -
 Non Functional   |    24      |    -
 None             |   135      |    7
 Perfective       |     3      |    1
 Preventative     |    24      |    -

 
 -- introduced vs removed jruby
select b.classification , count(*) from git_commit_analysis a, commit_guru b where a.version_introduced_commit_hash = b.commit_hash and a.project_name = 'jruby' group by 1 ;  
select b.classification , count(*) from git_commit_analysis a, commit_guru b where a.version_removed_commit_hash = b.commit_hash and a.project_name = 'jruby' group by 1 ; 
 
  classification  | introduced | removed
------------------+------------+--------
 Corrective       |   200      |   202      
 Feature Addition |    90      |    32       
 Merge            |     5      |     2
 Non Functional   |     1      |     -
 None             |   295      |   144
 Perfective       |    18      |     4 
 Preventative     |    13      |     2


