library("readxl")
library(ggplot2)
library(forecast)
library(tseries)

# product id: 7061886

pr6 <- read_excel("C:\\Users\\AHMET\\Desktop\\item6.xlsx")
ggplot(data = pr6, aes(x = event_date, y = sold_count))+ geom_point()+ geom_line(aes(group=1))

tspr6 <- ts(pr6$sold_count, freq = 7, start = c(1,1))

decpr6 <- decompose(tspr6, type = "additive")
plot(decpr6)
tsdisplay(decpr6$seasonal)
tsdisplay(decpr6$random)
kpss.test(decpr6$random)

randompr6 <- decpr6$random

# arima(1,0,2) initially decided by looking at acf&pacf plots of the random component

pr6arima <- arima(randompr6, order=c(1,0,2))
pr6arima

# neighborhood search:

pr6ar1 <- arima(randompr6, order=c(0,0,2))
pr6ar1 

pr6ar2 <- arima(randompr6, order=c(2,0,2))
pr6ar2 

pr6ar3 <- arima(randompr6, order=c(1,0,1))
pr6ar3 

pr6ar4 <- arima(randompr6, order=c(1,0,3))
pr6ar4 #lowest AIC

# arima(1,0,3) is decided

pr6model <- pr6ar4

model_fitted_pr6 <- randompr6 - residuals(pr6model)
model_fitted_transformed_pr6 <- model_fitted_pr6+decpr6$trend+decpr6$seasonal
plot(weeklytspr6, xlab = "Weeks", ylab = "Sold Count",main="Actual (Black) vs. Predicted (Blue)")+points(model_fitted_transformed_pr6, type = "l", col = 5, lty = 1)

model_forecast_pr6 = predict(pr6model, n.ahead=2)$pred
last_trend_pr6 = tail(decpr6$trend[!is.na(decpr6$trend)], 1)
seasonality_pr6 = decpr6$seasonal[5:6] # insert the corresponding index of seasonal component for today and the predicted day
model_forecast_pr6 = model_forecast_pr6+last_trend_pr6+seasonality_pr6
model_forecast_pr6 #second result is the prediction for the next day