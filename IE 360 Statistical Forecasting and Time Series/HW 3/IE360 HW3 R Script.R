library(tidyverse)
library(lubridate)
library(zoo)
library(ggplot2)
library(data.table)
library(dplyr)
library(forecast)



consumption=fread("RealTimeConsumption.csv")

head(consumption,)
str(consumption)

consumption <- consumption[,-c(4,4)]

numeric_hour <- rep(0:23, 1967 )
consumption[,datetime:=dmy(Date)+dhours(numeric_hour)]
consumption=consumption[order(datetime)]

colnames(consumption)[3] <- "Consumption.MWh"

weeknumber_for_first<- rep(1,72)
n <- 7*24
k <- rep(2:281,each=n)
last<- rep(282,96)
weeknumber<- c(weeknumber_for_first,k,last)

consumption$week.number<- weeknumber
consumption$Year <- format(consumption$Date, format = "%y")

consumption <- mutate(consumption, Date = dmy(Date))
consumption[,Month:=(lubridate::month(Date,label=F))]
consumption[,w_day:=as.character(lubridate::wday(Date,label=T))]


ggplot(consumption[ datetime <= '2021-05-20' & datetime >='2021-05-01'],aes(x=datetime,y= Consumption.MWh)) + geom_line()
consumption[consumption$Consumption.MWh == 0] <- NA
consumption <- na.omit(consumption)
ggplot(consumption[ datetime <= '2016-03-28' & datetime >='2016-03-26'],aes(x=datetime,y= Consumption.MWh)) + geom_line() +  geom_point()
ggplot(consumption,aes(x=datetime,y= Consumption.MWh)) + geom_line()

daily_series= consumption[,list(Consumption.MWh=mean(Consumption.MWh)),by=list(Date)]
head(daily_series)
str(daily_series)
?arima
ggplot(daily_series ,aes(x=Date,y=Consumption.MWh)) + geom_line()

daily_series[,w_day:=as.character(lubridate::wday(Date,label=T))]
str(daily_series)

monthly_series = aggregate( Consumption.MWh ~ Month + Year, consumption, mean)
monthly_date <-seq(as.Date("2016-01-01"), as.Date("2021-05-20"), by ="month")
monthly_series$monthly_date <- monthly_date

ggplot(monthly_series ,aes(x=monthly_date,y=Consumption.MWh)) + geom_line()

weekly_series = aggregate( Consumption.MWh ~ week.number, consumption, mean)

weekly_date <-seq(as.Date("2016-01-04"), as.Date("2021-05-20"), by ="week")
str(weekly_date)
first_week<- as.Date("2016-01-01")
str(first_week)
weekly_date <- c(first_week,weekly_date)
weekly_series$weekly_date <-weekly_date

ggplot(weekly_series ,aes(x=weekly_date,y=Consumption.MWh)) + geom_line()

ggplot(consumption,aes(x=datetime,y= Consumption.MWh)) + geom_line()

hourly.consumption.ts <- ts(consumption$Consumption.MWh,  freq = 8760, start= c(2016,1))
ts.plot(hourly.consumption.ts)
acf(hourly.consumption.ts)
hourly.consumption.dec.additive <- decompose(hourly.consumption.ts,type= "additive")
plot(hourly.consumption.dec.additive)


daily.consumption.ts <- ts(daily_series$Consumption.MWh, freq = 365, start = c(2016,1))
acf(daily.consumption.ts)
ts.plot(daily.consumption.ts)
daily.consumption.dec.additive <- decompose(daily.consumption.ts,type= "additive")
plot(daily.consumption.dec.additive)

weekly.consumption.ts <- ts(weekly_series$Consumption.MWh, freq = 52, start = c(2016,1))
acf(weekly.consumption.ts,lag.max = 50)
ts.plot(weekly.consumption.ts)                            
weekly.consumption.dec.additive <- decompose(weekly.consumption.ts,type="additive")
plot(weekly.consumption.dec.additive)
weekly.consumption.dec.additive$trend

monthly.consumption.ts <- ts(monthly_series$Consumption.MWh, freq = 12, start = c(2016,1))
ts.plot(monthly.consumption.ts)
acf(monthly.consumption.ts)
monthly.consumption.dec.additive <- decompose(monthly.consumption.ts,type= "additive")
plot(monthly.consumption.dec.additive)


consumption[,differ1:= Consumption.MWh - shift(Consumption.MWh,24)]
unt_test2=ur.kpss(consumption$differ1) 
summary(unt_test2)
consumption[,differ2:= differ1 - shift(differ1,168)]
unt_test=ur.kpss(consumption$differ2) 
summary(unt_test)


consumption[,differ:=Consumption.MWh - shift(Consumption.MWh,168)]
library(urca)
unt_test=ur.kpss(detrend.weekly) 
summary(unt_test)


ggplot(consumption,aes(x=Date)) + geom_line(aes(y=differ))
ggplot(consumption,aes(x=Date)) + geom_line(aes(y=Consumption.MWh))
ggplot(consumption,aes(x=Date)) + geom_line(aes(y=differ1))
ggplot(consumption,aes(x=Date)) + geom_line(aes(y=differ2))

acf(consumption[!is.na(differ)]$differ)
pacf(consumption[!is.na(differ)]$differ)

acf(consumption[!is.na(differ1)]$differ1)
pacf(consumption[!is.na(differ1)]$differ1)
consumption[,-c(9,9)]
length(consumption$Consumption.MWh)

training.consumption <- head(consumption$Consumption.MWh, length(consumption$Consumption.MWh) - 24*14)
test.consumption <- ts((tail(consumption$Consumption.MWh, (24*14 + 84 + 12))),freq = 168 ,start=c(279,(168-84-12+1)) )
all.consumption.ts <- ts(consumption$Consumption.MWh, freq = 168)

weekly.ts <- ts(training.consumption,freq = 168)
ts.plot(weekly.ts)
weekly.decompose <- decompose(weekly.ts,type="additive")
plot(weekly.decompose)
deseason.weekly <- weekly.ts - weekly.decompose$seasonal
ts.plot(deseason.weekly)
detrend.weekly <- deseason.weekly - weekly.decompose$trend
ts.plot(detrend.weekly)

weekly.daily.ts <- ts(detrend.weekly, freq = 24)
ts.plot(weekly.daily.ts)
weekly.daily.decompose <- decompose(weekly.daily.ts,type="additive")
plot(weekly.daily.decompose)
deseason.daily <- weekly.daily.ts - weekly.daily.decompose$seasonal
detrend.daily <- deseason.daily - weekly.daily.decompose$trend
ts.plot(detrend.daily)

ramazan.arife <- rep(2,24)
ramazan.first <- rep(3,24)
ramazan.second <- rep(2,24)
ramazan.third <- rep(1,24)
ramazan.bayrami <- c(ramazan.arife,ramazan.first,ramazan.second,ramazan.third)
not.ramazan.beginning <- which(consumption$datetime == "2016-07-04") 
a <- which(consumption$datetime == "2019-06-03") 
not.ramazan <- rep(0,4439)
ramazan.bayrams <- c(not.ramazan,ramazan.bayrami)

special.for2016 <- rep(0,352*24)
not.ramazan10 <- rep(0, (351*24))
not.ramazan11 <- rep(0, (350*24))
ramazan.bayrams <- c(ramazan.bayrams,special.for2016)
ramazan.bayrams <- c(ramazan.bayrams,ramazan.bayrami)
ramazan.bayrams <- c(ramazan.bayrams,not.ramazan10)
ramazan.bayrams <- c(ramazan.bayrams,ramazan.bayrami)
ramazan.bayrams <- c(ramazan.bayrams,not.ramazan11)
ramazan.bayrams <- c(ramazan.bayrams,ramazan.bayrami)
ramazan.bayrams <- c(ramazan.bayrams,not.ramazan11)
ramazan.bayrams <- c(ramazan.bayrams,ramazan.bayrami)
ramazan.bayrams <- c(ramazan.bayrams,not.ramazan11)
ramazan.bayrams <- c(ramazan.bayrams,ramazan.bayrami)
ramazan.bayrams <- c(ramazan.bayrams, rep(0,120))
ramazan.bayrams.ts <- ts(ramazan.bayrams, freq = 8760, start= c(2016,1))
ts.plot(ramazan.bayrams.ts)


training.resmitat <- head(consumption$ResmiTatil, length(consumption$ResmiTatil) - 24*14) 
test.resmitat <- ts((tail(consumption$ResmiTatil, (24*14 + 84 + 12))),freq = 168 ,start=c(279,(168-84-12+1)) )
all.resmitat.ts <- ts(consumption$ResmiTatil, freq = 168)

consumption$ramazan.detector <- ramazan.bayrams

pacf(detrend.daily[!is.na(detrend.daily)])
tsdisplay(detrend.daily)


ResmiTatil <- read.csv("ResmiTatil.csv")
ResmiTatil$ResmiTatil <- as.Date(ResmiTatil$ResmiTatil)
ResmiTatilDate <- (ResmiTatil$ResmiTatil$Date)
normaldate <- (consumption$Date)
head(aglicam,50)
aglicam <- rep(0, 47207)
for(j in 1:90){
  for(i in 1:47207){
    if ((ResmiTatilDate[j] == normaldate[i])){
      aglicam[i] <- 1
    }
  }
}
tail(normaldate,50)
tail(aglicam,50)

write.csv(aglicam, file = "resmitat.csv", row.names = FALSE)
library(stats)

resmitat1 <- read.csv("resmitat.csv")
consumption$ResmiTatil <- resmitat1

?arima
modelAR1reg <- arima(detrend.daily, order=c(1,0,0),xreg = training.resmitat, seasonal = list( order = c(0,0,1), period = 24))
print(modelAR1reg)
modelAR1 <- arima(detrend.daily, order=c(1,0,0))
print(modelAR1)
modelAR2 <- arima(detrend.daily, order=c(2,0,0),seasonal = T, intercept = T)
print(modelAR2)
modelAR3 <- arima(detrend.daily, order=c(3,0,0))
print(modelAR3)
modelAR4 <- arima(detrend.daily, order=c(4,0,0))
print(modelAR4)
modelAR5 <- arima(detrend.daily, order=c(10,0,0))
print(modelAR5)
modelMA1 <- arima(detrend.daily, order=c(0,0,1))
print(modelMA1)
modelMA2 <- arima(detrend.daily, order=c(0,0,5))
print(modelMA2)
modelMA3 <- arima(detrend.daily, order=c(0,0,10))
print(modelMA3)
modelARIMA1 <- arima(detrend.daily, order=c(3,0,3))
print(modelARIMA1)
modelARIMA2 <- arima(detrend.daily, order=c(4,0,4))
print(modelARIMA2)
modelARIMA3 <- arima(detrend.daily, order=c(4,1,4))
print(modelARIMA3)
modelARIMA4 <- arima(detrend.daily, order=c(5,0,5))
print(modelARIMA4)

#** Chosen model
modelARIMA5 <- arima(detrend.daily, order=c(5,0,4),xreg = training.resmitat, seasonal = list( order = c(0,0,1), period = 24))
print(modelARIMA5)
checkresiduals(modelARIMA5)
#** Chosen model

modelARIMA6 <- arima(detrend.daily, order=c(4,0,5))
print(modelARIMA6)

modelARIMA0 <- arima(detrend.daily, order=c(2,0,2))
print(modelARIMA0)

tail(detrend.daily,97)

model_fitted <- detrend.daily - residuals(modelAR1reg)
model_fitted_transformed <- model_fitted + weekly.daily.decompose$trend + weekly.daily.decompose$seasonal
model_fitted_transformed1 <- ts(model_fitted_transformed,freq = 168)
model_fitted_transformed2 <- model_fitted_transformed1 + weekly.decompose$trend + weekly.decompose$seasonal

tail(weekly.decompose$trend,97)

plot(all.consumption.ts, xlim = c(279,283))
points(model_fitted_transformed2, type= "l", col = 2,xlim = c(279,283))

tail(weekly.daily.decompose$trend,97)
model_fitted_transformed2
?predict
model.forecast <- predict(modelAR1reg, n.ahead = 432, newxreg = test.resmitat)$pred
model.forecast= ts(model.forecast, frequency = 168, start=c(279,(168-84-12+1)))
model.forecast
#use last trend value
last.trend.value <-tail(weekly.decompose$trend[!is.na(weekly.decompose$trend)],432) + tail(weekly.daily.decompose$trend[!is.na(weekly.daily.decompose$trend)],432)
seasonality=weekly.daily.decompose$seasonal[97:528] + weekly.decompose$seasonal[97:528]
#back to the original series

model.forecast.last = model.forecast + last.trend.value + seasonality
points(model.forecast.last, type = "l", col = 3)

accuracy(object = model.forecast.last, x = test.consumption)
plot(test.consumption, type="l")

tail(daily_series,14)

daily.model.forecast = ts(model.forecast.last,freq= 24)
tested.data <- tail(consumption, 24*14)

daily.model.forecast1 <- daily.model.forecast[-c(1:96)]

tested.data$daily.model.forecast <- daily.model.forecast1

daily.mean.comparison.data <-tested.data[,list(mean.consumption = mean(Consumption.MWh,na.rm=T), mean.forecast = mean(daily.model.forecast,na.rm=T)), by=list(Date)]

daily.bias <- sum(daily.mean.comparison.data$mean.consumption - daily.mean.comparison.data$mean.forecast) / 14

WMAPE <- sum(abs((daily.mean.comparison.data$mean.consumption- daily.mean.comparison.data$mean.forecast)))/ sum(daily.mean.comparison.data$mean.consumption) * 100

errors <- tested.data[,list( MAPE = sum(abs((daily.model.forecast - Consumption.MWh)/Consumption.MWh))/24, daily.bias = sum(Consumption.MWh - daily.model.forecast)/24), by= list(Date)]
