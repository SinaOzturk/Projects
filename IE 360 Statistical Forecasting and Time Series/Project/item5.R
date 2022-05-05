library("readxl")
library(ggplot2)
library(forecast)
library(tseries)

# product id: 6676673

pr5 <- read_excel("C:\\Users\\AHMET\\Desktop\\item5.xlsx")
ggplot(data = pr5, aes(x = event_date, y = sold_count))+ geom_point()+ geom_line(aes(group=1))


tspr5 <- ts(pr5$sold_count, freq = 7, start = c(1,1))
decpr5 <- decompose(tspr5, type = "additive")
plot(decpr5)
tsdisplay(decpr5$seasonal)
tsdisplay(decpr5$random)
kpss.test(decpr5$random)

# after analyzing the acf&pacf plots of the random component, autocorrelation between every three days is realized. new time series data is formed for 3-days periods

threetspr5 <- ts(pr5$sold_count, freq = 3, start = c(1,1))
decthreepr5 <- decompose(threetspr5, type = "additive")
plot(decthreepr5)
tsdisplay(decthreepr5$seasonal)
tsdisplay(decthreepr5$random)
kpss.test(decthreepr5$random)

randompr5 <- decthreepr5$random

# arima(0,0,2) initially decided by looking at acf&pacf plots of the random component

pr5arima <- arima(randompr5, order=c(0,0,2))
pr5arima

# neighborhood search:

pr5ar1 <- arima(randompr5, order=c(0,0,1))
pr5ar1 

pr5ar2 <- arima(randompr5, order=c(0,0,3))
pr5ar2 

pr5ar3 <- arima(randompr5, order=c(1,0,2))
pr5ar3 #lowest AIC

# arima(1,0,2) is decided

pr5model <- pr5ar3

model_fitted_pr5 <- randompr5 - residuals(pr5model)
model_fitted_transformed_pr5 <- model_fitted_pr5+decthreepr5$trend+decthreepr5$seasonal
plot(threetspr5, xlab = "3-Days", ylab = "Sold Count",main="Actual (Black) vs. Predicted (Blue)")+points(model_fitted_transformed_pr5, type = "l", col = 5, lty = 1)

model_forecast_pr5 = predict(pr5model, n.ahead=2)$pred
last_trend_pr5 = tail(decthreepr5$trend[!is.na(decthreepr5$trend)], 1)
seasonality_pr5 = decthreepr5$seasonal[1:2] # insert the corresponding index of seasonal component for today and the predicted day
model_forecast_pr5 = model_forecast_pr5+last_trend_pr5+seasonality_pr5
model_forecast_pr5 #second result is the prediction for the next day






