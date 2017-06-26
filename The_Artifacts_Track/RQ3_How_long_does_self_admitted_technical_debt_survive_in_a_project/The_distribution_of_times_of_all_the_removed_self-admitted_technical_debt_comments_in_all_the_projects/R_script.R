library(readr)
library(beanplot)


par(mfrow=c(1,5))

box_plot <- function(data, file_name){
  
  
  file_name <- sub('\\.csv$', '', file_name)
  boxplot(data$epoch_time_to_remove/86400, main = file_name,
          xlab=paste("Average =", round(mean(data$epoch_time_to_remove/86400),digits = 1),
          "\nMedian =", round(median(data$epoch_time_to_remove/86400),digits = 1)), cex.lab=1.5,
          cex.axis=1.5, cex.main=2, cex.sub=1.5 ,lwd=1, ylab="Number of days")
  
}



# Please provide the the script path here
#script_path <- "../RQ3_How_long_does_self_admitted_technical_debt_survive_in_a_project/The_distribution_of_times_of_all_the_removed_self-admitted_technical_debt_comments_in_all_the_projects/"

script_path <- ""
list_of_files <-list.files(script_path, pattern = "\\.csv$")
list_of_files

for (file_name in list_of_files) {

  project_data <- read_csv(paste(script_path,file_name,sep=""))
  box_plot(project_data, file_name)
  
 
  
}











