library(tidyverse)
library(lubridate)
library(zoo)
library(ggplot2)
library(data.table)
library(dplyr)
library(forecast)
library(miscTools)

# Manipulation

alldata_item7 <- read.csv("alldata_item7.csv")

alldata_item7 <- as.data.table(alldata_item7)
alldata_item7 <- alldata_item7[rev(order(event_date))]
alldata_item7[, w_day:=as.character(lubridate::wday(event_date,label=T))]
alldata_item7[, Month:=as.character(lubridate::month(event_date,label=T))]
alldata_item7[, weeknumber:=as.character(lubridate::week(event_date))]

# Visuailization of Attributes

ggplot(alldata_item7, aes(x = event_date)) + 
  geom_line(aes(y = sold_count))
ggplot(alldata_item7, aes(x = event_date)) + 
  geom_line(aes(y = price))
ggplot(alldata_item7, aes(x = event_date)) + 
  geom_line(aes(y = ty_visits))

# LM Model
item7_lm1 <- lm(sold_count~. - product_content_id , alldata_item7)
summary(item7_lm1)
AIC(item7_lm1)

fit_lm_item7 <- ts(item7_lm1$fitted.values,freq = 7)
plot(fit_lm_item7)

item7_sold_count_ts <- ts(alldata_item7$sold_count,freq = 7)
plot(item7_sold_count_ts)
points(fit_lm_item7, type= "l", col = 2)

item7_lm2 <- lm(sold_count~ price + visit_count + basket_count + category_sold + category_brand_sold + category_visits + category_favored , alldata_item7)
summary(item7_lm2)

cutted_item7 <- subset(alldata_item7, event_date >= '2021-01-29')
item7_lm3 <- lm(sold_count~ price + visit_count + basket_count + category_sold + category_brand_sold + category_visits + category_favored , cutted_item7)
summary(item7_lm3)

item7_lm4 <- lm(sold_count~ visit_count + basket_count + category_sold + category_visits + category_basket , alldata_item7, )
summary(item7_lm4)
AIC(item7_lm4)

# we only get the future values for regressors in LM models with using moving average for this product at the beginning of project
#predict with LM model

pred_item7 <- predict(item7_lm4,alldata_item7[is.na(sold_count)==T]) # for predicting row we have NA sold_count
pred_item7

#Decomposisiton

pr7 = alldata_item7
pr7 <- as.data.table(pr7)
pr7 <- pr7[,-c("X","w_day")]
pr7 <- mutate(pr7, event_date = ymd(event_date)) # converting event date into datetime object
pr7[, Month:=as.numeric(lubridate::month(event_date,label=F))] #adding month information as a numeric variable 
pr7[, Day:=as.numeric(lubridate::wday(event_date,label=F))] #adding day information as a numeric variable 
head(pr7)

sold <- data.table(event_date =pr7$event_date,
                   sold_count = pr7$sold_count)
head(sold)

boxplot(sold$sold_count)
acf(sold$sold_count)
pacf(sold$sold_count)

# Weekly Seasonality

soldts <- ts(rev(pr7$sold_count),  freq = 7, start= c(1,1))
resultweekdec <- decompose(soldts,type= "multiplicative")
plot(resultweekdec)

# Monthly  Seasonality

soldtsmonth <- ts(rev(pr7$sold_count),  freq = 30, start= c(1,1))
resultmonthdec <- decompose(soldtsmonth,type= "multiplicative")
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

model <- arima(random, order= c(4,0,0))
AIC(model)

model <- arima(random, order= c(5,0,0))
AIC(model)

model <- arima(random, order= c(6,0,0))
AIC(model)

model <- arima(random, order= c(1,0,1))
AIC(model)

model <- arima(random, order= c(2,0,1))
AIC(model)

model <- arima(random, order= c(3,0,1))
AIC(model)

model <- arima(random, order= c(4,0,1))
AIC(model)

model <- arima(random, order= c(2,0,2))
AIC(model)

model <- arima(random, order= c(1,0,3))
AIC(model)

model <- arima(random, order= c(2,0,4))
AIC(model)

#best model
model <- arima(random, order= c(2,0,4))
summary(model)

#fitted model
modelfit <- random - model$residuals
fitted <- modelfit*trend*season
plot(soldts)
points(fitted, type= "l", col = 2)

#searching for external regressors

ggpairs(pr7, columns = c(4,7,8,10,12 ))

#to compare models, need to divide data
traindata <- sold[-c(1:7),]
head(traindata)
testdata <- sold[c(1:7),]
head(testdata)

# two external regressor
regressors <- pr7[-c(1:7), c(7,13)]
head(regressors)

#decompose the train data and built the model again
traindatats <- ts(rev(traindata$sold_count),frequency = 7, start = c(1,1))
resultdec <- decompose(traindatats,type= "multiplicative")
trend = resultdec$trend
season = resultdec$seasonal
random = resultdec$random 
plot(resultdec)

model <- arima(random, order= c(2,0,4))
summary(model)

#with external regressors
model <- arima(random, order= c(2,0,4), xreg = regressors)
summary(model)

#deleting one regressor and search for better model
regressors <- regressors[,-c(2,2)]
model <- arima(random, order= c(3,0,1), xreg = regressors)
summary(model)

#getting forecast for test data

model <- arima(random, order= c(3,0,0), xreg = regressors)
summary(model)

model.forecast <- predict(model, n.ahead = 10, newxreg = pr7$basket_count[c(1:10)])$pred

last.trend.value <-tail(resultdec$trend[!is.na(resultdec$trend)],10)
seasonality <- resultdec$seasonal[370:379]

forecast_normalized <- model.forecast*last.trend.value*seasonality
forecast_normalized= ts(forecast_normalized, frequency = 7, start=c(55,3))

#plot actual vs predicted in test data
testdata <- ts(rev(testdata$sold_count), frequency = 7, start=c(55,3))

plot(testdata,ylim = c(0,100))
points(forecast_normalized,type= "l", col = 2)


# predicting used regressors (basket_count) with LM or ARIMA

alldata_item7$basket_count[1] <- NA
item7_basket_count_lm <- lm(basket_count~ weeknumber + w_day + Month + event_date, alldata_item7)
summary(item7_basket_count_lm)

pred_item7_basket_count_June20 <- predict(item7_basket_count_lm,alldata_item7[is.na(sold_count)==T])
pred_item7_basket_count_June20
alldata_item7$basket_count[1] <- pred_item7_basket_count_June20

rev_alldata_item7 <- alldata_item7[order(event_date)]
basket_count_pr7 <- rev_alldata_item7$basket_count
basket_count_pr7 <- basket_count_pr7[-c(398:398)]
pacf(basket_count_pr7)
item7_basket_count_ts <- ts(basket_count_pr7,  freq = 7, start= c(1,1))
plot(item7_basket_count_ts)
basket_count_pr7_dec <- decompose(item7_basket_count_ts,type= "additive")
plot(basket_count_pr7_dec)
random_basket_count_pr7 <- basket_count_pr7_dec$random
bc_pr7_ARIMA1 <- arima(random_basket_count_pr7, order = c(2,0,1))
bc_pr7_ARIMA1

model.forecast <- predict(bc_pr7_ARIMA1, n.ahead = 5)$pred
model.forecast = ts(model.forecast, freq = 7,start = c(57,3))

last.trend.value <-tail(basket_count_pr7_dec$trend[!is.na(basket_count_pr7_dec$trend)],5)
seasonality=basket_count_pr7_dec$seasonal[2:6]
model.forecast.last = model.forecast + last.trend.value + seasonality
alldata_item7$basket_count[1] <- model.forecast.last[5]    

#predicting sold_count using ARIMAX model for 2 day ahead:

random = resultweekdec$random
trend = resultweekdec$trend
season = resultweekdec$seasonal
model <- arima(random, order= c(3,0,0), xreg = regressors)

model.forecast <- predict(model, n.ahead = 5, newxreg = pr7$basket_count[c(1:5)])$pred

last.trend.value <-tail(resultweekdec$trend[!is.na(resultweekdec$trend)],5)
seasonality <- resultweekdec$seasonal[370:374] # going to change each day

forecast_normalized <- model.forecast*last.trend.value*seasonality

#forecasted value
alldata_item7$sold_count[1] <- forecast_normalized[5]

