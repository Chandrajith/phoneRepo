
library(data.table)

# Requirements
# 1.Merges the training and the test sets to create one data set.
# 2.Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3.Uses descriptive activity names to name the activities in the data set
# 4.Appropriately labels the data set with descriptive variable names. 
# 5.Creates a second, independent tidy data set with the average of each variable for 
#   each activity and each subject.

# 0. download the file to current directory
fileName <- "samsung.zip"

if (!file.exists(fileName)) {
  fileUrl  <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl, destfile = "samsung.zip", method = "curl")
  message("Download complete!")
  unzip("samsung.zip")
  message("file unzipped")
} 

setwd("UCI HAR Dataset")

# Load the files
testData          <- read.table("test/X_test.txt")
testData_label    <- read.table("test/y_test.txt")
testData_subject  <- read.table("test/subject_test.txt")

trainData         <- read.table("train/X_train.txt")
trainData_label   <- read.table("train/y_train.txt")
trainData_subject <- read.table("train/subject_train.txt")

# Uses descriptive activity names to name the activities in the data set
activities         <- read.table("activity_labels.txt",colClasses="character")
testData_label$V1  <- factor(testData_label$V1,levels=activities$V1,labels=activities$V2)
trainData_label$V1 <- factor(trainData_label$V1,levels=activities$V1,labels=activities$V2)

# Appropriately labels the data set with descriptive activity names
features <- read.table("features.txt",colClasses="character")

colnames(testData)         <- features$V2
colnames(trainData)        <- features$V2
colnames(testData_label)   <- c("Activity")
colnames(trainData_label)  <- c("Activity")
colnames(testData_subject) <- c("Subject")
colnames(trainData_subject)<- c("Subject")

# extract only the measurements on the mean and standard deviation for each measurement
## Filter anything other than std or mean

testData <- testData[,c(grepl('-(mean|std)[(]', names(testData)))]
trainData <- trainData[,c(grepl('-(mean|std)[(]', names(trainData)))]


# merge test and training sets into one data set
## [Data], [Activity]  => [Data, Activity]
testData        <- cbind(testData,testData_label)
## => [Data, Activity, Subject]
testData        <- cbind(testData,testData_subject)
## Do the same for training data
trainData       <- cbind(trainData,trainData_label)
trainData       <- cbind(trainData,trainData_subject)
allData         <- rbind(testData,trainData)

# Now we have 
# dim(allData)
# [1] 10299   68  (66 mean/std columns + Subject + Activity)

# 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
dataTable      <- data.table(allData)
tidyResult     <-dataTable[,lapply(.SD, mean),by="Activity,Subject"]
write.table(tidyResult,file="tidydata.csv", sep=",",row.names = FALSE)

