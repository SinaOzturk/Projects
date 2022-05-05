library(data.table)
library(lubridate)
library(ggplot2)
library(repr)
library(rpart)
library(rattle)
library(TSrepr)
library(zoo)
library(TunePareto)


dat=fread('YAT-01012019-10122021.csv')

setnames(dat,names(dat),c('date','hour','yat_one','yat_two','yat_three'))
dat[,datex:=strptime(date,'%d/%m/%Y')]

dat[,tst:=ymd_hm(paste(datex,hour))]
dat[,date:=date(tst)]
dat[,hour:=hour(tst)]

dat[,yat_one_t:=gsub('\\.','',yat_one)]
dat[,yat_two_t:=gsub('\\.','',yat_two)]
dat[,yat_three_t:=gsub('\\.','',yat_three)]


dat[,yat_one:=as.numeric(gsub(',','.',yat_one_t))]
dat[,yat_two:=as.numeric(gsub(',','.',yat_two_t))]
dat[,yat_three:=as.numeric(gsub(',','.',yat_three_t))]


yat_dat=dat[,list(date,hour,yat_one,yat_two,yat_three)]


dat=fread('YAL-01012019-10122021.csv')

# naming is temporary here, used the same set of codes
setnames(dat,names(dat),c('date','hour','yat_one','yat_two','yat_three'))
dat[,datex:=strptime(date,'%d/%m/%Y')]

dat[,tst:=ymd_hm(paste(datex,hour))]
dat[,date:=date(tst)]
dat[,hour:=hour(tst)]

dat[,yat_one_t:=gsub('\\.','',yat_one)]
dat[,yat_two_t:=gsub('\\.','',yat_two)]
dat[,yat_three_t:=gsub('\\.','',yat_three)]


dat[,yal_one:=as.numeric(gsub(',','.',yat_one_t))]
dat[,yal_two:=as.numeric(gsub(',','.',yat_two_t))]
dat[,yal_three:=as.numeric(gsub(',','.',yat_three_t))]


yal_dat=dat[,list(date,hour,yal_one,yal_two,yal_three)]
all_dat = cbind(yat_dat, yal_dat)
all_dat = all_dat[,-c(6:7)]
all_dat = all_dat[, sum_yat := (yat_one + yat_two + yat_three)]
all_dat = all_dat[, sum_yal := (yal_one + yal_two + yal_three)]
all_dat = all_dat[, diff := (sum_yat - sum_yal)]

for(i in 1:25800){
if(all_dat$diff[i] < -50){
  all_dat[i, sign := (-1)]
}
else if(all_dat$diff[i] > 50){
  all_dat[i, sign := 1]
}
else{
  all_dat[i, sign := 0]
}
}

  
counter = 1
wide_dat = matrix(,ncol = 24, nrow = 1075)
for (i in 1:1075){
  for (j in 1:24){
    wide_dat[i,j] = all_dat$diff[counter]
    counter = counter + 1
  } 
}

wide_dat = as.data.table(wide_dat)

# because we will able to get the 6.00 AM data at 11.00 AM, I will rearrange the data starting from 7.00AM till 6.00AM

counter = 8
wide_dat = matrix(,ncol = 24, nrow = 1074)
for (i in 1:1074){
  for (j in 1:24){
    wide_dat[i,j] = all_dat$diff[counter]
    counter = counter + 1
  } 
}

wide_dat = as.data.table(wide_dat)
colnames(wide_dat) = c("hour_7","hour_8","hour_9","hour_10","hour_11","hour_12","hour_13","hour_14","hour_15","hour_16","hour_17","hour_18","hour_19","hour_20","hour_21","hour_22","hour_23","hour_0","hour_1","hour_2","hour_3","hour_4","hour_5","hour_6")

allclass = c()
counter = 1
for(i in 24:25800){
  if(all_dat$hour[i] == 12){
    allclass[counter] = all_dat$sign[i]
    counter = counter + 1
  }
}
trainclass <- allclass[1:774]
testclass <- allclass[775:1074]
wide_dat[,id:=1:.N]
wide_dat[,class:= allclass]

long_data = melt(wide_dat,id.vars=c('id','class'))
long_data[,time:=as.numeric(gsub("\\D", "", variable))]
long_data=long_data[,list(id,class,time,value)]
long_data=long_data[order(id,time)]
head(long_data)

# Visualize the data based on Class
ggplot(long_data, aes(time,value)) + geom_line(aes(id)) +
  facet_wrap(~class)

long_data = long_data[order(id,time)]

# Divide Data into Train and Test
traindata = wide_dat[-c(775:1074),]
testdata = wide_dat[c(775:1074),]
testdata = testdata[,-c(26:26)]
setcolorder(testdata,c("id","hour_7","hour_8","hour_9","hour_10","hour_11","hour_12","hour_13","hour_14","hour_15","hour_16","hour_17","hour_18","hour_19","hour_20","hour_21","hour_22","hour_23","hour_0","hour_1","hour_2","hour_3","hour_4","hour_5","hour_6"))

# Instance Characteristics
tlength=ncol(wide_dat) - 2
n_series_train=nrow(traindata)
n_series_test=nrow(testdata)

#PAA

selected_series=1
segment_length=4
paa_rep = vector("numeric",)
control = 0
paa_rep_all = vector("numeric",)
loop_indise = n_series_train * ceiling(tlength/4)

for( i in 1:n_series_train){
  
  selected_series = i
  temp_data_ts = long_data[id == selected_series]$value
  temp_paa_rep=repr_paa(temp_data_ts, segment_length, meanC)
  paa_rep = append(paa_rep, temp_paa_rep)
  
}
for (i in 1:loop_indise){
  temp = rep(paa_rep[i], times = 4)
  paa_rep_all = append(paa_rep_all,temp)
}

long_train <- long_data[c(1:18576),]
test_train <- long_data[-c(1:18576),]

long_train[,paa_rep := paa_rep_all]
head(long_train)

paa_rep_long_train <- long_train[,-c("class","value")]
wide_paa_rep <- reshape(paa_rep_long_train, idvar = "id", v.names = "paa_rep", timevar = "time", direction = "wide")
wide_paa_rep_with_test <- rbind(wide_paa_rep,testdata, use.names=FALSE)

# Drop first column from data
wide_paa_rep_with_test <- wide_paa_rep_with_test[,2:ncol(wide_paa_rep_with_test)]

#Euclidean Distance
paa_dist_euc <- as.matrix(dist(wide_paa_rep_with_test))
large_number = 100000000
diag(paa_dist_euc) = large_number

# NN Classification
#create a loop for it!

neighborhood=apply(paa_dist_euc[775:1074,1:774],1,order) #first array entry is 1, why?
neighborhood[,1]

predicted=trainclass[neighborhood[1,]]

table(testclass,predicted)

acc=sum(testclass==predicted)/length(predicted)
print(acc)

bulk_imbalance <- read.csv("bulk_imbalance.csv")
tail(bulk_imbalance,48)
