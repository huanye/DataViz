# load libraries
library(readr)
library(haven)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

# load data into R
acc2014 <- read_sas("accident.sas7bdat")
acc2015 <- read_csv("accident.csv")
ls()
class(acc2014)
class(acc2015)


# combining the two years of FARS data

# convert the missing values of TWAY_ID2 from empty strings to NA
acc2014=mutate(acc2014,TWAY_ID2 = na_if(TWAY_ID2, ""))
# check column name difference between the two tables
# the identified four column names are "ROAD_FNC","RUR_URB","FUNC_SYS"
# and "RD_OWNER"
colnames(acc2014) %in% colnames(acc2015)
colnames(acc2014)[19]
# the column named "ROAD_FNC" is missing from dataset acc2015
colnames(acc2015) %in% colnames(acc2014)
colnames(acc2015)[19:21]
# three columns named "RUR_URB","FUNC_SYS" and "RD_OWNER"
# are missing from dataset acc2014

# combine two datasets and count the number of NAs in column
# RUR_URB in the combined dataset
acc <- bind_rows(acc2014,acc2015)
count(acc,RUR_URB)
# it turns out the number of NAs in column RUR_URB is 
# the exact number of rows in dataset acc2014, and this 
# is because acc2014 originally does not contain the 
# column RUR_URB, and when it is combined with acc2015 
# by row,  RUR_URB values are set to be NAs by default 
# when they are added to those rows from dataset acc2014.  