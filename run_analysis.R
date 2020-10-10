###Load libraries           ------- Only needed if using method 2 to compute averages for final dataset
#install.packages("dplyr")  ------- Install package if not already installed
#library(dplyr)             

###Download the zip file
if(!file.exists("data")){dir.create("data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dir <- getwd()
destFile <- "UCI_HAR_Datasets.zip"
destFileWithPath <- as.character(paste(dir,"data",destFile, sep = "/"))
download.file(fileUrl, destFileWithPath, method = "curl", mode = "wb")
dateDownloaded <- date()

###Unzip the downloaded file
#args(unzip)
unzip(destFileWithPath, exdir="./data")

##Make sure zip file and extracted files exist
list.files("./data")

###Get list of extracted files
##Define folder path 
filePath = file.path("./data", "UCI HAR Dataset")
#List all 28 file names
files = list.files(filePath, recursive=TRUE)
files

###Read Files
#Read Training Data - X_train, y_train and subject_train
xTrain <- read.table(file.path(filePath,"train","X_train.txt"), header = FALSE)
yTrain <- read.table(file.path(filePath,"train","y_train.txt"), header = FALSE)
subjectTrain <- read.table(file.path(filePath,"train","subject_train.txt"), header = FALSE)

#Read Testing Data - X_test, y_test and subject_test
xTest <- read.table(file.path(filePath,"test","X_test.txt"), header = FALSE)
yTest <- read.table(file.path(filePath,"test","y_test.txt"), header = FALSE)
subjectTest <- read.table(file.path(filePath,"test","subject_test.txt"), header = FALSE)

#Read the Features Data
features = read.table(file.path(filePath, "features.txt"), header = FALSE)

#Read the Activity Labels data
activityLabels = read.table(file.path(filePath, "activity_labels.txt"), header = FALSE)

###Merge training and test datasets individually for x, y and subject data
xData       <- rbind(xTrain, xTest)
yData       <- rbind(yTrain, yTest)
subjectData <- rbind(subjectTrain, subjectTest)

##names(xData)
##names(yData)
##names(subjectData)
##nrow(features)
##head(yData, n =2)

###Assign Column Names
colnames(xData)       <- features[,2]
colnames(yData)       <- "activityID"
colnames(subjectData) <- "subjectID"
colnames(activityLabels) <- c("activityID","activityName")

###Select only mean and std from xData
meanOrStdVariable <- grepl(".*mean\\(\\)|std\\(\\)", names(xData), ignore.case = FALSE)
#names(xData[,meanOrStdVariable])

###Merge all x (mean or std variables only), y and subject datasets together
combinedData <- cbind(subjectData, yData, xData[,meanOrStdVariable])
#names(combinedData)

###Merge Activity Names
combinedData <- merge(combinedData, activityLabels, by='activityID', all.x=TRUE)

### Get Average of each variable by Activity and Subject 
combinedDataMean <- aggregate(. ~subjectID + activityID + activityName, combinedData, mean)

###Method 2: Turn activities & subjects into factors and summarize
#combinedData$activityID <- factor(combinedData$activityID, levels = activityLabels[,1], labels = activityLabels[,2]) 
#combinedData$subjectID  <- as.factor(combinedData$subjectID) 
#combinedDataMean <- combinedData %>% group_by(activityID, subjectID) %>% summarize_all(funs(mean)) 

###Sort the Dataset
combinedDataMean <- combinedDataMean[order(combinedDataMean$subjectID, combinedDataMean$activityID),]

###Export Clean Dataset
write.table(combinedDataMean, file = "./tidydata.txt", row.names = FALSE, col.names = TRUE) 
