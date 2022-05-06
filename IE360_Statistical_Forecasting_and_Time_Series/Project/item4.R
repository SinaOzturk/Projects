library("readxl")
library(ggplot2)
library(forecast)
library(tseries)

# product id: 31515569

pr4 <- read_excel("C:\\Users\\AHMET\\Desktop\\item4.xlsx")
ggplot(data = pr4, aes(x = event_date, y = sold_count))+ geom_point()+ geom_line(aes(group=1))

tspr4 <- ts(pr4$sold_count, freq = 7, start = c(1,1))

decpr4 <- decompose(tspr4, type = "additive")
plot(decpr4)
tsdisplay(decpr4$seasonal)
tsdisplay(decpr4$random)
kpss.test(decpr4$random)

randompr4 <- decpr4$random

# arima(2,0,2) initially decided by looking at acf&pacf plots of the random component

pr4arima <- arima(randompr4, order=c(2,0,2))
pr4arima

# neighborhood search:

pr4ar1 <- arima(randompr4, order=c(1,0,2))
pr4ar1 

pr4ar2 <- arima(randompr4, order=c(3,0,2))
pr4ar2 #lowest AIC

pr4ar3 <- arima(randompr4, order=c(2,0,1))
pr4ar3 

pr4ar4 <- arima(randompr4, order=c(2,0,3))
pr4ar4 

# arima(3,0,2) is decided

pr4model <- pr4ar2

model_fitted_pr4 <- randompr4 - residuals(pr4model)
model_fitted_transformed_pr4 <- model_fitted_pr4+decpr4$trend+decpr4$seasonal
plot(weeklytspr4, xlab = "Weeks", ylab = "Sold Count",main="Actual (Black) vs. Predicted (Blue)")+points(model_fitted_transformed_pr4, type = "l", col = 5, lty = 1)

model_forecast_pr4 = predict(pr4model, n.ahead=2)$pred
last_trend_pr4 = tail(decpr4$trend[!is.na(decpr4$trend)], 1)
seasonality_pr4 = decpr4$seasonal[5:6] # insert the corresponding index of seasonal component for today and the predicted day
model_forecast_pr4 = model_forecast_pr4+last_trend_pr4+seasonality_pr4
model_forecast_pr4 #second result is the prediction for the next day




