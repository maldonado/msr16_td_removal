# general median in days for removal of td
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where repository_id = 2 and is_introduced_version is true and has_removed_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where repository_id = 3 and is_introduced_version is true and has_removed_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where repository_id = 5 and is_introduced_version is true and has_removed_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where repository_id = 6 and is_introduced_version is true and has_removed_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where repository_id = 7 and is_introduced_version is true and has_removed_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where repository_id = 8 and is_introduced_version is true and has_removed_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where repository_id = 9 and is_introduced_version is true and has_removed_version is true")
postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where repository_id in(2,3,5,6,7,8,9)  and is_introduced_version is true and has_removed_version is true")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
seconds_in_a_day <- 86400
median(data1$epoch_time_to_remove/seconds_in_a_day)

# calculating the median in days from self-removal TD
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
############################################################################################################################################################################################################################################################################################################################################################
# manual dataset
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author = b.version_removed_author and a.project_name = 'apache-ant' and a.version_removed_name != 'not_removed' and b.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author = b.version_removed_author and a.project_name = 'apache-jmeter' and a.version_removed_name != 'not_removed' and b.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author = b.version_removed_author and a.project_name = 'jruby'  and a.version_removed_name != 'not_removed' and b.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author = b.version_removed_author and a.version_removed_name != 'not_removed' and b.comment_classification = 'DESIGN'")
############################################################################################################################################################################################################################################################################################################################################################

# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author = removed_version_author and repository_id = 2 and is_introduced_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author = removed_version_author and repository_id = 3 and is_introduced_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author = removed_version_author and repository_id = 5 and is_introduced_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author = removed_version_author and repository_id = 6 and is_introduced_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author = removed_version_author and repository_id = 7 and is_introduced_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author = removed_version_author and repository_id = 8 and is_introduced_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author = removed_version_author and repository_id = 9 and is_introduced_version is true")
postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author = removed_version_author and repository_id in(2,3,5,6,7,8,9)  and is_introduced_version is true")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
seconds_in_a_day <- 86400
median(data1$epoch_time_to_remove/seconds_in_a_day)


# calculating the median in days from non self-removal TD
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
############################################################################################################################################################################################################################################################################################################################################################
# manual dataset
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author != b.version_removed_author and a.project_name = 'apache-ant' and a.version_removed_name != 'not_removed' b.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author != b.version_removed_author and a.project_name = 'apache-jmeter' and a.version_removed_name != 'not_removed' b.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author != b.version_removed_author and a.project_name = 'jruby'  and a.version_removed_name != 'not_removed' b.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author != b.version_removed_author  and a.version_removed_name != 'not_removed' b.comment_classification = 'DESIGN'")
############################################################################################################################################################################################################################################################################################################################################################

postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author != removed_version_author and repository_id = 2 and is_introduced_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author != removed_version_author and repository_id = 3 and is_introduced_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author != removed_version_author and repository_id = 5 and is_introduced_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author != removed_version_author and repository_id = 6 and is_introduced_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author != removed_version_author and repository_id = 7 and is_introduced_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author != removed_version_author and repository_id = 8 and is_introduced_version is true")
# postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author != removed_version_author and repository_id = 9 and is_introduced_version is true")
postgresql <- dbSendQuery(con, "select epoch_time_to_remove from processed_comments where introduced_version_author != removed_version_author and repository_id in(2,3,5,6,7,8,9)  and is_introduced_version is true")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
seconds_in_a_day <- 86400
median(data1$epoch_time_to_remove/seconds_in_a_day)


# self-removal beanplots (16x8)
# Ant
##################################################################################################
library(RPostgreSQL)
library(beanplot)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Ant' as project_name, epoch_time_to_remove from processed_comments where repository_id = 2 and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
postgresql <- dbSendQuery(con, "select 'Ant' as project_name, epoch_time_to_remove from processed_comments where repository_id = 2 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data2 <- fetch(postgresql, n=-1)
dim(data2)
dbHasCompleted(postgresql)
beanplot(data1$epoch_time_to_remove/86400, data2$epoch_time_to_remove/86400, names=c(data1$project_name[1]), col=list(c("#79c36a"), c("#9e66ab")),  side = 'both', log = '' , what=c(0,1,1,0))
title(ylab="Number of days", xlab = paste("Self-removal N/Mediam in days =", nrow(data1),"/", round(median(data1$epoch_time_to_remove/86400), digits = 0),"," ,"Non Self-removal N/Mediam in days =", nrow(data2),"/", round(median(data2$epoch_time_to_remove/86400), digits = 0)))
legend('topright', fill=c("#79c36a", "#9e66ab"), legend = c("Self-removal", "Non Self-removal"))
##################################################################################################

# Jmeter
##################################################################################################
library(RPostgreSQL)
library(beanplot)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Jmeter' as project_name, epoch_time_to_remove from processed_comments where repository_id = 3 and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
postgresql <- dbSendQuery(con, "select 'Jmeter' as project_name, epoch_time_to_remove from processed_comments where repository_id = 3 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data2 <- fetch(postgresql, n=-1)
dim(data2)
dbHasCompleted(postgresql)
beanplot(data1$epoch_time_to_remove/86400, data2$epoch_time_to_remove/86400, names=c(data1$project_name[1]), col=list(c("#79c36a"), c("#9e66ab")),  side = 'both', log = '' , what=c(0,1,1,0))
title(ylab="Number of days", xlab = paste("Self-removal N/Mediam in days =", nrow(data1),"/", round(median(data1$epoch_time_to_remove/86400), digits = 0),"," ,"Non Self-removal N/Mediam in days =", nrow(data2),"/", round(median(data2$epoch_time_to_remove/86400), digits = 0)))
legend('topright', fill=c("#79c36a", "#9e66ab"), legend = c("Self-removal", "Non Self-removal"))

# Camel
##################################################################################################
library(RPostgreSQL)
library(beanplot)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Camel' as project_name, epoch_time_to_remove from processed_comments where repository_id = 5 and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
postgresql <- dbSendQuery(con, "select 'Camel' as project_name, epoch_time_to_remove from processed_comments where repository_id = 5 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data2 <- fetch(postgresql, n=-1)
dim(data2)
dbHasCompleted(postgresql)
beanplot(data1$epoch_time_to_remove/86400, data2$epoch_time_to_remove/86400, names=c(data1$project_name[1]), col=list(c("#79c36a"), c("#9e66ab")),  side = 'both', log = '' , what=c(0,1,1,0))
title(ylab="Number of days", xlab = paste("Self-removal N/Mediam in days =", nrow(data1),"/", round(median(data1$epoch_time_to_remove/86400), digits = 0),"," ,"Non Self-removal N/Mediam in days =", nrow(data2),"/", round(median(data2$epoch_time_to_remove/86400), digits = 0)))
legend('topright', fill=c("#79c36a", "#9e66ab"), legend = c("Self-removal", "Non Self-removal"))

# Hadoop
##################################################################################################
library(RPostgreSQL)
library(beanplot)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Hadoop' as project_name, epoch_time_to_remove from processed_comments where repository_id = 6 and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
postgresql <- dbSendQuery(con, "select 'Hadoop' as project_name, epoch_time_to_remove from processed_comments where repository_id = 6 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data2 <- fetch(postgresql, n=-1)
dim(data2)
dbHasCompleted(postgresql)
beanplot(data1$epoch_time_to_remove/86400, data2$epoch_time_to_remove/86400, names=c(data1$project_name[1]), col=list(c("#79c36a"), c("#9e66ab")),  side = 'both', log = '' , what=c(0,1,1,0))
title(ylab="Number of days", xlab = paste("Self-removal N/Mediam in days =", nrow(data1),"/", round(median(data1$epoch_time_to_remove/86400), digits = 0),"," ,"Non Self-removal N/Mediam in days =", nrow(data2),"/", round(median(data2$epoch_time_to_remove/86400), digits = 0)))
legend('topright', fill=c("#79c36a", "#9e66ab"), legend = c("Self-removal", "Non Self-removal"))

# Tomcat
##################################################################################################
library(RPostgreSQL)
library(beanplot)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
# postgresql <- dbSendQuery(con, "select 'Tomcat' as project_name, epoch_time_to_remove from processed_comments where repository_id = 7 and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
postgresql <- dbSendQuery(con, "select 'Tomcat' as project_name, epoch_time_to_remove from processed_comments where repository_id = 7 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data2 <- fetch(postgresql, n=-1)
dim(data2)
dbHasCompleted(postgresql)
beanplot(data1$epoch_time_to_remove/86400, data2$epoch_time_to_remove/86400, names=c(data1$project_name[1]), col=list(c("#79c36a"), c("#9e66ab")),  side = 'both', log = '' , what=c(0,1,1,0))
title(ylab="Number of days", xlab = paste("Self-removal N/Mediam in days =", nrow(data1),"/", round(median(data1$epoch_time_to_remove/86400), digits = 0),"," ,"Non Self-removal N/Mediam in days =", nrow(data2),"/", round(median(data2$epoch_time_to_remove/86400), digits = 0)))
legend('topright', fill=c("#79c36a", "#9e66ab"), legend = c("Self-removal", "Non Self-removal"))

# Log4j
##################################################################################################
library(RPostgreSQL)
library(beanplot)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Log4j' as project_name, epoch_time_to_remove from processed_comments where repository_id = 8 and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
postgresql <- dbSendQuery(con, "select 'Log4j' as project_name, epoch_time_to_remove from processed_comments where repository_id = 8 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data2 <- fetch(postgresql, n=-1)
dim(data2)
dbHasCompleted(postgresql)
beanplot(data1$epoch_time_to_remove/86400, data2$epoch_time_to_remove/86400, names=c(data1$project_name[1]), col=list(c("#79c36a"), c("#9e66ab")),  side = 'both', log = '' , what=c(0,1,1,0))
title(ylab="Number of days", xlab = paste("Self-removal N/Mediam in days =", nrow(data1),"/", round(median(data1$epoch_time_to_remove/86400), digits = 0),"," ,"Non Self-removal N/Mediam in days =", nrow(data2),"/", round(median(data2$epoch_time_to_remove/86400), digits = 0)))
legend('topright', fill=c("#79c36a", "#9e66ab"), legend = c("Self-removal", "Non Self-removal"))

# Guerrit
##################################################################################################library(RPostgreSQL)
library(RPostgreSQL)
library(beanplot)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Gerrit' as project_name, epoch_time_to_remove from processed_comments where repository_id = 9 and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
postgresql <- dbSendQuery(con, "select 'Gerrit' as project_name, epoch_time_to_remove from processed_comments where repository_id = 9 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data2 <- fetch(postgresql, n=-1)
dim(data2)
dbHasCompleted(postgresql)
beanplot(data1$epoch_time_to_remove/86400, data2$epoch_time_to_remove/86400, names=c(data1$project_name[1]), col=list(c("#79c36a"), c("#9e66ab")),  side = 'both', log = '' , what=c(0,1,1,0))
title(ylab="Number of days", xlab = paste("Self-removal N/Mediam in days =", nrow(data1),"/", round(median(data1$epoch_time_to_remove/86400), digits = 0),"," ,"Non Self-removal N/Mediam in days =", nrow(data2),"/", round(median(data2$epoch_time_to_remove/86400), digits = 0)))
legend('topright', fill=c("#79c36a", "#9e66ab"), legend = c("Self-removal", "Non Self-removal"))

# All projects
##################################################################################################
library(RPostgreSQL)
library(beanplot)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'All projects' as project_name, epoch_time_to_remove from processed_comments where repository_id in (2,3,5,6,7,8,9) and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
postgresql <- dbSendQuery(con, "select 'All projects' as project_name, epoch_time_to_remove from processed_comments where repository_id in (2,3,5,6,7,8,9) and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data2 <- fetch(postgresql, n=-1)
dim(data2)
dbHasCompleted(postgresql)
beanplot(data1$epoch_time_to_remove/86400, data2$epoch_time_to_remove/86400, names=c(data1$project_name[1]), col=list(c("#79c36a"), c("#9e66ab")),  side = 'both', log = '' , what=c(0,1,1,0))
title(ylab="Number of days", xlab = paste("Self-removal N/Mediam in days =", nrow(data1),"/", round(median(data1$epoch_time_to_remove/86400), digits = 0),"," ,"Non Self-removal N/Mediam in days =", nrow(data2),"/", round(median(data2$epoch_time_to_remove/86400), digits = 0)))
legend('topright', fill=c("#79c36a", "#9e66ab"), legend = c("Self-removal", "Non Self-removal"))

# non self-removal histogram
library(RPostgreSQL)
library(vioplot)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
# #################################################################################################################################################################################################################################################################################################################################### 
# Manual dataset
# postgresql <- dbSendQuery(con, "select a.project_name, a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author != b.version_removed_author and a.project_name = 'apache-ant' and a.version_removed_name != 'not_removed' and b.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select a.project_name, a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author != b.version_removed_author and a.project_name = 'apache-jmeter' and a.version_removed_name != 'not_removed' and b.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select a.project_name, a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author != b.version_removed_author and a.project_name = 'jruby'  and a.version_removed_name != 'not_removed' and b.comment_classification = 'DESIGN'")
# #################################################################################################################################################################################################################################################################################################################################### 
# postgresql <- dbSendQuery(con, "select 'Ant' as project_name, epoch_time_to_remove from processed_comments where repository_id = 2 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Jmeter' as project_name, epoch_time_to_remove from processed_comments where repository_id = 3 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Camel' as project_name, epoch_time_to_remove from processed_comments where repository_id = 5 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Hadoop' as project_name, epoch_time_to_remove from processed_comments where repository_id = 6 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Tomcat' as project_name, epoch_time_to_remove from processed_comments where repository_id = 7 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Log4j' as project_name, epoch_time_to_remove from processed_comments where repository_id = 8 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Gerrit' as project_name, epoch_time_to_remove from processed_comments where repository_id = 9 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
postgresql <- dbSendQuery(con, "select 'All projects' as project_name, epoch_time_to_remove from processed_comments where repository_id in (2,3,5,6,7,8,9) and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")


# self-removal histogram (7x5)
library(RPostgreSQL)
library(vioplot)
library(beanplot)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
# #################################################################################################################################################################################################################################################################################################################################### 
# Manual dataset
# postgresql <- dbSendQuery(con, "select a.project_name, a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author = b.version_removed_author and a.project_name = 'apache-ant' and a.version_removed_name != 'not_removed' and b.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select a.project_name, a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author = b.version_removed_author and a.project_name = 'apache-jmeter' and a.version_removed_name != 'not_removed' and  b.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select a.project_name, a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author = b.version_removed_author and a.project_name = 'jruby'  and a.version_removed_name != 'not_removed' and b.comment_classification = 'DESIGN'")
# ####################################################################################################################################################################################################################################################################################################################################
# postgresql <- dbSendQuery(con, "select 'Ant' as project_name, epoch_time_to_remove from processed_comments where repository_id = 2 and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Jmeter' as project_name, epoch_time_to_remove from processed_comments where repository_id = 3 and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Camel' as project_name, epoch_time_to_remove from processed_comments where repository_id = 5 and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Hadoop' as project_name, epoch_time_to_remove from processed_comments where repository_id = 6 and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Tomcat' as project_name, epoch_time_to_remove from processed_comments where repository_id = 7 and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Log4j' as project_name, epoch_time_to_remove from processed_comments where repository_id = 8 and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
postgresql <- dbSendQuery(con, "select 'Gerrit' as project_name, epoch_time_to_remove from processed_comments where repository_id = 9 and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'All projects' as project_name, epoch_time_to_remove from processed_comments where repository_id in (2,3,5,6,7,8,9) and introduced_version_author = removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)

postgresql <- dbSendQuery(con, "select 'Gerrit' as project_name, epoch_time_to_remove from processed_comments where repository_id = 9 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
data2 <- fetch(postgresql, n=-1)
dim(data2)
dbHasCompleted(postgresql)

# hist(data1$epoch_time_to_remove/86400, xlab='Days to remove', main = paste('Self-removal histogram of ', data1$project_name[1]) )
# first what argument = total average line,
# second what argument = the beans,
# third what argument = the bean average,
# fourth what argument = the bean lines,
#f9a65a
#9e66ab
#cd7058
#d77fb3

#727272
#f1595f vermelho legal
#79c36a verde
#599ad3 azul
#f9a65a laranja
#9e66ab roxo
#cd7058
#d77fb3


beanplot(data1$epoch_time_to_remove/86400, data2$epoch_time_to_remove/86400, names=c(data1$project_name[1]), col=list(c("#79c36a"), c("#9e66ab")),  side = 'both', log = '' , what=c(0,1,1,0))
# vioplot(data1$epoch_time_to_remove/86400, names=c(data1$project_name[1]),   col="gold")
title(ylab="Number of days", xlab = paste("Self-removal N/Mediam in days =", nrow(data1),"/", round(median(data1$epoch_time_to_remove/86400), digits = 0),"," ,"Non Self-removal N/Mediam in days =", nrow(data2),"/", round(median(data2$epoch_time_to_remove/86400), digits = 0)))
# title(paste('Self-removal of ', data1$project_name[1]), ylab="Number of days", xlab = paste("N=", nrow(data1)," , ", "Mediam in days =", round(median(data1$epoch_time_to_remove/86400), digits = 0)))
legend('topright', fill=c("#79c36a", "#9e66ab"), legend = c("Self-removal", "Non Self-removal"))

# non self-removal histogram
library(RPostgreSQL)
library(vioplot)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
# #################################################################################################################################################################################################################################################################################################################################### 
# Manual dataset
# postgresql <- dbSendQuery(con, "select a.project_name, a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author != b.version_removed_author and a.project_name = 'apache-ant' and a.version_removed_name != 'not_removed' and b.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select a.project_name, a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author != b.version_removed_author and a.project_name = 'apache-jmeter' and a.version_removed_name != 'not_removed' and b.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select a.project_name, a.epoch_time_to_remove from time_to_remove_td a, technical_debt_summary b where a.processed_comment_id = b.processed_comment_id and b.version_introduced_author != b.version_removed_author and a.project_name = 'jruby'  and a.version_removed_name != 'not_removed' and b.comment_classification = 'DESIGN'")
# #################################################################################################################################################################################################################################################################################################################################### 
# postgresql <- dbSendQuery(con, "select 'Ant' as project_name, epoch_time_to_remove from processed_comments where repository_id = 2 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Jmeter' as project_name, epoch_time_to_remove from processed_comments where repository_id = 3 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Camel' as project_name, epoch_time_to_remove from processed_comments where repository_id = 5 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Hadoop' as project_name, epoch_time_to_remove from processed_comments where repository_id = 6 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Tomcat' as project_name, epoch_time_to_remove from processed_comments where repository_id = 7 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Log4j' as project_name, epoch_time_to_remove from processed_comments where repository_id = 8 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Gerrit' as project_name, epoch_time_to_remove from processed_comments where repository_id = 9 and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")
postgresql <- dbSendQuery(con, "select 'All projects' as project_name, epoch_time_to_remove from processed_comments where repository_id in (2,3,5,6,7,8,9) and introduced_version_author != removed_version_author and is_introduced_version is true and has_removed_version is true and td_classification = 'DESIGN'")

data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
# hist(data1$epoch_time_to_remove/86400, xlab='Days to remove', main = paste('Non self-removal histogran of ', data1$project_name[1]) )
vioplot(data1$epoch_time_to_remove/86400, names=c(data1$project_name[1]),   col="gold")
title(paste('Non self-removal of ', data1$project_name[1]), ylab="Number of days", xlab = paste("N=", nrow(data1)," , ", "Mediam in days =", round(median(data1$epoch_time_to_remove/86400), digits = 0)))

######################################################################################################################################################
# calculating survival plots apache-ant
######################################################################################################################################################
library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Ant' as project_name, a.was_td_removed, a.epoch_interval, b.comment_classification from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'apache-ant' and b.comment_classification in ('DESIGN') order by 4")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(100, 0.3, legend=c("Esimate","Lower 95%","Upper 95%"), col = 1:4, lty = 1)
summary(my.fit)

######################################################################################################################################################
# calculating survival plots apache-jmeter
######################################################################################################################################################
library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Jmeter' as project_name, a.was_td_removed, a.epoch_interval, b.comment_classification from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'apache-jmeter' and b.comment_classification in ('DESIGN') order by 4")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(100, 0.3, legend=c("Esimate","Lower 95%","Upper 95%"), col = 1:4, lty = 1)
summary(my.fit)

######################################################################################################################################################
# calculating survival plots Jruby
######################################################################################################################################################
library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Jruby' as project_name, a.was_td_removed, a.epoch_interval, b.comment_classification from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'jruby' and b.comment_classification in ('DESIGN') order by 4")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(100, 0.3, legend=c("Esimate","Lower 95%","Upper 95%"), col = 1:4, lty = 1)
summary(my.fit)

######################################################################################################################################################
# calculating survival plots Ant - Tool (12x7.5)
######################################################################################################################################################
library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Ant Tool' as project_name, a.was_td_removed, a.epoch_interval, 'DESIGN' as comment_classification from survival_plot a  where  a.project_name = 'ant'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(3400, 1.0, legend=c("Esimate","Lower 95%","Upper 95%"), col = 1:4, lty = 1)
summary(my.fit)

library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Ant Tool' as project_name, a.was_td_removed, a.epoch_interval, a.removal_authorship as comment_classification from survival_plot a  where  a.project_name = 'ant' order by 4")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(3400, 1.0, legend=c("Non self-removal","Self-removal"), col = 1:2, lty = 1)
summary(my.fit)


######################################################################################################################################################
# calculating survival plots Jmeter - Tool (12x7.5)
######################################################################################################################################################
library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Jmeter Tool' as project_name, a.was_td_removed, a.epoch_interval, 'DESIGN' as comment_classification from survival_plot a  where  a.project_name = 'jmeter'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(3400, 1.0, legend=c("Esimate","Lower 95%","Upper 95%"), col = 1:4, lty = 1)
summary(my.fit)

library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Jmeter Tool' as project_name, a.was_td_removed, a.epoch_interval, a.removal_authorship as comment_classification from survival_plot a  where  a.project_name = 'jmeter' order by 4")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(3000, 1.0, legend=c("Non self-removal","Self-removal"), col = 1:2, lty = 1)
summary(my.fit)


######################################################################################################################################################
# calculating survival plots camel - Tool (12x7.5)
######################################################################################################################################################
library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Camel' as project_name, a.was_td_removed, a.epoch_interval, 'DESIGN' as comment_classification from survival_plot a  where  a.project_name = 'camel'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(2100, 1.0, legend=c("Esimate","Lower 95%","Upper 95%"), col = 1:4, lty = 1)
summary(my.fit)

library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Camel' as project_name, a.was_td_removed, a.epoch_interval, a.removal_authorship as comment_classification from survival_plot a  where  a.project_name = 'camel' order by 4")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(2000, 1.0, legend=c("Non self-removal","Self-removal"), col = 1:2, lty = 1)
summary(my.fit)


######################################################################################################################################################
# calculating survival plots hadoop - Tool (12x7.5)
######################################################################################################################################################
library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Hadoop' as project_name, a.was_td_removed, a.epoch_interval, 'DESIGN' as comment_classification from survival_plot a  where  a.project_name = 'hadoop'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(1700, 1.0, legend=c("Esimate","Lower 95%","Upper 95%"), col = 1:4, lty = 1)
summary(my.fit)

library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Hadoop' as project_name, a.was_td_removed, a.epoch_interval, a.removal_authorship as comment_classification from survival_plot a  where  a.project_name = 'hadoop' order by 4")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(1500, 1.0, legend=c("Non self-removal","Self-removal"), col = 1:2, lty = 1)
summary(my.fit)

######################################################################################################################################################
# calculating survival plots tomcat - Tool (12x7.5)
######################################################################################################################################################
library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Tomcat' as project_name, a.was_td_removed, a.epoch_interval, 'DESIGN' as comment_classification from survival_plot a  where  a.project_name = 'tomcat'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(2400, 1.0, legend=c("Esimate","Lower 95%","Upper 95%"), col = 1:4, lty = 1)
summary(my.fit)

library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Tomcat' as project_name, a.was_td_removed, a.epoch_interval, a.removal_authorship as comment_classification from survival_plot a  where  a.project_name = 'tomcat' order by 4")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(2300, 1.0, legend=c("Non self-removal","Self-removal"), col = 1:2, lty = 1)
summary(my.fit)

######################################################################################################################################################
# calculating survival plots gerrit - Tool (12x7.5)
######################################################################################################################################################
library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Gerrit' as project_name, a.was_td_removed, a.epoch_interval, 'DESIGN' as comment_classification from survival_plot a  where  a.project_name = 'gerrit'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(1700, 1.0, legend=c("Esimate","Lower 95%","Upper 95%"), col = 1:4, lty = 1)
summary(my.fit)

library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Gerrit' as project_name, a.was_td_removed, a.epoch_interval, a.removal_authorship as comment_classification from survival_plot a  where  a.project_name = 'gerrit' order by 4")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(1500, 1.0, legend=c("Non self-removal","Self-removal"), col = 1:2, lty = 1)
summary(my.fit)

######################################################################################################################################################
# calculating survival plots Log4j - Tool (12x7.5)
######################################################################################################################################################
library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Log4j' as project_name, a.was_td_removed, a.epoch_interval, 'DESIGN' as comment_classification from survival_plot a  where  a.project_name = 'log4j'")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(3400, 1.0, legend=c("Esimate","Lower 95%","Upper 95%"), col = 1:4, lty = 1)
summary(my.fit)

library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'log4j' as project_name, a.was_td_removed, a.epoch_interval, a.removal_authorship as comment_classification from survival_plot a  where  a.project_name = 'log4j' order by 4")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(3400, 1.0, legend=c("Non self-removal","Self-removal"), col = 1:2, lty = 1)
summary(my.fit)


# calculating survival plots Gerrit - Tool (12x7.5)
######################################################################################################################################################
library(survival) 
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
postgresql <- dbSendQuery(con, "select 'Design Debt' as project_name, a.was_td_removed, a.epoch_interval, 'DESIGN' as comment_classification from survival_plot a  where  a.project_name in ('log4j', 'ant', 'jmeter', 'camel', 'hadoop', 'tomcat', 'gerrit') ")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
survival.objects = Surv(data1$epoch_interval/86400, data1$was_td_removed)
my.fit = survfit(survival.objects ~ data1$comment_classification)
plot (my.fit, main=paste("Kaplan-Meier estimate for ",data1$project_name[1]), xlab="Time in Days", ylab="Survival Function", col = 1:4) 
legend(3400, 1.0, legend=c("Esimate","Lower 95%","Upper 95%"), col = 1:4, lty = 1)
summary(my.fit)


# removals and insertion of td over time
######################################################################################################################################################
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
# postgresql <- dbSendQuery(con, "select 'Ant' as project_name, introduced_version_date, removed_version_date from processed_comments where is_introduced_version is true and repository_id = 2 ")
# postgresql <- dbSendQuery(con, "select 'Jmeter' as project_name, introduced_version_date, removed_version_date from processed_comments where is_introduced_version is true and repository_id = 3 ")
# postgresql <- dbSendQuery(con, "select 'Camel' as project_name, introduced_version_date, removed_version_date from processed_comments where is_introduced_version is true and repository_id = 5 ")
# postgresql <- dbSendQuery(con, "select 'Hadoop' as project_name, introduced_version_date, removed_version_date from processed_comments where is_introduced_version is true and repository_id = 6 ")
# postgresql <- dbSendQuery(con, "select 'Tomcat' as project_name, introduced_version_date, removed_version_date from processed_comments where is_introduced_version is true and repository_id = 7 ")
# postgresql <- dbSendQuery(con, "select 'Log4j' as project_name, introduced_version_date, removed_version_date from processed_comments where is_introduced_version is true and repository_id = 8 ")
postgresql <- dbSendQuery(con, "select 'Gerrit' as project_name, introduced_version_date, removed_version_date from processed_comments where is_introduced_version is true and repository_id = 9 ")
data1 <- fetch(postgresql, n=-1)
dim(data1)
dbHasCompleted(postgresql)
df <- c(1:length(data1$introduced_version_date))
plot(data1$introduced_version_date,df, col= 'dark green', xlab = 'time', ylab = 'frequency', main = paste('Debt introduction and removal for ', data1$project_name[1]))
points(data1$removed_version_date, df, col= 'red')


# # hist(data1$epoch_time_to_remove/86400, xlab='Days to remove', main = paste('Histogram of ', data1$comment_classification[1]))
# vioplot(data1$epoch_time_to_remove/86400, names=c(data1$comment_classification[1]),   col="gold")
# # , ylim = c(500,3500)
# title(paste(data1$comment_classification[1], 'debt for ', data1$project_name[1]), ylab="Number of days")
# summary(data1)


# calculating the median in days for different types of td
# library(RPostgreSQL)
# drv <- dbDriver("PostgreSQL")
# con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'apache-ant' and a.version_removed_name != 'not_removed' and a.comment_classification = 'DESIGN' ")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'apache-ant' and a.version_removed_name != 'not_removed' and a.comment_classification = 'DEFECT' ")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'apache-ant' and a.version_removed_name != 'not_removed' and a.comment_classification = 'TEST' ")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'apache-jmeter' and a.version_removed_name != 'not_removed' and a.comment_classification = 'DESIGN' ")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'apache-jmeter' and a.version_removed_name != 'not_removed' and a.comment_classification = 'DEFECT' ")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'jruby' and a.version_removed_name != 'not_removed' and a.comment_classification = 'DESIGN' ")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'jruby' and a.version_removed_name != 'not_removed' and a.comment_classification = 'DEFECT' ")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'jruby' and a.version_removed_name != 'not_removed' and a.comment_classification = 'IMPLEMENTATION' ")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'jruby' and a.version_removed_name != 'not_removed' and a.comment_classification = 'TEST' ")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a where a.version_removed_name != 'not_removed' and a.comment_classification = 'DESIGN' ")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a where a.version_removed_name != 'not_removed' and a.comment_classification = 'DEFECT' ")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a where a.version_removed_name != 'not_removed' and a.comment_classification = 'IMPLEMENTATION' ")
# postgresql <- dbSendQuery(con, "select a.epoch_time_to_remove from time_to_remove_td a where a.version_removed_name != 'not_removed' and a.comment_classification = 'TEST' ")
# data1 <- fetch(postgresql, n=-1)
# dim(data1)
# dbHasCompleted(postgresql)
# median(data1$epoch_time_to_remove/86400)

# Different types of TD violin plot
# library(RPostgreSQL)
# library(vioplot)
# drv <- dbDriver("PostgreSQL")
# con <- dbConnect(drv, host='localhost', port='5432', dbname='comment_classification', user='evermal', password='')
# postgresql <- dbSendQuery(con, "select 'Design Debt' as comment_classification, a.epoch_time_to_remove from time_to_remove_td a where a.version_removed_name != 'not_removed' and a.comment_classification = 'DESIGN' ")
# postgresql <- dbSendQuery(con, "select 'Defect Debt' as comment_classification, a.epoch_time_to_remove from time_to_remove_td a where a.version_removed_name != 'not_removed' and a.comment_classification = 'DEFECT' ")
# postgresql <- dbSendQuery(con, "select 'Requeriment Debt' as comment_classification, a.epoch_time_to_remove from time_to_remove_td a where a.version_removed_name != 'not_removed' and a.comment_classification = 'IMPLEMENTATION' ")
# postgresql <- dbSendQuery(con, "select 'Test Debt' as comment_classification, a.epoch_time_to_remove from time_to_remove_td a where a.version_removed_name != 'not_removed' and a.comment_classification = 'TEST' ")
# postgresql <- dbSendQuery(con, "select 'Ant' as project_name ,  a.comment_classification, a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'apache-ant' and a.version_removed_name != 'not_removed' and a.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Ant' as project_name ,  a.comment_classification, a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'apache-ant' and a.version_removed_name != 'not_removed' and a.comment_classification = 'DEFECT'")
# postgresql <- dbSendQuery(con, "select 'Ant' as project_name ,  a.comment_classification, a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'apache-ant' and a.version_removed_name != 'not_removed' and a.comment_classification = 'TEST'")
# postgresql <- dbSendQuery(con, "select 'Jmeter' as project_name, a.comment_classification , a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'apache-jmeter' and a.version_removed_name != 'not_removed' and a.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Jmeter' as project_name, a.comment_classification , a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'apache-jmeter' and a.version_removed_name != 'not_removed' and a.comment_classification = 'DEFECT'")
# postgresql <- dbSendQuery(con, "select 'JRuby' as project_name, a.comment_classification , a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'jruby' and a.version_removed_name != 'not_removed' and a.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'JRuby' as project_name, a.comment_classification , a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'jruby' and a.version_removed_name != 'not_removed' and a.comment_classification = 'DEFECT'")
# postgresql <- dbSendQuery(con, "select 'JRuby' as project_name, 'REQUIREMENT' as comment_classification , a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'jruby' and a.version_removed_name != 'not_removed' and a.comment_classification = 'IMPLEMENTATION'")
# postgresql <- dbSendQuery(con, "select 'JRuby' as project_name, a.comment_classification , a.epoch_time_to_remove from time_to_remove_td a where a.project_name = 'jruby' and a.version_removed_name != 'not_removed' and a.comment_classification = 'TEST'")
# data1 <- fetch(postgresql, n=-1)
# dim(data1)
# dbHasCompleted(postgresql)
# # hist(data1$epoch_time_to_remove/86400, xlab='Days to remove', main = paste('Histogram of ', data1$comment_classification[1]))
# vioplot(data1$epoch_time_to_remove/86400, names=c(data1$comment_classification[1]),   col="gold")
# # , ylim = c(500,3500)
# title(paste(data1$comment_classification[1], 'debt for ', data1$project_name[1]), ylab="Number of days")
# summary(data1)

######################################################################################################################################################
# taking into consideration different types of td
# postgresql <- dbSendQuery(con, "select 'Ant'     as project_name, a.was_td_removed, a.epoch_interval, b.comment_classification from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'apache-ant' and b.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Ant'     as project_name, a.was_td_removed, a.epoch_interval, b.comment_classification from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'apache-ant' and b.comment_classification = 'DEFECT'")
# postgresql <- dbSendQuery(con, "select 'Ant'     as project_name, a.was_td_removed, a.epoch_interval, b.comment_classification from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'apache-ant' and b.comment_classification = 'TEST'")
# postgresql <- dbSendQuery(con, "select 'Jmeter'  as project_name, a.was_td_removed, a.epoch_interval, b.comment_classification from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'apache-jmeter' and b.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Jmeter'  as project_name, a.was_td_removed, a.epoch_interval, b.comment_classification from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'apache-jmeter' and b.comment_classification = 'DEFECT'")
# postgresql <- dbSendQuery(con, "select 'Jruby'   as project_name, a.was_td_removed, a.epoch_interval, b.comment_classification from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'jruby' and b.comment_classification = 'DESIGN'")
# postgresql <- dbSendQuery(con, "select 'Jruby'   as project_name, a.was_td_removed, a.epoch_interval, b.comment_classification from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'jruby' and b.comment_classification = 'DEFECT'")
# postgresql <- dbSendQuery(con, "select 'Jruby'   as project_name, a.was_td_removed, a.epoch_interval, b.comment_classification from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'jruby' and b.comment_classification = 'TEST'")
# postgresql <- dbSendQuery(con, "select 'Jruby'   as project_name, a.was_td_removed, a.epoch_interval, b.comment_classification from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'jruby' and b.comment_classification = 'IMPLEMENTATION'")
######################################################################################################################################################

######################################################################################################################################################
# all projects and all types together
# postgresql <- dbSendQuery(con, "select was_td_removed, epoch_interval from survival_plot ")
######################################################################################################################################################

# ####################################################################################################################################################
# adding only the removed samples indicates that we expect that the population (td) will be dead (removed) at the end of the experiment
# postgresql <- dbSendQuery(con, "select was_td_removed, epoch_interval from survival_plot where project_name = 'apache-ant' and was_td_removed = 1")
# postgresql <- dbSendQuery(con, "select was_td_removed, epoch_interval from survival_plot where project_name = 'apache-jmeter' and was_td_removed = 1")
# postgresql <- dbSendQuery(con, "select was_td_removed, epoch_interval from survival_plot where project_name = 'jruby' and was_td_removed = 1")
######################################################################################################################################################

######################################################################################################################################################
# there are some types of td that are never removed
# postgresql <- dbSendQuery(con, "select a.was_td_removed, a.epoch_interval from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'apache-ant' and b.comment_classification = 'IMPLEMENTATION'")
# postgresql <- dbSendQuery(con, "select a.was_td_removed, a.epoch_interval from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'apache-jmeter' and b.comment_classification = 'TEST'")
# postgresql <- dbSendQuery(con, "select a.was_td_removed, a.epoch_interval from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'apache-jmeter' and b.comment_classification = 'IMPLEMENTATION'")
# postgresql <- dbSendQuery(con, "select a.was_td_removed, a.epoch_interval from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'apache-jmeter' and b.comment_classification = 'DOCUMENTATION'")
# postgresql <- dbSendQuery(con, "select a.was_td_removed, a.epoch_interval from survival_plot a, time_to_remove_td b where a.processed_comment_id = b.processed_comment_id and a.project_name = 'jruby' and b.comment_classification = 'DOCUMENTATION'")
######################################################################################################################################################