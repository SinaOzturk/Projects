library(tidyverse)
library(lubridate)
library(zoo)
library(ggplot2)
library(data.table)
library(dplyr)
library(forecast)
library(miscTools)

# Manipulation

alldata_item8 <- read.csv("alldata_item8.csv")

alldata_item8 <- as.data.table(alldata_item8)
alldata_item8 <- alldata_item8[rev(order(event_date))]
alldata_item8[, w_day:=as.character(lubridate::wday(event_date,label=T))]
alldata_item8[, Month:=as.character(lubridate::month(event_date,label=T))]
alldata_item8[, weeknumber:=as.character(lubridate::week(event_date))]

# Visuailization of Attributes

ggplot(alldata_item8, aes(x = event_date)) + 
  geom_line(aes(y = sold_count))
ggplot(alldata_item8, aes(x = event_date)) + 
  geom_line(aes(y = price))
ggplot(alldata_item8, aes(x = event_date)) + 
  geom_line(aes(y = ty_visits))

# LM Model
item8_lm1 <- lm(sold_count~., alldata_item8)
summary(item8_lm1)
AIC(item8_lm1)

fit_lm_item8 <- ts(item7_lm1$fitted.values,freq = 7)
plot(fit_lm_item8)

item8_sold_count_ts <- ts(alldata_item8$sold_count,freq = 7)
plot(item8_sold_count_ts)
points(fit_lm_item8, type= "l", col = 2)

item8_lm2 <- lm(sold_count~ basket_count + category_sold + category_brand_sold + category_visits, alldata_item8)
summary(item8_lm2)
AIC(item8_lm2)

# we only get the future values for regressors in LM models with using moving average for this product at the beginning of project
#predict with LM model

pred_item8 <- predict(item8_lm2,alldata_item8[is.na(sold_count)==T]) # for predicting row we have NA sold_count
pred_item8

#Decomposisiton

pr8 = read.csv("alldata_item8.csv")
pr8 <- as.data.table(pr8)
pr8 <- pr8[,-c("X","w_day")]
pr8 <- mutate(pr8, event_date = ymd(event_date)) # converting event date into datetime object
pr8[, Month:=as.numeric(lubridate::month(event_date,label=F))] #adding month information as a numeric variable 
pr8[, Day:=as.numeric(lubridate::wday(event_date,label=F))] #adding day information as a numeric variable 
head(pr8)

sold <- data.table(event_date =pr8$event_date,
                   sold_count = pr8$sold_count)
head(sold)

boxplot(sold$sold_count)
acf(sold$sold_count)
pacf(sold$sold_count)

# Weekly Seasonality

soldts <- ts(rev(pr8$sold_count),  freq = 7, start= c(1,1))
resultweekdec <- decompose(soldts,type= "additive")
plot(resultweekdec)

# Monthly  Seasonality

soldtsmonth <- ts(rev(pr8$sold_count),  freq = 30, start= c(1,1))
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

model <- arima(random, order= c(4,0,0))
AIC(model)

model <- arima(random, order= c(1,0,1))
AIC(model)

model <- arima(random, order= c(2,0,1))
AIC(model)

model <- arima(random, order= c(3,0,1))
AIC(model)

model <- arima(random, order= c(4,0,1))
AIC(model)

model <- arima(random, order= c(3,0,2))
AIC(model)

model <- arima(random, order= c(2,0,2))
AIC(model)

model <- arima(random, order= c(1,0,2))
AIC(model)

#best model
model <- arima(random, order= c(3,0,2))
summary(model)

#fitted model
modelfit <- random - model$residuals
fitted <- modelfit*trend*season
plot(soldts)
points(fitted, type= "l", col = 2)

#searching for external regressors

ggpairs(pr8, columns = c(4,7,8,10,13 ))

#to compare models, need to divide data
traindata <- sold[-c(1:7),]
head(traindata)
testdata <- sold[c(1:7),]
head(testdata)

# three external regressor
regressors <- pr8[-c(1:7), c(7,8,13)]
head(regressors)

#decompose the train data and built the model again
traindatats <- ts(rev(traindata$sold_count),frequency = 7, start = c(1,1))
resultdec <- decompose(traindatats,type= "additive")
trend = resultdec$trend
season = resultdec$seasonal
random = resultdec$random 
plot(resultdec)

model <- arima(random, order= c(3,0,2))
summary(model)

#with external regressors
model <- arima(random, order= c(3,0,2), xreg = regressors)
summary(model)

#deleting one regressor and search for better model
newregmatrix <- pr8[c(1:10), c(7,8,13)]

#getting forecast for test data

model.forecast <- predict(model, n.ahead = 10, newxreg = newregmatrix)$pred

last.trend.value <-tail(resultdec$trend[!is.na(resultdec$trend)],1)
seasonality <- resultdec$seasonal[370:379]

forecast_normalized <- model.forecast+last.trend.value+seasonality
forecast_normalized= ts(forecast_normalized, frequency = 7, start=c(55,3))

#plot actual vs predicted in test data
testdata <- ts(rev(testdata$sold_count), frequency = 7, start=c(55,3))

plot(testdata)
points(forecast_normalized,type= "l", col = 2)



# predicting used regressors (Basket Count, Category Favored and Category Sold) with LM or ARIMA

#Basket Count
alldata_item8$basket_count[1] <- NA
item8_basket_count_lm <- lm(basket_count~ weeknumber + w_day + Month + event_date, alldata_item8)
summary(item8_basket_count_lm)

pred_item8_basket_count_June20 <- predict(item8_basket_count_lm,alldata_item8[is.na(sold_count)==T])
pred_item8_basket_count_June20
alldata_item8$basket_count[1] <- pred_item8_basket_count_June20

rev_alldata_item8 <- alldata_item8[order(event_date)]
basket_count_pr8 <- rev_alldata_item8$basket_count
basket_count_pr8 <- basket_count_pr8[-c(398:398)]
pacf(basket_count_pr8)
item8_basket_count_ts <- ts(basket_count_pr8,  freq = 7, start= c(1,1))
plot(item8_basket_count_ts)
basket_count_pr8_dec <- decompose(item8_basket_count_ts,type= "additive")
plot(basket_count_pr8_dec)
random_basket_count_pr8 <- basket_count_pr8_dec$random
bc_pr8_ARIMA1 <- arima(random_basket_count_pr8, order = c(2,0,1))
bc_pr8_ARIMA1

model.forecast <- predict(bc_pr8_ARIMA1, n.ahead = 5)$pred
model.forecast = ts(model.forecast, freq = 7,start = c(57,3))

last.trend.value <-tail(basket_count_pr8_dec$trend[!is.na(basket_count_pr8_dec$trend)],5)
seasonality=basket_count_pr8_dec$seasonal[2:6]
model.forecast.last = model.forecast + last.trend.value + seasonality
alldata_item8$basket_count[1] <- model.forecast.last[5]   

# Category Favored
alldata_item8$category_favored[1] <- mean(alldata_item8[2:4]$category_favored) # because it has a lot of lost value in data set

# Category Sold
 
# lm models better for this attribute
alldata_item8$category_sold[1] <- NA
item8_category_sold_lm <- lm(category_sold~ weeknumber + w_day + Month + event_date, alldata_item8)
summary(item8_category_sold_lm)
pred_item8_category_sold_June20 <- predict(item8_category_sold_lm,alldata_item8[is.na(sold_count)==T])
pred_item8_category_sold_June20
alldata_item8$category_sold[1] <- pred_item8_category_sold_June20


#predicting sold_count using ARIMAX model for 2 day ahead:

random = resultweekdec$random
trend = resultweekdec$trend
season = resultweekdec$seasonal
model <- arima(random, order= c(3,0,2), xreg = regressors)

newregmatrix <- pr8[c(1:5), c(7,8,13)]
model.forecast <- predict(model, n.ahead = 5, newxreg = newregmatrix)$pred

last.trend.value <-tail(resultweekdec$trend[!is.na(resultweekdec$trend)],5)
seasonality <- resultweekdec$seasonal[370:374] # going to change each day

forecast_normalized <- model.forecast*last.trend.value*seasonality

#forecasted value
alldata_item8$sold_count[1] <- forecast_normalized[5]
