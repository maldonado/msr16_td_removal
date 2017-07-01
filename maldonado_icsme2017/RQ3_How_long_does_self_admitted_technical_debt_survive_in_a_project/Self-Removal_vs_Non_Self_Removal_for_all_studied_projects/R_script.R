par(mfrow=c(1,5))
library(beanplot)


#Please provide the path to the data of research question #3 
#data_path <- "../The_Artifacts_Track/RQ3_How_long_does_self_admitted_technical_debt_survive_in_a_project/Self-Removal_vs_Non_Self_Removal_for_all_studied_projects/"
data_path <- ""



bean_plot <- function(self_removel, non_self_removal, project_name){
  
  beanplot(self_removel$epoch_time_to_remove/86400, non_self_removal$epoch_time_to_remove/86400, names=c(self_removel$project_name[1]), col=list(c("#004c99"), c("#C0C0C0")),  
           side = 'both', log = 'auto' , what=c(0,1,1,0),xaxt="n",ylab="Number of days (log scaled)",
           prob=FALSE, cex.lab=1.5, cex.axis=1.5, cex.main=2, cex.sub=1.5 ,lwd=1)
  title(project_name,prob=FALSE, cex.lab=1.5, cex.axis=1.5, cex.main=2, cex.sub=1.5 ,lwd=1)
  title( xlab = paste("Self-removal N/Mediam in days =", nrow(self_removel),"/", round(median(self_removel$epoch_time_to_remove/86400), digits = 0),",\n" ,"Non Self-removal N/Mediam in days =", nrow(non_self_removal),"/", round(median(non_self_removal$epoch_time_to_remove/86400), digits = 0)))
 
  
}







### Camel Project
self_removal_for_Camel <- read_csv(paste(data_path,"self_removal_for_Camel.csv",sep=""))
non_self_removal_for_Camel <- read_csv(paste(data_path,"non_self_removal_for_Camel.csv",sep=""))
bean_plot(self_removal_for_Camel, non_self_removal_for_Camel,"Camel Project")


### Gerrit Project
self_removal_for_Gerrit <- read_csv(paste(data_path,"self_removal_for_Gerrit.csv",sep=""))
non_self_removal_for_Gerrit <- read_csv(paste(data_path,"non_self_removal_for_Gerrit.csv",sep=""))
bean_plot(self_removal_for_Gerrit, non_self_removal_for_Gerrit,"Gerrit Project")


### Hadoop Project
self_removal_for_Hadoop <- read_csv(paste(data_path,"self_removal_for_Hadoop.csv",sep=""))
non_self_removal_for_Hadoop <- read_csv(paste(data_path,"non_self_removal_for_Hadoop.csv",sep=""))
bean_plot(self_removal_for_Hadoop, non_self_removal_for_Hadoop,"Hadoop Project")


### Log4j Project
self_removal_for_Log4j <- read_csv(paste(data_path,"self_removal_for_Log4j.csv",sep=""))
non_self_removal_for_Log4j <- read_csv(paste(data_path,"non_self_removal_for_Log4j.csv",sep=""))
bean_plot(self_removal_for_Log4j, non_self_removal_for_Log4j,"Log4j Project")


### Tomcat Project
self_removal_for_Tomcat <- read_csv(paste(data_path,"self_removal_for_Tomcat.csv",sep=""))
non_self_removal_for_Tomcat <- read_csv(paste(data_path,"non_self_removal_for_Tomcat.csv",sep=""))
bean_plot(self_removal_for_Tomcat, non_self_removal_for_Tomcat,"Tomcat Project")
