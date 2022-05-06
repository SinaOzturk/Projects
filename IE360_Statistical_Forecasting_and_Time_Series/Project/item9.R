library(tidyverse)
library(lubridate)
library(zoo)
library(ggplot2)
library(data.table)
library(dplyr)
library(forecast)
library(miscTools)

# Manipulation

alldata_item9 <- read.csv("alldata_item9.csv")

alldata_item9 <- as.data.table(alldata_item9)
alldata_item9 <- alldata_item9[rev(order(event_date))]
alldata_item9[, w_day:=as.character(lubridate::wday(event_date,label=T))]
alldata_item9[, Month:=as.character(lubridate::month(event_date,label=T))]
alldata_item9[, weeknumber:=as.character(lubridate::week(event_date))]

# Visuailization of Attributes

ggplot(alldata_item9, aes(x = event_date)) + 
  geom_line(aes(y = sold_count))
ggplot(alldata_item9, aes(x = event_date)) + 
  geom_line(aes(y = price))
ggplot(alldata_item9, aes(x = event_date)) + 
  geom_line(aes(y = ty_visits))

# LM Model
item9_lm1 <- lm(sold_count~., alldata_item9)
summary(item9_lm1)
AIC(item9_lm1)

fit_lm_item9 <- ts(item9_lm1$fitted.values,freq = 7)
plot(fit_lm_item9)

item9_sold_count_ts <- ts(alldata_item9$sold_count,freq = 7)
plot(item9_sold_count_ts)
points(fit_lm_item9, type= "l", col = 2)

item9_lm2 <- lm(sold_count~ favored_count + basket_count + category_sold + category_favored + sold_count_lag1, alldata_item9)
summary(item9_lm2)
residuals_item9_lm2 <- item9_lm2$residuals
acf(residuals_item9_lm2)
AIC(item9_lm2)

#predict with LM model
# we only get the future values for regressors in LM models with using moving average for this product at the beginning of project

pred_item9 <- predict(item9_lm2,alldata_item9[is.na(sold_count)==T]) # for predicting row we have NA sold_count
pred_item9

#Decomposisiton

pr9 = read.csv("alldata_item9.csv")
pr9 <- as.data.table(pr9)
pr9 <- pr9[,-c("X","w_day")]
pr9 <- mutate(pr9, event_date = ymd(event_date)) # converting event date into datetime object
pr9[, Month:=as.numeric(lubridate::month(event_date,label=F))] #adding month information as a numeric variable 
pr9[, Day:=as.numeric(lubridate::wday(event_date,label=F))] #adding day information as a numeric variable 
head(pr9)

sold <- data.table(event_date =pr9$event_date,
                   sold_count = pr9$sold_count)
head(sold)

boxplot(sold$sold_count)
acf(sold$sold_count)
pacf(sold$sold_count)

# Weekly Seasonality

soldts <- ts(rev(pr9$sold_count),  freq = 7, start= c(1,1))
resultweekdec <- decompose(soldts,type= "additive")
plot(resultweekdec)

# Monthly  Seasonality

soldtsmonth <- ts(rev(pr9$sold_count),  freq = 30, start= c(1,1))
resultmonthdec <- decompose(soldtsmonth,type= "additive")
plot(resultmonthdec)

plot(resultmonthdec$random)
plot(resultweekdec$random)

# decide go with weekly decomposed item
random = resultweekdec$random
trend = resultweekdec$trend
season = resultweekdec$seasonal

# parameter decision for ARIMA model
acf(random, na.action = na.pass)
pacf(random, na.action = na.pass)

# search for best parameters
model <- arima(random, order= c(1,0,0))
AIC(model)

model <- arima(random, order= c(2,0,0))
AIC(model)

model <- arima(random, order= c(3,0,0))
AIC(model)

model <- arima(random, order= c(3,0,1))
AIC(model)

model <- arima(random, order= c(3,0,2))
AIC(model)

model <- arima(random, order= c(4,0,1))
AIC(model)

model <- arima(random, order= c(2,0,2))
AIC(model)

model <- arima(random, order= c(1,0,3))
AIC(model)

model <- arima(random, order= c(1,0,2))
AIC(model)

model <- arima(random, order= c(0,0,1))
AIC(model)

model <- arima(random, order= c(0,0,2))
AIC(model)

model <- arima(random, order= c(4,0,2))
AIC(model)

model <- arima(random, order= c(2,0,1))
AIC(model)

#best model
model <- arima(random, order= c(2,0,1))
summary(model)

#fitted model
modelfit <- random - model$residuals
fitted <- modelfit*trend*season
plot(soldts)
points(fitted, type= "l", col = 2)

#searching for external regressors

ggpairs(pr9, columns = c(4,7,8,10,13 ))

#to compare models, need to divide data
traindata <- sold[-c(1:7),]
head(traindata)
testdata <- sold[c(1:7),]
head(testdata)

# one external regressor
regressors <- pr9$basket_count[-c(1:7)]
head(regressors)

#decompose the train data and built the model again
traindatats <- ts(rev(traindata$sold_count),frequency = 7, start = c(1,1))
resultdec <- decompose(traindatats,type= "additive")
trend = resultdec$trend
season = resultdec$seasonal
random = resultdec$random 
plot(resultdec)

model <- arima(random, order= c(2,0,1))
summary(model)

#with external regressors
model <- arima(random, order= c(2,0,1), xreg = regressors)
summary(model)

#getting forecast for test data

model.forecast <- predict(model, n.ahead = 10, newxreg = pr9$basket_count[c(1:10)])$pred

last.trend.value <-tail(resultdec$trend[!is.na(resultdec$trend)],10)
seasonality <- resultdec$seasonal[367:376]

forecast_normalized <- model.forecast+last.trend.value+seasonality
forecast_normalized= ts(forecast_normalized, frequency = 7, start=c(55,3))

#plot actual vs predicted in test data
testdata <- ts(rev(testdata$sold_count), frequency = 7, start=c(55,3))

plot(testdata)
points(forecast_normalized,type= "l", col = 2)



# predicting used regressors (Basket Count, Category Favored and Category Sold) with LM or ARIMA

#Basket Count

alldata_item9$basket_count[1] <- NA
item9_basket_count_lm <- lm(basket_count~ weeknumber + w_day + Month + event_date, alldata_item9)
summary(item9_basket_count_lm)
pred_item9_basket_count_June20 <- predict(item9_basket_count_lm,alldata_item9[is.na(sold_count)==T])
pred_item9_basket_count_June20
alldata_item9$basket_count[1] <- pred_item9_basket_count_June20

#predicting sold_count using ARIMAX model for 2 day ahead:

random = resultweekdec$random
trend = resultweekdec$trend
season = resultweekdec$seasonal
model <- arima(random, order= c(2,0,1), xreg = regressors)


model.forecast <- predict(model, n.ahead = 5, newxreg = pr9$basket_count[c(1:5)])$pred

last.trend.value <-tail(resultweekdec$trend[!is.na(resultweekdec$trend)],5)
seasonality <- resultweekdec$seasonal[370:374] # going to change each day

forecast_normalized <- model.forecast*last.trend.value*seasonality

#forecasted value
alldata_item9$sold_count[1] <- forecast_normalized[5]
