Getting_Cleaning_Data_Coursera_Project-
=======================================
The purpose of this project is to demonstrate one's ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis.

Data: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

Repo contains one R script "run_analysis.R" that does the following.

    1 Merges the training and the test sets to create one data set.
    2 Extracts only the measurements on the mean and standard deviation for each measurement.
    3 Uses descriptive activity names to name the activities in the data set.
    4 Appropriately labels the data set with descriptive variable names.
    5 Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

This script assumes the Samsung data is extracted in your working directory
Type source("run_analysis.R") to run the R code

This will result in creation of two files in your working directory

1.Req_files.txt
2.Req_files.csv
