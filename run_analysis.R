library(data.table)
library(reshape2)
#1 read all the data in test and train folder
test.labels <- read.table("test/y_test.txt", col.names="label")
test.subjects <- read.table("test/subject_test.txt", col.names="subject")
test.data <- read.table("test/X_test.txt")
train.labels <- read.table("train/y_train.txt", col.names="label")
train.subjects <- read.table("train/subject_train.txt", col.names="subject")
train.data <- read.table("train/X_train.txt")
# merge data together in following format: subjects, labels, data
data <- rbind(cbind(test.subjects, test.labels, test.data),
              cbind(train.subjects, train.labels, train.data))

#2 read the features
features <- read.table("features.txt", strip.white=TRUE, stringsAsFactors=FALSE)
# only retrieve features of mean and standard deviation
features.meanstd <- features[grep("mean\\(\\)|std\\(\\)", features$V2), ]
# select only the means and standard deviations from data
# increment by 2 because data has subjects and labels in the first columns
data.meanstd <- data[, c(1, 2, features.meanstd$V1+2)]

#3 read the labels
labels <- read.table("activity_labels.txt", stringsAsFactors=FALSE)
# replace labels in data with label names
data.meanstd$label <- labels[data.meanstd$label, 2]

#4 first make a list of the current column names and feature names
features.colnames <- c("subject", "label", features.meanstd$V2)
# then tidy that list by removing every non-alphabetic character and converting to lowercase
features.colnames <- tolower(gsub("[^[:alpha:]]", "", features.colnames))
# then use the list as column names for data
colnames(data.meanstd) <- features.colnames

#5 find the mean for each combination of subject and label
aggregatedata <- aggregate(data.meanstd[, 3:ncol(data.meanstd)],
                       by=list(subject = data.meanstd$subject, 
                               label = data.meanstd$label),
                       mean)
# write the data for course upload
write.table(format(aggregatedata, scientific=T), "tidydataset.txt",
            row.names=F, col.names=F, quote=2)
