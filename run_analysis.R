##############################################################################
# FILE: run_analysis.R
##############################################################################

library(dplyr)
##############################################################################
# Download, Unzip and read Data
##############################################################################


SourceUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
SourceFile <- "UCI HAR Dataset.zip"

download.file(SourceUrl, SourceFile, mode = "wb")

WDdataPath <- "UCI HAR Dataset"
if (!file.exists(WDdataPath)) {
        unzip(SourceFile)
}

training_Subjects <- read.table(file.path(WDdataPath, "train", "subject_train.txt"))
test_Subjects <- read.table(file.path(WDdataPath, "test", "subject_test.txt"))

training_Values <- read.table(file.path(WDdataPath, "train", "X_train.txt"))
test_Values <- read.table(file.path(WDdataPath, "test", "X_test.txt"))

training_Activity <- read.table(file.path(WDdataPath, "train", "y_train.txt"))
test_Activity <- read.table(file.path(WDdataPath, "test", "y_test.txt"))






features <- read.table(file.path(WDdataPath, "features.txt"), as.is = TRUE)
activities <- read.table(file.path(WDdataPath, "activity_labels.txt"))
colnames(activities) <- c("activityId", "activityLabel")


#############################################################################
# Merge All Source Data



training_Data=cbind(training_Subjects, training_Values, training_Activity)
test_Data=cbind(test_Subjects, test_Values, test_Activity)


humActivity <- rbind(training_Data, test_Data)

# remove source  data tables, no more need it
rm(training_Subjects, training_Values, training_Activity)
rm(test_Subjects, test_Values, test_Activity)
rm(training_Data, test_Data)
   
# assign column names
colnames(humActivity) <- c("subject", features[, 2], "activity")


##############################################################################
# clean data, keep columns only subject|activity|mean|std column name

colsToKeep <- grepl("subject|activity|mean|std", colnames(humActivity))
humActivity <- humActivity[, colsToKeep]


##############################################################################
# change activity values from factor levels
humActivity$activity <- factor(humActivity$activity, 
                                 levels = activities[, 1], labels = activities[, 2])



##############################################################################
# GRoup and Write
humActivityMeans <- humActivity %>% 
        group_by(subject, activity) %>%
        summarise_each( list(mean))

# output to file "tidy_data.txt"
write.table(humActivityMeans, "tidy_data.txt", row.names = FALSE, quote = FALSE)
