library(survival)
library(readr)
library(beanplot)


par(mfrow=c(2,3))



Survival_plots <- function(data){
  
  survival.objects = Surv(data$epoch_interval/86400, data$was_td_removed)
  my.fit = survfit(survival.objects ~ data$comment_classification)
  plot (my.fit, main=paste(data$project_name[1], " Project"), xlab="Time in Days", ylab="Survival Function", col = 1:4,
        prob=FALSE, cex.lab=1.5, cex.axis=1.5, cex.main=2, cex.sub=1.5 ,lwd=1 ) 
  
  box(lwd=1.95) 
  
  legend(2400, 1.0, legend=c("Esimate","Lower 95%","Upper 95%"), col = 1:4, lty = 1, bty = "n",cex=1.4, pt.cex = 1.9)
  summary(my.fit)
  
}


#Please provide the path to the data of research question #3 
#data_path <- "../The_Artifacts_Track/RQ3_How_long_does_self_admitted_technical_debt_survive_in_a_project/Survival_plots_show_the_probability_of_the_removal_of_self_admitted_technical_debt_comment_for_all_studied_projects/"


data_path <- ""
list_of_files <-list.files(data_path, pattern = "\\.csv$")
list_of_files

for (file_name in list_of_files) {
  
  project_data <- read_csv(paste(data_path,file_name,sep=""))
  Survival_plots(project_data)
  
  
  
}







