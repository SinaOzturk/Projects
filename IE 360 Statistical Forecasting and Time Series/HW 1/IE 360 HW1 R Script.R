

library(tidyverse)
library(lubridate)
library(zoo)
library(EVDS)
library(ggplot2)
library(data.table)

set_evds_key("Rw8XwgzVe4")

#Kurlar/ Döviz Kurları/ ABD Doları (Döviz Alış) -> TP.DK.USD.A.YTL
#Kurlar/ Döviz Kurları/ Euro (Döviz Alış) -> TP.DK.EUR.A.YTL
#Turizm İstatistikleri/ Seyahat Gelirleri ve Giderleri/ Toplam Seyahat Geliri -> TP.SGEGI.K1
#Turizm İstatistikleri/ Milliyetlere Göre Ziyaretçi Sayısı -> TP.ODEMGZS.GTOPLAM
#Fiyat Endeksleri/ Fiyat Endeksi(Tüketici)/ Genel -> TP.FG.J0US_Dollar <- as.numeric(df$items$TP_DK_USD_A_YTL)

df <- get_series(series = c("TP.DK.USD.A.YTL","TP.DK.EUR.A.YTL","TP.SGEGI.K1","TP.ODEMGZS.GTOPLAM","TP.FG.J0"), start_date = "01-01-2008",end_date = "31-12-2020")

US_Dollar <- as.numeric(df$items$TP_DK_USD_A_YTL)
Euro <- as.numeric(df$items$TP_DK_EUR_A_YTL)
Total_Travel_Incomes_millionUSD <- as.numeric(df$items$TP_SGEGI_K1)
Number_of_Total_Tourist <- as.numeric(df$items$TP_ODEMGZS_GTOPLAM)
Consumer_Price_Index <- as.numeric(df$items$TP_FG_J0)
Tarih <- as.character(df$items$Tarih)

df1 <- data.frame(Tarih,US_Dollar,Euro,Consumer_Price_Index,Number_of_Total_Tourist,Total_Travel_Incomes_millionUSD)

na.omit(df1)
df1 <- mutate(df1, Date = ym(Tarih))

## Currency Rates
df1 %>%
  ggplot(aes(x = Date, y = US_Dollar)) + 
  geom_line(aes(color = "Dolar")) + 
  geom_line(aes(y = Euro, color ="Euro")) +
  expand_limits(y= c(1,10)) +
  labs(title = "Exchange Rates vs. Time", x = "Time", y = "Currency Rates") + 
  scale_x_date(date_breaks = "6 month", date_labels = "%Y %b", date_minor_breaks = "1 month") +
  theme(axis.text.x=element_text(angle=60, hjust=1.4, vjust = 1.4)) +
  theme(legend.position= "top" , legend.background = element_rect(fill="gray", linetype="solid"))
  
##Tourism Data
df1 %>%
  ggplot(aes(x=Date, y = Number_of_Total_Tourist)) +
  geom_line(color = "Blue") +
  labs(title = "The number of tourists visiting Turkey", x = "Time (Monthly)", y = "Total Number of Tourists") +
  scale_x_date(date_breaks = "6 month", date_labels = "%Y %b", date_minor_breaks = "1 month") +
  theme(axis.text.x=element_text(angle=60, hjust=1.4, vjust = 1.4))

df1 %>%
  ggplot(aes(x=Date, y = Total_Travel_Incomes_millionUSD)) + 
  geom_line(color = 6) + 
  labs(title = "Tourism Income vs. Time", x = "Time(Monthly)", y = "Incomes from Tourists (million USD)") +
  scale_x_date(date_breaks = "6 month", date_labels = "%Y %b", date_minor_breaks = "1 month") +
  theme(axis.text.x=element_text(angle=60, hjust=1.4, vjust = 1.4))

##Consumer Price Index
df1 %>%
  ggplot(aes(x=Date, y = Consumer_Price_Index)) + 
  geom_line(color= 9) +
  labs(title = "Consumer Price Index vs. Time (Base year 2003 = 100)", y = "Consumer Price Index", x = "Time(Monthly)") +
  scale_x_date(date_breaks = "6 month", date_labels = "%Y %b", date_minor_breaks = "1 month") + 
  theme(axis.text.x=element_text(angle=60, hjust=1.4, vjust = 1.4))


### PART B (GoogleTrends)

##reading google trends chunk
antalya <- read.csv(file = "antalya.csv")
dolarkuru <- read.csv(file = "dolarkuru.csv")
asgariucret <- read.csv(file = "asgariucret.csv")


## manupulate the data
antalya <- antalya[-1,]
antalya <- as.numeric(antalya)
dolarkuru <- dolarkuru[-1,]
na.omit(dolarkuru)
dolarkuru <- as.numeric(dolarkuru)
asgariucret <- asgariucret[-1,]
asgariucret <- as.numeric(asgariucret)
gtrends <- data.frame(Tarih, asgariucret, antalya, dolarkuru)
gtrends <- mutate(gtrends,Date = ym(Tarih))

##plotting google trends searches

#antalya
gtrends %>%
  ggplot(aes(x= Date, y = antalya)) +
  geom_line(color = 1) + 
  labs(title = " Antalya Search in GoogleTrends", x = "Time(Monthly", y = "Antalya Search") +
  scale_x_date(date_breaks = "6 month", date_labels = "%Y %b", date_minor_breaks = "1 month") + 
  theme(axis.text.x=element_text(angle=60, hjust=1.4, vjust = 1.4))

#dolar kuru
gtrends %>%
  ggplot(aes(x= Date, y = dolarkuru)) +
  geom_line(color = 1) + 
  labs(title = " 'Dolar Kuru' Search in GoogleTrends", x = "Time(Monthly", y = "'Dolar Kuru' Search") +
  scale_x_date(date_breaks = "6 month", date_labels = "%Y %b", date_minor_breaks = "1 month") + 
  theme(axis.text.x=element_text(angle=60, hjust=1.4, vjust = 1.4))

#asgari ucret
gtrends %>%
  ggplot(aes(x= Date, y = asgariucret)) +
  geom_line(color = 1) + 
  labs(title = " 'Asgari Ucret' Search in GoogleTrends", x = "Time(Monthly", y = " 'Asgari Ucret' Search") +
  scale_x_date(date_breaks = "6 month", date_labels = "%Y %b", date_minor_breaks = "1 month") + 
  theme(axis.text.x=element_text(angle=60, hjust=1.4, vjust = 1.4))



