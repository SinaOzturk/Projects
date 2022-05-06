# Libraries

library(data.table)
library(ggplot2)
library(TSdist)
library(dtw)
library(rpart)
library(rattle)
library(zoo)
library(repr)
library(TSrepr)
library(Rcpp)
library(TunePareto)

# Path Determination
current_folder=getwd()
dataset='GunPointMaleVersusFemale'
main_path=sprintf('%s/ClassificationData/%s',current_folder,dataset)
dist_path=sprintf('%s/ClassificationData/%s/distances/%s',current_folder,dataset,dataset)

# Reading the univariate data from local

train_data_path=sprintf('%s/%s_TRAIN.txt',main_path,dataset)
traindata=as.matrix(fread(train_data_path))

test_data_path=sprintf('%s/%s_TEST.txt',main_path,dataset)
testdata=as.matrix(fread(test_data_path))

# First column is the class data of time series
trainclass <- traindata[,1]
testclass <- testdata[,1]
allclass <- c(trainclass, testclass)

#create long format of the data
traindata <- as.data.table(traindata)
setnames(traindata,'V1','class')
traindata = traindata[order(class)]
traindata[,class:=as.character(class)]
traindata[,id:=1:.N]
head(traindata)

#melt the data for long format
long_train = melt(traindata,id.vars=c('id','class'))
head(long_train)
long_train[,time:=as.numeric(gsub("\\D", "", variable))-1]
head(long_train)
long_train=long_train[,list(id,class,time,value)]
long_train=long_train[order(id,time)]
head(long_train)

# Visualize the data based on Class
ggplot(long_train, aes(time,value)) + geom_line(aes(color=as.character(id))) +
  facet_wrap(~class)

# Sort long table
long_train = long_train[order(id,time)]

# Instance Characteristics
tlength=ncol(traindata) - 2
n_series_train=nrow(traindata)
n_series_test=nrow(testdata)


#PAA

#Parameter Set 1
# Set parameters for PAA
selected_series=1
segment_length=5

paa_rep = vector("numeric",)
for( i in 1:n_series_train){
  
  selected_series = i
  temp_data_ts = long_train[id == selected_series]$value
  temp_paa_rep=repr_paa(temp_data_ts, segment_length, meanC)
  paa_rep = append(paa_rep, temp_paa_rep)
  
}

control = 0
paa_rep_all = vector("numeric",)
loop_indise = n_series_train * ceiling(tlength/5)
  
for( i in 1:loop_indise){
  if(dataset == "ECG200"){
    if(control != 19){
      temp = rep(paa_rep[i], times = 5)
      paa_rep_all = append(paa_rep_all,temp)
      control = control + 1
    }
    else{
      paa_rep_all = append(paa_rep_all,paa_rep[i])
      control = 0
    }
  }
  if(dataset == "PowerCons"){
    if(control != 28){
      temp = rep(paa_rep[i], times = 5)
      paa_rep_all = append(paa_rep_all,temp)
      control = control + 1
    }
    else{
      temp = rep(paa_rep[i], times = 4)
      paa_rep_all = append(paa_rep_all,temp)
      control = 0
    }
  }
  if(dataset == "Plane"){
    if(control != 28){
      temp = rep(paa_rep[i], times = 5)
      paa_rep_all = append(paa_rep_all,temp)
      control = control + 1
    }
    else{
      temp = rep(paa_rep[i], times = 4)
      paa_rep_all = append(paa_rep_all,temp)
      control = 0
    }
  }
  if(dataset == "GunPointMaleVersusFemale"){
    temp = rep(paa_rep[i], times = 5)
    paa_rep_all = append(paa_rep_all,temp)
  }
  if(dataset == "GunPointAgeSpan"){
    temp = rep(paa_rep[i], times = 5)
    paa_rep_all = append(paa_rep_all,temp)
  }
}

long_train[,paa_rep := paa_rep_all]
long_train

#Parameter Set 2
segment_length=10

paa_rep_2 = vector("numeric",)
for( i in 1:n_series_train){
  
  selected_series = i
  temp_data_ts = long_train[id == selected_series]$value
  temp_paa_rep=repr_paa(temp_data_ts, segment_length, meanC)
  paa_rep_2 = append(paa_rep_2, temp_paa_rep)
  
}

control = 0
paa_rep_all_2 = vector("numeric",)
loop_indise = n_series_train * ceiling(tlength/10)

for( i in 1:loop_indise){
  if(dataset == "ECG200"){
    if(control != 9){
      temp = rep(paa_rep_2[i], times = 10)
      paa_rep_all_2 = append(paa_rep_all_2,temp)
      control = control + 1
    }
    else{
      temp = rep(paa_rep_2[i], times = 6)
      paa_rep_all_2 = append(paa_rep_all_2,temp)
      control = 0
    }
  }
  if(dataset == "PowerCons"){
    if(control != 14){
      temp = rep(paa_rep_2[i], times = 10)
      paa_rep_all_2 = append(paa_rep_all_2,temp)
      control = control + 1
    }
    else{
      temp = rep(paa_rep_2[i], times = 4)
      paa_rep_all_2 = append(paa_rep_all_2,temp)
      control = 0
    }
  }
  if(dataset == "Plane"){
    if(control != 14){
      temp = rep(paa_rep_2[i], times = 10)
      paa_rep_all_2 = append(paa_rep_all_2,temp)
      control = control + 1
    }
    else{
      temp = rep(paa_rep_2[i], times = 4)
      paa_rep_all_2 = append(paa_rep_all_2,temp)
      control = 0
    }
  }
  if(dataset == "GunPointMaleVersusFemale"){
    temp = rep(paa_rep_2[i], times = 10)
    paa_rep_all_2 = append(paa_rep_all_2,temp)
  }
  if(dataset == "GunPointAgeSpan"){
    temp = rep(paa_rep_2[i], times = 10)
    paa_rep_all_2 = append(paa_rep_all_2,temp)
  }
}

long_train[,paa_rep_2 := paa_rep_all_2]
long_train

#SAX

#Parameter Set 1
sax_segment_length=4
sax_alphabet_size=5

sax_rep = vector("character",)
for( i in 1:n_series_train){
  
  selected_series = i
  temp_data_ts = long_train[id == selected_series]$value
  temp_sax_rep=repr_sax(temp_data_ts, q = sax_segment_length, a = sax_alphabet_size)
  sax_rep = append(sax_rep, temp_sax_rep)
  
}

sax_rep_all = vector("character",)
loop_indise = n_series_train * ceiling(tlength/4)

for( i in 1:loop_indise){
  if(dataset == "ECG200"){
    temp = rep(sax_rep[i], times = 4)
    sax_rep_all = append(sax_rep_all,temp)
  }
  if(dataset == "PowerCons"){
    temp = rep(sax_rep[i], times = 4)
    sax_rep_all = append(sax_rep_all,temp)
  }
  if(dataset == "Plane"){
    temp = rep(sax_rep[i], times = 4)
    sax_rep_all = append(sax_rep_all,temp)
  }
  if(dataset == "GunPointMaleVersusFemale"){
    
    if(control != 37){
      temp = rep(sax_rep[i], times = 4)
      sax_rep_all = append(sax_rep_all,temp)
      control = control + 1
    }
    else{
      temp = rep(sax_rep[i], times = 2)
      sax_rep_all = append(sax_rep_all,temp)
      control = 0
    }
  }
  if(dataset == "GunPointAgeSpan"){
    if(control != 37){
      temp = rep(sax_rep[i], times = 4)
      sax_rep_all = append(sax_rep_all,temp)
      control = control + 1
    }
    else{
      temp = rep(sax_rep[i], times = 2)
      sax_rep_all = append(sax_rep_all,temp)
      control = 0
    }
  }
}

long_train[,sax_rep_char := sax_rep_all]
long_train

long_train[,sax_rep_char_num := as.numeric(as.factor(sax_rep_all))]  
long_train[,sax_rep:=mean(value),by = list(id,sax_rep_char_num)]
long_train$sax_rep = as.numeric(long_train$sax_rep)

#Parameter Set 2

sax_segment_length=8
sax_alphabet_size=4

sax_rep_2 = vector("character",)

for( i in 1:n_series_train){
  
  selected_series = i
  temp_data_ts = long_train[id == selected_series]$value
  temp_sax_rep=repr_sax(temp_data_ts, q = sax_segment_length, a = sax_alphabet_size)
  sax_rep_2 = append(sax_rep_2, temp_sax_rep)
  
}

sax_rep_all_2 = vector("character",)
loop_indise = n_series_train * ceiling(tlength/8)

for( i in 1:loop_indise){
  if(dataset == "ECG200"){
    temp = rep(sax_rep_2[i], times = 8)
    sax_rep_all_2 = append(sax_rep_all_2,temp)
  }
  if(dataset == "PowerCons"){
    temp = rep(sax_rep_2[i], times = 8)
    sax_rep_all_2 = append(sax_rep_all_2,temp)
  }
  if(dataset == "Plane"){
    temp = rep(sax_rep_2[i], times = 8)
    sax_rep_all_2 = append(sax_rep_all_2,temp)
  }
  if(dataset == "GunPointMaleVersusFemale"){
    if(control != 18){
      temp = rep(sax_rep_2[i], times = 8)
      sax_rep_all_2 = append(sax_rep_all_2,temp)
      control = control + 1
    }
    else{
      temp = rep(sax_rep_2[i], times = 6)
      sax_rep_all_2 = append(sax_rep_all_2,temp)
      control = 0
    }
  }
  if(dataset == "GunPointAgeSpan"){
    if(control != 18){
      temp = rep(sax_rep_2[i], times = 8)
      sax_rep_all_2 = append(sax_rep_all_2,temp)
      control = control + 1
    }
    else{
      temp = rep(sax_rep_2[i], times = 6)
      sax_rep_all_2 = append(sax_rep_all_2,temp)
      control = 0
    }
  }
}

long_train[,sax_rep_char_2 := sax_rep_all_2]
long_train

long_train[,sax_rep_char_num_2 := as.numeric(as.factor(sax_rep_all_2))]  
long_train[,sax_rep_2:=mean(value),by = list(id,sax_rep_char_num_2)]

long_train = long_train[,-c("sax_rep_char","sax_rep_char_num","sax_rep_char_2","sax_rep_char_num_2")]

#Melt the data columns
testdata
raw_rep_long_train <- long_train[,-c("class","paa_rep","sax_rep","sax_rep_2","paa_rep_2")]
wide_raw_rep <- reshape(raw_rep_long_train, idvar = "id", v.names = "value", timevar = "time", direction = "wide")
wide_raw_rep_with_test <- rbind(wide_raw_rep,testdata, use.names=FALSE)

paa_rep_long_train <- long_train[,-c("class","value","sax_rep","sax_rep_2","paa_rep_2")]
wide_paa_rep <- reshape(paa_rep_long_train, idvar = "id", v.names = "paa_rep", timevar = "time", direction = "wide")
wide_paa_rep_with_test <- rbind(wide_paa_rep,testdata, use.names=FALSE)


paa_rep_2_long_train <- long_train[,-c("class","value","sax_rep","sax_rep_2","paa_rep")]
wide_paa_rep_2 <- reshape(paa_rep_2_long_train, idvar = "id", v.names = "paa_rep_2", timevar = "time", direction = "wide")
wide_paa_rep_2_with_test <- rbind(wide_paa_rep_2,testdata, use.names=FALSE)


sax_rep_long_train <- long_train[,-c("class","value","paa_rep","sax_rep_2","paa_rep_2")]
wide_sax_rep <- reshape(sax_rep_long_train, idvar = "id", v.names = "sax_rep", timevar = "time", direction = "wide")
wide_sax_rep_with_test <- rbind(wide_sax_rep,testdata, use.names=FALSE)

sax_rep_2_long_train <- long_train[,-c("class","value","sax_rep","paa_rep","paa_rep_2")]
wide_sax_rep_2 <- reshape(sax_rep_2_long_train, idvar = "id", v.names = "sax_rep_2", timevar = "time", direction = "wide")
wide_sax_rep_2_with_test <- rbind(wide_sax_rep_2,testdata, use.names=FALSE)

# Drop first column from data

traindata <- traindata[,2:(ncol(traindata)-1)]
testdata <- testdata[,2:(ncol(testdata))]
wide_raw_rep_with_test <- wide_raw_rep_with_test[,2:ncol(wide_raw_rep_with_test)]
wide_paa_rep_with_test <- wide_paa_rep_with_test[,2:ncol(wide_paa_rep_with_test)]
wide_paa_rep_2_with_test <- wide_paa_rep_2_with_test[,2:ncol(wide_paa_rep_2_with_test)]
wide_sax_rep_with_test <- wide_sax_rep_with_test[,2:ncol(wide_sax_rep_with_test)]
wide_sax_rep_2_with_test <- wide_sax_rep_2_with_test[,2:ncol(wide_sax_rep_2_with_test)]

#Euclidean Distance
large_number = 100000000
raw_dist_euc <- as.matrix(dist(wide_raw_rep_with_test))
paa_dist_euc <- as.matrix(dist(wide_paa_rep_with_test))
paa2_dist_euc <- as.matrix(dist(wide_paa_rep_2_with_test))
sax_dist_euc <- as.matrix(dist(wide_sax_rep_with_test))
sax2_dist_euc <- as.matrix(dist(wide_sax_rep_2_with_test))

diag(raw_dist_euc) = large_number
diag(paa_dist_euc) = large_number
diag(paa2_dist_euc) = large_number
diag(sax_dist_euc) = large_number
diag(sax2_dist_euc) = large_number

fwrite(raw_dist_euc,sprintf('%s/%s_raw_dist_euc.csv',dist_path,dataset),col.names=F)
fwrite(paa_dist_euc,sprintf('%s/%s_paa_dist_euc.csv',dist_path,dataset),col.names=F)
fwrite(paa2_dist_euc,sprintf('%s/%s_paa2_dist_euc.csv',dist_path,dataset),col.names=F)
fwrite(sax_dist_euc,sprintf('%s/%s_sax_dist_euc.csv',dist_path,dataset),col.names=F)
fwrite(sax2_dist_euc,sprintf('%s/%s_sax2_dist_euc.csv',dist_path,dataset),col.names=F)


#DTW Distance
raw_dist_dtw=as.matrix(dtwDist(wide_raw_rep_with_test))
paa_dist_dtw=as.matrix(dtwDist(wide_paa_rep_with_test))
paa2_dist_dtw=as.matrix(dtwDist(wide_paa_rep_2_with_test))
sax_dist_dtw=as.matrix(dtwDist(wide_sax_rep_with_test))
sax2_dist_dtw=as.matrix(dtwDist(wide_sax_rep_2_with_test))

diag(raw_dist_dtw)=large_number
diag(paa_dist_dtw) = large_number
diag(paa2_dist_dtw) = large_number
diag(sax_dist_dtw) = large_number
diag(sax2_dist_dtw) = large_number

fwrite(raw_dist_dtw,sprintf('%s/%s_raw_dist_dtw.csv',dist_path,dataset),col.names=F)
fwrite(paa_dist_dtw,sprintf('%s/%s_paa_dist_dtw.csv',dist_path,dataset),col.names=F)
fwrite(paa2_dist_dtw,sprintf('%s/%s_paa2_dist_dtw.csv',dist_path,dataset),col.names=F)
fwrite(sax_dist_dtw,sprintf('%s/%s_sax_dist_dtw.csv',dist_path,dataset),col.names=F)
fwrite(sax2_dist_dtw,sprintf('%s/%s_sax2_dist_dtw.csv',dist_path,dataset),col.names=F)

#LCSS Distance

raw_dist_lcss=TSDatabaseDistances(wide_raw_rep_with_test,distance='lcss',epsilon=0.05)
raw_dist_lcss=as.matrix(raw_dist_lcss)
diag(raw_dist_lcss)=large_number

paa_dist_lcss=TSDatabaseDistances(wide_paa_rep_with_test,distance='lcss',epsilon=0.05)
paa_dist_lcss=as.matrix(paa_dist_lcss)
diag(paa_dist_lcss)=large_number

paa2_dist_lcss=TSDatabaseDistances(wide_paa_rep_2_with_test,distance='lcss',epsilon=0.05)
paa2_dist_lcss=as.matrix(paa2_dist_lcss)
diag(paa2_dist_lcss)=large_number

sax_dist_lcss=TSDatabaseDistances(wide_sax_rep_with_test,distance='lcss',epsilon=0.05)
sax_dist_lcss=as.matrix(sax_dist_lcss)
diag(sax_dist_lcss)=large_number

sax2_dist_lcss=TSDatabaseDistances(wide_sax_rep_2_with_test,distance='lcss',epsilon=0.05)
sax2_dist_lcss=as.matrix(sax2_dist_lcss)
diag(sax2_dist_lcss)=large_number

fwrite(raw_dist_lcss,sprintf('%s/%s_raw_dist_lcss.csv',dist_path,dataset),col.names=F)
fwrite(paa_dist_lcss,sprintf('%s/%s_paa_dist_lcss.csv',dist_path,dataset),col.names=F)
fwrite(paa2_dist_lcss,sprintf('%s/%s_paa2_dist_lcss.csv',dist_path,dataset),col.names=F)
fwrite(sax_dist_lcss,sprintf('%s/%s_sax_dist_lcss.csv',dist_path,dataset),col.names=F)
fwrite(sax2_dist_lcss,sprintf('%s/%s_sax2_dist_lcss.csv',dist_path,dataset),col.names=F)

#ERP Distance

raw_dist_erp=TSDatabaseDistances(wide_raw_rep_with_test,distance='erp',g=0.5)
raw_dist_erp=as.matrix(raw_dist_erp)
diag(raw_dist_erp)=large_number

paa_dist_erp=TSDatabaseDistances(wide_paa_rep_with_test,distance='erp',g=0.5)
paa_dist_erp=as.matrix(paa_dist_erp)
diag(paa_dist_erp)=large_number

paa2_dist_erp=TSDatabaseDistances(wide_paa_rep_2_with_test,distance='erp',g=0.5)
paa2_dist_erp=as.matrix(paa2_dist_erp)
diag(paa2_dist_erp)=large_number

sax_dist_erp=TSDatabaseDistances(wide_sax_rep_with_test,distance='erp',g=0.5)
sax_dist_erp=as.matrix(sax_dist_erp)
diag(sax_dist_erp)=large_number

sax2_dist_erp=TSDatabaseDistances(wide_sax_rep_2_with_test,distance='erp',g=0.5)
sax2_dist_erp=as.matrix(sax2_dist_erp)
diag(sax2_dist_erp)=large_number

fwrite(raw_dist_erp,sprintf('%s/%s_raw_dist_erp.csv',dist_path,dataset),col.names=F)
fwrite(paa_dist_erp,sprintf('%s/%s_paa_dist_erp.csv',dist_path,dataset),col.names=F)
fwrite(paa2_dist_erp,sprintf('%s/%s_paa2_dist_erp.csv',dist_path,dataset),col.names=F)
fwrite(sax_dist_erp,sprintf('%s/%s_sax_dist_erp.csv',dist_path,dataset),col.names=F)
fwrite(sax2_dist_erp,sprintf('%s/%s_sax2_dist_erp.csv',dist_path,dataset),col.names=F)

#NN Classification

nn_classify_cv=function(dist_matrix,train_class,test_indices,k=1){
  
  test_distances_to_train=dist_matrix[test_indices,]
  test_distances_to_train=test_distances_to_train[,-test_indices]
  train_class=train_class[-test_indices]
  #print(str(test_distances_to_train))
  ordered_indices=apply(test_distances_to_train,1,order)
  if(k==1){
    nearest_class=as.numeric(allclass[as.numeric(ordered_indices[1,])])
    nearest_class=data.table(id=test_indices,nearest_class)
  } else {
    nearest_class=apply(ordered_indices[1:k,],2,function(x) {allclass[x]})
    nearest_class=data.table(id=test_indices,t(nearest_class))
  }
  
  long_nn_class=melt(nearest_class,'id')
  
  class_counts=long_nn_class[,.N,list(id,value)]
  class_counts[,predicted_prob:=N/k]
  wide_class_prob_predictions=dcast(class_counts,id~value,value.var='predicted_prob')
  wide_class_prob_predictions[is.na(wide_class_prob_predictions)]=0
  class_predictions=class_counts[,list(predicted=value[which.max(N)]),by=list(id)]
  
  
  return(list(prediction=class_predictions,prob_estimates=wide_class_prob_predictions))
  
}

# Cross Validation

set.seed(100)
nof_rep=5
n_fold=10
cv_indices=generateCVRuns(ecgtrainclass, ntimes =nof_rep, nfold = n_fold, 
                          leaveOneOut = FALSE, stratified = TRUE)

str(cv_indices)

dist_folder=sprintf('%s/ClassificationData/%s/distances/%s',current_folder,dataset,dataset)
dist_files=list.files(dist_folder, full.names=T)
list.files(dist_folder)

k_levels=c(1,3,5)
approach_file=list.files(dist_folder)

result=vector('list',length(dist_files)*nof_rep*n_fold*length(k_levels))
iter=1

for(m in 1:length(dist_files)){ #
  print(dist_files[m])
  dist_mat=as.matrix(fread(dist_files[m],header=FALSE))
  for(i in 1:nof_rep){
    this_fold=cv_indices[[i]]
    for(j in 1:n_fold){
      test_indices=this_fold[[j]]
      for(k in 1:length(k_levels)){
        current_k=k_levels[k]
        current_fold=nn_classify_cv(dist_mat,allclass,test_indices,k=current_k)
        accuracy=sum(allclass[test_indices]==current_fold$prediction$predicted)/length(test_indices)
        tmp=data.table(approach=approach_file[m],repid=i,foldid=j,
                       k=current_k,acc=accuracy)
        result[[iter]]=tmp
        iter=iter+1
        
      }
      
    }
    
  }   
  
}

overall_results=rbindlist(result)
summarized_results=overall_results[,list(avg_acc=mean(acc),sdev_acc=sd(acc),result_count=.N),by=list(approach,k)]

summarized_results[order(-avg_acc)]
fwrite(summarized_results[order(-avg_acc)],sprintf('%s/%sresult.csv',main_path,dataset),col.names=T)
