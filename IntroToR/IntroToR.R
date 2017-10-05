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
acc2014 <-mutate(acc2014,TWAY_ID2 = na_if(TWAY_ID2, ""))
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


# merge on another data source
fips <- read_csv("fips.csv")
glimpse(fips)

# convert state and county variables in acc from integers
# to characters
acc <- mutate(acc,STATE = as.character(STATE))
acc <- mutate(acc,COUNTY = as.character(COUNTY))
# padding
acc <- mutate(acc,STATE = str_pad(STATE,2,"left","0"))
acc <- mutate(acc,COUNTY = str_pad(COUNTY,3,"left","0"))
# rename
acc <- rename(acc,StateFIPSCode=STATE)
acc <- rename(acc,CountyFIPSCode=COUNTY)
# merge 
acc <- left_join(acc,fips,by=c("StateFIPSCode","CountyFIPSCode"))

# exploratory data analysis
by_state_year <- group_by(acc,StateName,YEAR)
agg <- summarise(by_state_year,TOTAL = sum(FATALS))
agg_wide <- spread(agg,"YEAR",'TOTAL')
agg_wide <- rename(agg_wide,Year2014=`2014`)
agg_wide <- rename(agg_wide,Year2015=`2015`)
agg <- mutate(agg_wide,Diff_Percent = (Year2015-Year2014)/Year2014)
agg <- arrange(agg,Diff_Percent)
agg <- filter(agg,Diff_Percent>0.15)
agg <- filter(agg,!is.na(StateName))

# rewrite the prior steps using dplyr's chain operator %>%
agg <- acc %>%
       group_by(StateName,YEAR) %>% 
       summarise(TOTAL = sum(FATALS)) %>%
       spread("YEAR",'TOTAL') %>%
       rename(Year2014=`2014`) %>%
       rename(Year2015=`2015`) %>%
       mutate(Diff_Percent = (Year2015-Year2014)/Year2014) %>%
       arrange(Diff_Percent)  %>%
       filter(Diff_Percent>0.15) %>%
       filter(!is.na(StateName))

 glimpse(agg)
