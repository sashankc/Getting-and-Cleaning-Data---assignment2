##load data files in R

# train data file
train<-read.table("UCI HAR Dataset/train/X_train.txt",  stringsAsFactors=FALSE, header=FALSE)
# test data file
test<-read.table("UCI HAR Dataset/test/X_test.txt",  stringsAsFactors=FALSE, header=FALSE)
# features file
features<-read.table("UCI HAR Dataset/features.txt",  stringsAsFactors=FALSE,
                     header=FALSE)
# subject data for train and test
sub_train<-read.table("UCI HAR Dataset/train/subject_train.txt",  stringsAsFactors=FALSE, header=FALSE)
sub_test<-read.table("UCI HAR Dataset/test/subject_test.txt",  stringsAsFactors=FALSE, header=FALSE)
# activity data for train and test
act_train<-read.table("UCI HAR Dataset/train/y_train.txt",  stringsAsFactors=FALSE, header=FALSE)
act_test<-read.table("UCI HAR Dataset/test/y_test.txt",  stringsAsFactors=FALSE, header=FALSE)
#  activity labels
act_lbl<-read.table("UCI HAR Dataset/activity_labels.txt",  stringsAsFactors=FALSE, header=FALSE)



# add header to subject and activity
names(sub_train)<-"Subject"
names(act_train)<-"Activity"
names(sub_test)<-"Subject"
names(act_test)<-"Activity"


# add the header to the data file
names(test)<-features[,2]
names(train)<-features[,2]


## Exclude all columns except those ENDING with mean and sub data

# the brackets and hyphen in the header are not valid hence select does not work
# first remove the special characters from headers
valid_column_names <- make.names(names=names(test), unique=TRUE, allow_ = TRUE)

#apply these headers back to data
names(test)<-valid_column_names
names(train)<-valid_column_names

library(dplyr)
#do a select to get only those ending with "Mean" or "std" in the header
reduced_test<-select(test, contains("Mean..."),contains("std..."))
reduced_train<-select(train, contains("Mean..."),contains("std..."))

# replacing activity numbers with labels
act_lbl_train_name<-act_lbl[match(act_train[,], act_lbl[,1]),2]
act_lbl_test_name<-act_lbl[match(act_test[,], act_lbl[,1]),2]


# add sub and activity columns
# bind subject and activity with the data
complete_train<-cbind(sub_train, Activity=act_lbl_train_name, reduced_train)
complete_test<-cbind(sub_test, Activity=act_lbl_test_name, reduced_test)

# rename the names back to original
names<-names(data)
#replace ... by ()
names<-gsub("std..","std()", names)
names<-gsub("mean..","mean()", names)
# replace . by -
names<-gsub("[:.:]","-", names)

#reset back the name
names(data)<-names

# combine the train and test files
# group by Subject and activity
# summarise the columns to calculate the mean
result<-rbind(complete_train, complete_test) %>%
  group_by(Subject,Activity) %>% 
  summarise_each(funs(mean))

write.table(result, row.name=FALSE)

