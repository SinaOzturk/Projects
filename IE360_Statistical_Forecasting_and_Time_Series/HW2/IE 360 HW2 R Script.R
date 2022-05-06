library(tidyverse)
library(lubridate)
library(zoo)
library(ggplot2)
library(data.table)
library(dplyr)
library(forecast)

EVDSdata <- read.csv(file = "EVDS.csv")
EVDSdata
EVDSdata <- mutate(EVDSdata, Date = ym(ï..Tarih))
EVDSdata = select(EVDSdata, -1)
colnames(EVDSdata) <- c("USD","Interest","CPI","Clothing","CCI","Date")
EVDSdata <- EVDSdata[-c(112:121),]
EVDSdata[1,]

ggplot(EVDSdata,aes(x= Date, y = CPI)) + geom_line()
EVDSdata <- as.data.table(EVDSdata)
EVDSdata[,trend:=1:.N, ]
head(EVDSdata)

fit2 = lm(CPI ~trend, data = EVDSdata)
summary(fit2)

EVDSdata[,pred_trend := predict(fit2,EVDSdata)]

ggplot(EVDSdata,aes(x= Date)) + geom_line(aes(y=CPI,color='real')) + geom_line(aes(y= pred_trend, color='trend'))


EVDSdata[,mon:=as.character(lubridate::month(Date,label = TRUE))]
head(EVDSdata)

fit3 = lm(CPI~trend+mon,data = EVDSdata)
summary(fit3)

EVDSdata[,pred_trend_month:=predict(fit3,EVDSdata)]

ggplot(EVDSdata,aes(x= Date)) + 
  geom_line(aes(y=CPI,color='real')) + 
  geom_line(aes(y= pred_trend_month, color='trend'))

ggplot(EVDSdata,aes(x= Date)) + geom_line(aes(y= CPI - pred_trend_month , color='residual'))

checkresiduals(fit3$residuals)

EVDSdata[,residual:=fit3$residuals]
head(EVDSdata)

ggplot(EVDSdata,aes(x=USD,y=residual)) + 
  geom_line() +
  geom_smooth() 

fit4 = lm(CPI~ trend+mon+USD, data= EVDSdata)
summary(fit4)


EVDSdata[,pred_trend_month_USD:=predict(fit4,EVDSdata)]

ggplot(EVDSdata,aes(x= Date)) + 
  geom_line(aes(y=CPI,color='real')) + 
  geom_line(aes(y= pred_trend_month_USD, color='trend'))

fit5 = lm(CPI~trend + mon + USD + Interest + Clothing + CCI, data= EVDSdata)
summary(fit5)

EVDSdata[,pred_trend_month_USD_Interest_Clothing_CCI:=predict(fit5,EVDSdata)]

checkresiduals(fit5$residuals)
EVDSdata[,lag1:=shift(residuals(fit5),1)]
EVDSdata[,lag2:=shift(residuals(fit5),2)]

fit6 = lm(CPI~trend + mon + USD + Interest + Clothing + CCI + lag1 + lag2 , data= EVDSdata)
summary(fit6)
checkresiduals(fit6)

EVDSdata[,pred_trend_month_USD_Interest_Clothing_CCI_lags:=predict(fit6,EVDSdata)]

ggplot(EVDSdata,aes(x= Date)) + 
  geom_line(aes(y=CPI,color='real')) + 
  geom_line(aes(y=pred_trend_month_USD_Interest_Clothing_CCI_lags , color='trend'))


interest_last_3 <- mean(EVDSdata[109:111]$Interest)
USD_last_3 <- mean(EVDSdata[109:111]$USD)
Clothing_last_3 <- mean(EVDSdata[109:111]$Clothing)
CCI_last_3 <- mean(EVDSdata[109:111]$CCI)
lag1_last <- EVDSdata$lag1[111]
lag2_last <- EVDSdata$lag1[110]
EVDSdata <- rbind(EVDSdata,data.table(Date = as.Date("2021-04-01")), fill=T)
EVDSdata$trend[112]= as.numeric(112)
EVDSdata$USD[112]= USD_last_3
EVDSdata$CCI[112]= CCI_last_3
EVDSdata$Clothing[112]= Clothing_last_3
EVDSdata$Interest[112]= interest_last_3
EVDSdata$mon[112]= as.character("Apr")
EVDSdata$lag1[112] = lag1_last  
EVDSdata$lag2[112] = lag2_last  

  
predict(fit6,EVDSdata[is.na(CPI)==T])
EVDSdata[is.na(CPI)==T,CPI:=predict(fit6,EVDSdata[is.na(CPI)==T])]
print(EVDSdata$CPI[112])

a = summary(fit6)
a$adj.r.squared