library(data.table)
library(lubridate)
library(ggplot2)
library(repr)
library(rpart)
library(rattle)
library(TSrepr)
library(zoo)
library(TunePareto)

# Path Determination

# assuming you have the data folder in your working directory in the following format:
# 'working_directory/ClassificationData/dataset_name/'

current_folder=getwd()
dataset='wide_yat_data'
hour_inf ='12'
main_path=sprintf('%s/ClassificationData/%s',current_folder,dataset)
dist_path=sprintf('%s/ClassificationData/%s/%s',current_folder,dataset,hour_inf)

# Reading the univariate data from local

data_path = sprintf('%s/%s_%s.csv',dist_path,dataset,hour_inf)
data = as.matrix(fread(data_path))

# First column is the class data of time series
allclass <- data[,1]

#create long format of the data
data <- as.data.table(data)
setnames(data,'V1','class')
data[,class:=as.character(class)]
data[,id:=1:.N]
head(data)

#melt the data for long format
long_train = melt(data,id.vars=c('id','class'))
long_train[,time:=as.numeric(gsub("\\D", "", variable))-1]
long_train=long_train[,list(id,class,time,value)]
long_train=long_train[order(id,time)]
head(long_train)

# Visualize the data based on Class
ggplot(long_train[1:240,], aes(time,value)) + geom_line(aes(color=as.character(id))) +
  facet_wrap(~class)

# Sort long table in order to make sure for last time
long_train = long_train[order(id,time)]

# Instance Characteristics
tlength=ncol(data) - 2
n_series_train=nrow(data)

#Piecewise Aggregate Approximations

#Parameter Set 1

selected_series=1
segment_length=4
paa_rep = vector("numeric",)
control = 0
paa_rep_all = vector("numeric",)
loop_indise = n_series_train * ceiling(tlength/4)

for( i in 1:n_series_train){
  
  selected_series = i
  temp_data_ts = long_train[id == selected_series]$value
  temp_paa_rep=repr_paa(temp_data_ts, segment_length, meanC)
  paa_rep = append(paa_rep, temp_paa_rep)
  
}

for( i in 1:loop_indise){
    temp = rep(paa_rep[i], times = 4)
    paa_rep_all = append(paa_rep_all,temp)
}

long_train[,paa_rep := paa_rep_all]
head(long_train)
