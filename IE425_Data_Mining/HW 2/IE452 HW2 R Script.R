library(caret)
library(caTools)
library(randomForest)

ToyotaCorolla = read.csv("ToyotaCorolla.csv")

ToyotaCorolla$FuelType = as.factor(ToyotaCorolla$FuelType)
ToyotaCorolla$MetColor = as.factor(ToyotaCorolla$MetColor)
ToyotaCorolla$Automatic = as.factor(ToyotaCorolla$Automatic)

set.seed(425)
rndSample = sample(1:nrow(ToyotaCorolla), nrow(ToyotaCorolla)*0.7)
Corollatr = ToyotaCorolla[rndSample,]
Corollate = ToyotaCorolla[-rndSample,]


set.seed(425)
ctrl1 = trainControl(method = 'repeatedcv', number = 10, repeats = 5)

set.seed(425)
fit1 = train(Price~., data = Corollatr, method = "rf", metric = "RMSE", trControl = ctrl1,ntree = 100, tuneGrid = expand.grid(.mtry = (1:10)))
fit1

set.seed(425)
fit2 = train(Price~., data = Corollatr, method = "rf", metric = "RMSE", trControl = ctrl1,ntree = 200, tuneGrid = expand.grid(.mtry = (1:10)))
fit2

set.seed(425)
fit3 = train(Price~., data = Corollatr, method = "rf", metric = "RMSE", trControl = ctrl1,ntree = 300, tuneGrid = expand.grid(.mtry = (1:10)))
fit3

set.seed(425)
fit4 = train(Price~., data = Corollatr, method = "rf", metric = "RMSE", trControl = ctrl1,ntree = 400, tuneGrid = expand.grid(.mtry = (1:10)))
fit4

set.seed(425)
fit5 = train(Price~., data = Corollatr, method = "rf", metric = "RMSE", trControl = ctrl1,ntree = 500, tuneGrid = expand.grid(.mtry = (1:10)))
fit5

plot(fit5, metric = "RMSE")
varImp(fit5)
fit5$mtry

fit5pred = predict(fit5, newdata = Corollate )
RMSE(fit5pred, Corollate$Price)


set.seed(425)
lmfit = train(Price~., data = Corollatr, method = "lm",  metric = "RMSE", trControl = ctrl1)
summary(lmfit)
lmfit$results$RMSE

lmfitpred = predict(lmfit, newdata = Corollate)
RMSE(lmfitpred, Corollate$Price)


gbmGrid = expand.grid(n.trees = 50 + (1:4)*25,
                      interaction.depth = 2 + (1:3)*1,
                      n.minobsinnode = (1:3)*5,
                      shrinkage = (1:3)*0.1)
nrow(gbmGrid)

set.seed(425)
gbmfit = train(Price~., data = Corollatr, method = "gbm", metric = "RMSE", verbose = FALSE, trControl = ctrl1, tuneGrid = gbmGrid)
gbmfit$bestTune
which.min(gbmfit$results$RMSE)
gbmfit$results$RMSE[which.min(gbmfit$results$RMSE)]

gbmfitpred = predict(gbmfit, newdata = Corollate)
RMSE(gbmfitpred,Corollate$Price)