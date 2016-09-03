library(dplyr)
wd <- "/Users/jeffgrover/Dropbox/Coursera/3 Getting and Cleaning Data/Project/UCI HAR Dataset"
setwd(wd)

# Import data

## Import measurements
test <- read.table(paste0(wd,"/test/X_test.txt"))
train <- read.table(paste0(wd,"/train/X_train.txt"))

## Import measurement variable labels
## Important to do this before adding more variables
varnames <- read.table(paste0(wd,"/features.txt"))[2]
names(test) <- as.character(varnames$V2)
names(train) <- as.character(varnames$V2)

## Import subject ID and activity ID variables and add them to the respective datasets.
## read.table() imports tables as data frames, so extract the values as a factor variable.
test$subject <- read.table(paste0(wd,"/test/subject_test.txt"), colClasses="factor")$V1
test$activity <- read.table(paste0(wd,"/test/y_test.txt"), colClasses="factor")$V1
train$subject <- read.table(paste0(wd,"/train/subject_train.txt"), colClasses="factor")$V1
train$activity <- read.table(paste0(wd,"/train/y_train.txt"), colClasses="factor")$V1

# Clean data

## Replace activity ID numbers with descriptive labels
activity.labels <- read.table(paste0(wd,"/activity_labels.txt"))
levels(test$activity) <- activity.labels$V2
levels(train$activity) <- activity.labels$V2

## Some value variable names are duplicates. This will prevent us from merging the datasets properly.
## Find the duplicates:
varnames.duplicates <- data.frame(table(varnames))
varnames.duplicates[varnames.duplicates$Freq>1,]
## All the duplicate variables have "-bandsEnergy() in the name.
## These aren't means or st devs, so we can drop them in this project.
## Keep only variables that do not have duplicate names:
test <- test[, !duplicated(names(test))]
train <- train[, !duplicated(names(train))]

## Add a variable to keep track of test data and training data
test$sample <- as.factor(rep("test", dim(test)[1]))
train$sample <- as.factor(rep("train", dim(train)[1]))

## Keep only variables that have "mean" or "std" in the name, as well as the ID variables we created above:
test <- test[,grepl("[Mm]ean|std|subject|activity|sample", names(test))]
train <- train[,grepl("[Mm]ean|std|subject|activity|sample", names(train))]

## Append test and train sets to form one dataset
data <- rbind(test, train)

##########################
## Summarizing the data ##
##########################

## Split the dataset by subject and activity
data.averages <- data %>% group_by(subject, activity)
## Calculate the mean of each measurement variable for each subject doing each activity
data.averages <- data.averages %>% summarize_all(mean) %>% select(-sample)

## Export 
write.table(data.averages, file="j.grover.data.txt", row.names=FALSE)