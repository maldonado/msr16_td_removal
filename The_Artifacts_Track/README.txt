Title of the paper: An Empirical Study On the Removal of Self-Admitted Technical Debt
The authors: 

Everton da S. Maldonado, Rabe Abdalkareem , Emad Shihab
Data-driven Analysis of Software (DAS) Lab, Department of Computer Science and Software Engineering, Concordia University, Montreal, Canada
Email: {e_silvam,rab abdu,eshihab}@encs.concordia.ca

Alexander Serebrenik
Eindhoven University of Technology, Eindhoven, The Netherlands
Email: a.serebrenik@tue.nl




Abstract: 
Technical debt refers to the phenomena of taking shortcuts to achieve short term gain at the cost of higher maintenance efforts in the future. Recently, approaches were developed to detect technical debt through code comments, referred to as Self-Admitted Technical Debt (SATD). Due to its importance, several studies have focused on the detection of SATD and examined its impact on software quality. However, preliminary findings showed that in some cases SATD may live in a project for a long time, i.e., more than 10 years. These findings clearly show that not all SATD may be regarded as ‘bad’ and some SATD needs to be removed, while other SATD may be fine to take on. 
Therefore, in this paper, we study the removal of SATD. In an empirical study on five open source projects, we examine how much SATD is removed and who removes SATD? We also investigate for how long SATD lives in a project and what activities lead to the removal of SATD? Our findings indicate that the majority of SATD is removed and that the majority is self-removed (i.e., removed by the same person that introduced it). Moreover, we find that SATD can last between approx. 18–172 days, on median. Finally, through a developer survey, we find that developers mostly use SATD to track future bugs and areas of the code that need improvements. Also, developers mostly remove SATD when they are fixing bugs or adding new features. Our findings contribute to the body of empirical evidence on SATD, in particular evidence pertaining to its removal.



List of the studied projects:
1 | camel  | master        | https://github.com/apache/camel             | 2016-03-29 15:42:13.551677
2 | hadoop | trunk         | https://github.com/apache/hadoop            | 2016-03-29 15:43:32.239268
3 | tomcat | trunk         | https://github.com/apache/tomcat            | 2016-03-29 15:44:26.829478
4 | log4j  | trunk         | https://github.com/apache/log4j             | 2016-03-29 15:45:07.198918
5 | gerrit | master        | https://github.com/gerrit-review/gerrit.git | 2016-04-05 14:26:39.899985



This artifact presents the dataset that we analyzed to answer our four research question presented in the paper. The artifact is structured according to the research questions. All the dataset files are in CSV `Comma-separated values' format.


RQ1: How much self-admitted technical debt gets removed?
For each of the studied project, there is a CSV file that contains a list of all the identified self-admitted technical debt with their meta data such as the file where the comment exists and the commit hash that introduced the source code comment. 


RQ2: Who removes self-admitted technical debt? Is it most likely to be self-removed or removed by others?
For each of the studied project, there is a CSV file that contains a list of all the self-removed technical debt and non-self-removed. They provide authors' name of the commit that introduced and removed the self-admitted technical debt.


RQ3: How long does self-admitted technical debt survive in a project?
This folder contains both interval time to remove self-admitted technical debt. It also contains the R-script that is used for analysis and generating paper’s plots.


RQ4: What activities lead to the removal of self-admitted technical debt?
This folder contains a sample of the online survey questions that we sent to the developers. It also contains the responses from the online survey.
 


