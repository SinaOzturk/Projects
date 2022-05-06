library(data.table)
library(sjmisc)
library(caret)
library(caTools)
library(ggpubr)
library(ROCR)

datatest <- read.csv("kobe-test.csv")
datatest <- data.table(datatest)
datatrain <- read.csv("kobe-train.csv")
datatrain <- data.table(datatrain)
submition <- read.csv("kobe-sample-submission.csv")

# first need to check variables in the data to understand the problem

datatrain <- datatrain[,-c("X")] # no need to have another index

cor.test(datatrain$lon, datatrain$loc_x, method=c("pearson", "kendall", "spearman")) # we have positive correlation between these two
cor.test(datatrain$lat, datatrain$loc_y, method=c("pearson", "kendall", "spearman")) # we have negative correlation between these two
datatrain <- datatrain[,-c("lat","lon")] # no need to hold lat and lon attribute anymore in data set
datatrain <- datatrain[,-c("team_id", "team_name")] # these two are always the same for all data set
datatrain <- datatrain[,-c("game_date")] # we cannot use game date for regressor because any game happens at the same date

# to understand the game playerd at home or away, we can create home_play attribute using matchup attribute

contains_vs <- c()
for (i in 1:nrow(datatrain)) {
  contains_vs[i] <- str_contains(datatrain$matchup[i], "vs")
}

datatrain <- datatrain[, home_play:=contains_vs] # if home_play is TRUE then match played at home, vice versa
datatrain <- datatrain[, -c("matchup")] # now we don't need for matchup because we already have component attribute

# to have more clear way to understand remaing time to the end of period, we need combine seconds_remaining and minutes_remaining

datatrain <- datatrain[, time_remaining:=minutes_remaining*60 + datatrain$seconds_remaining] # multiple minute with 60 and add remaining seconds to have remaining time
datatrain <- datatrain[,-c("minutes_remaining", "seconds_remaining")] # now no need for these attributes because we created time_remaining

# there is no understanding of looking at the data by our eyes therefore we cannot subtract more attribute

#apply the same manipulation to the datatest 

datatest <- datatest[,-c("X", "X.1")] # we have one more useless index attribute in this one
datatest <- datatest[,-c("lat","lon")] 
datatest <- datatest[,-c("team_id", "team_name")]
datatest <- datatest[,-c("game_date")] 

contains_vs_test <- c()
for (i in 1:nrow(datatest)) {
  contains_vs_test[i] <- str_contains(datatest$matchup[i], "vs")
}
datatest <- datatest[, home_play:=contains_vs_test]
datatest <- datatest[, -c("matchup")]
datatest <- datatest[, time_remaining:=minutes_remaining*60 + datatest$seconds_remaining]
datatest <- datatest[,-c("minutes_remaining", "seconds_remaining")]


# after manipulate the data enough for now, we need to divide train data set into one more train and test set to compare our models by ourself

# because the test data is 0.1 of actual total data we can also divide train data using 0.1
set.seed(0) # to get the same split for each time
split = sample.split(datatrain$shot_made_flag, SplitRatio = 0.9)
kobetrain = subset(datatrain, split == TRUE)
kobetest = subset(datatrain, split == FALSE)

# now we can built our models using kobetrain and test it with using accuracy in kobetest
set.seed(425)
lr1 <- glm(shot_made_flag~.,data = kobetrain, family = binomial )
summary(lr1)

# when we see the summary, distance attribute has no effect in the model. We think that shot_zone_range has the correlation with distance
#Therefore, we subtract shot_zone_range first.
set.seed(425)
lr2 <- glm(shot_made_flag~. - shot_zone_range,data = kobetrain, family = binomial )
summary(lr2)

#shot_zone_are has correlation with loc_x and loc_y values because shot zone area simply divide the play ground into pieces.
set.seed(425)
lr3 <- glm(shot_made_flag~. - shot_zone_range - shot_zone_area,data = kobetrain, family = binomial )
summary(lr3)

# game_event_id and game_id has no effect on models. Also we think that there is small chance to affect the model but we give them chance
set.seed(425)
lr4 <- glm(shot_made_flag~. - shot_zone_range - shot_zone_area - game_id - game_event_id,data = kobetrain, family = binomial )
summary(lr4)

# opponent is a huge categorical attribute and almost any of them has significance in the model
set.seed(425)
lr5 <- glm(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent,data = kobetrain, family = binomial )
summary(lr5)

# first we think that playoff attribute can affect the model because NBA players play better in playoffs. However it does not afffect the model too much.
set.seed(425)
lr6 <- glm(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs,data = kobetrain, family = binomial )
summary(lr6)

# after we realize that shot_type also has correlation with distance (3PT or 2PT)
set.seed(425)
lr7 <- glm(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs - shot_type,data = kobetrain, family = binomial )
summary(lr7)

# we also realize action_type is a huge subset of combined_shot_type 
set.seed(425)
lr8 <- glm(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs - shot_type - combined_shot_type,data = kobetrain, family = binomial )
summary(lr8)

# also we think that Kobe's seasons can affect the models but only last two years has significance in the model, but we are not sure to subtract it from model
set.seed(425)
lr9 <- glm(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs - shot_type - combined_shot_type - season,data = kobetrain, family = binomial )
summary(lr9)

# now almost all the attributes are significant in the model.
# we have still suspect whether subtract season or not and home_play and shot_distance
# to determine these we can predict on kobetest and see the accuracy values

# suspicious models here listed:

#with all of them: lr8
#without season: lr9
#without home_play
set.seed(425)
lr10 <- glm(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs - shot_type - combined_shot_type - home_play ,data = kobetrain, family = binomial )
summary(lr10)

#without shot_distance
set.seed(425)
lr11 <- glm(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs - shot_type - combined_shot_type - shot_distance ,data = kobetrain, family = binomial )
summary(lr11)

#without shot_distance and home_play
set.seed(425)
lr12 <- glm(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs - shot_type - combined_shot_type - shot_distance - home_play ,data = kobetrain, family = binomial )
summary(lr12)

#without shot_distance and season
set.seed(425)
lr13 <- glm(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs - shot_type - combined_shot_type - shot_distance - season ,data = kobetrain, family = binomial )
summary(lr13)

#without home_play and season
set.seed(425)
lr14 <- glm(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs - shot_type - combined_shot_type - home_play - season ,data = kobetrain, family = binomial )
summary(lr14)

#without all three suspicious attributes
set.seed(425)
lr15 <- glm(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs - shot_type - combined_shot_type - home_play - season - shot_distance,data = kobetrain, family = binomial )
summary(lr15)

#now decide which model we are going to use with using accuracy

pred.lr8 = predict(lr8,newdata=kobetest, type="response") # Accuracy 0.6788
cmlr8 <- confusionMatrix(table(pred.lr8 >= 0.5,kobetest$shot_made_flag == 1))
cmlr8$overall

pred.lr9 = predict(lr9,newdata=kobetest, type="response") # Accuracy 0.6762
cmlr9 <- confusionMatrix(table(pred.lr9 >= 0.5,kobetest$shot_made_flag == 1))
cmlr9$overall


pred.lr10 = predict(lr10,newdata=kobetest, type="response") # Accuracy 0.6788
cmlr10 <- confusionMatrix(table(pred.lr10 >= 0.5,kobetest$shot_made_flag == 1))
cmlr10$overall

pred.lr11 = predict(lr11,newdata=kobetest, type="response") # Accuracy 0.6788
cmlr11 <- confusionMatrix(table(pred.lr11 >= 0.5,kobetest$shot_made_flag == 1))
cmlr11$overall

pred.lr12 = predict(lr12,newdata=kobetest, type="response") # Accuracy 0.6783
cmlr12 <- confusionMatrix(table(pred.lr12 >= 0.5,kobetest$shot_made_flag == 1))
cmlr12$overall

pred.lr13 = predict(lr13,newdata=kobetest, type="response") # Accuracy 0.6762
cmlr13 <- confusionMatrix(table(pred.lr13 >= 0.5,kobetest$shot_made_flag == 1))
cmlr13$overall

pred.lr14 = predict(lr14,newdata=kobetest, type="response") # Accuracy 0.6757
cmlr14 <- confusionMatrix(table(pred.lr14 >= 0.5,kobetest$shot_made_flag == 1))
cmlr14$overall

pred.lr15 = predict(lr15,newdata=kobetest, type="response") # Accuracy 0.6762
cmlr15 <- confusionMatrix(table(pred.lr15 >= 0.5,kobetest$shot_made_flag == 1))
cmlr15$overall

# From accuracies, most sensible model looks like adding all the suspicious attributes into the model which is lr8


ctrlforparameters = trainControl(method = 'repeatedcv', number = 10, repeats = 1)

gbmGrid1 = expand.grid(n.trees = 50,
                       interaction.depth = 3 + (0:5)*1,
                       n.minobsinnode = 5,
                       shrinkage =0.1)

gbmfit1 = train(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs - shot_type - combined_shot_type , data = kobetrain, method = "gbm", metric = "RMSE", verbose = TRUE, trControl = ctrlforparameters, tuneGrid = gbmGrid1)
#check from 30 till 110 with 5 interval
# best n.trees = 90

gbmGrid2 = expand.grid(n.trees = 50,
                       interaction.depth = 8,
                       n.minobsinnode = 5 + (0:2)*5,
                       shrinkage =0.1)

gbmfit2 = train(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs - shot_type - combined_shot_type , data = kobetrain, method = "gbm", metric = "RMSE", verbose = TRUE, trControl = ctrlforparameters, tuneGrid = gbmGrid2)

# check interaction.depth from 3 to 13 one by one
# best interaction.depth = 8

gbmGrid3 = expand.grid(n.trees = 50,
                       interaction.depth = 8,
                       n.minobsinnode = 5,
                       shrinkage =0.1 + (0:2)*0.1)

gbmfit3 = train(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs - shot_type - combined_shot_type , data = kobetrain, method = "gbm", metric = "RMSE", verbose = TRUE, trControl = ctrlforparameters, tuneGrid = gbmGrid3)

# check n.minobsinnode 5-10-15
# best n.minobsinnode = 5

gbmGrid4 = expand.grid(n.trees = 50 + (0:5)*20,
                       interaction.depth = 8,
                       n.minobsinnode = 5,
                       shrinkage =0.1)

gbmfit4 = train(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs - shot_type - combined_shot_type , data = kobetrain, method = "gbm", metric = "RMSE", verbose = TRUE, trControl = ctrlforparameters, tuneGrid = gbmGrid4)

# check shrinkage first 0.1- 0.2- 0.3 then from 0.01 to 0.1 by increasing 0.01 and finally 0.1 to 0.15 by increasing 0.01
# best shrinkage = 0.1

# now we finally decide our parameters, now one more final model with increasing repeats to 10 in repeated cross-validation

ctrlforfinalmodel= trainControl(method = 'repeatedcv', number = 10, repeats = 5)

gbmGridFinal = expand.grid(n.trees = 90,
                           interaction.depth = 8,
                           n.minobsinnode = 5,
                           shrinkage =0.1)

gbmfit5 = train(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs - shot_type - combined_shot_type , data = kobetrain, method = "gbm", metric = "RMSE", verbose = F, trControl = ctrlforfinalmodel, tuneGrid = gbmGridFinal)
gbmfit5

# in this model we used our own divided kobetrain data to compute AUC values before submition to the Kaggle
gbmfit5pred = predict(gbmfit5, newdata = kobetest)
gbmfit5ROCpred=prediction(gbmfit5pred,kobetest$shot_made_flag)
gbmfit5perf=performance(gbmfit5ROCpred,"tpr","fpr")
plot(gbmfit5perf)
as.numeric(performance(gbmfit5ROCpred,"auc")@y.values)


#finally we can built the model with using all the data with the same parameters that we decide before

gbmfitKaggle = train(shot_made_flag~. - shot_zone_range - shot_zone_area- game_id - game_event_id - opponent - playoffs - shot_type - combined_shot_type , data = datatrain, method = "gbm", metric = "RMSE", verbose = F, trControl = ctrlforfinalmodel, tuneGrid = gbmGridFinal)
gbmfitKagglepred = predict(gbmfitKaggle, newdata = datatest)

submition$shot_made_flag <- gbmfitKagglepred


