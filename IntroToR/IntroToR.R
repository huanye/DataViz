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
