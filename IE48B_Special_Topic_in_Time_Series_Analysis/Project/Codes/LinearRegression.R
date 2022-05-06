library(data.table)
library(lubridate)
library(ggplot2)
library(repr)
library(rpart)
library(rattle)
library(TSrepr)
library(zoo)
library(TunePareto)

bulk_imbalance <- read.csv("bulk_imbalance.csv") # reliable data until 21st January from 1st January 2019
bulk_imbalance <- bulk_imbalance[-c(26809:26832),]
weather <- read.csv("2022-01-22_weather.csv")
smp <- read.csv("SMF.csv")
mcp <- read.csv("MCP.csv")

mcp$PTF..TL.MWh. <- gsub(",", "", mcp$PTF..TL.MWh.)
smp$SMF..TL.MWh. <- gsub(",", "", smp$SMF..TL.MWh.)

mcp$PTF..TL.MWh. <- as.numeric(mcp$PTF..TL.MWh.)
mcp$PTF..TL.MWh. <- mcp$PTF..TL.MWh./100
smp$SMF..TL.MWh. <- as.numeric(smp$SMF..TL.MWh.)
smp$SMF..TL.MWh. <- smp$SMF..TL.MWh./100

for ( i in (1:26808)){
  if(mcp$PTF..TL.MWh.[i] < 1){
    mcp$PTF..TL.MWh.[i] = mcp$PTF..TL.MWh.[i]*100000
  }
}

for ( i in (1:26808)){
  if(smp$SMF..TL.MWh.[i] < 1){
    smp$SMF..TL.MWh.[i] = smp$SMF..TL.MWh.[i]*100000
  }
}

# adding SMP and MCP information into our data
bulk_imbalance[,SMP := smp$SMF..TL.MWh.]
bulk_imbalance[,MCP := mcp$PTF..TL.MWh.]

# adding DSWRF_surface information into our data

DSWRF_surface <- weather[weather$variable %in% "DSWRF_surface",]

DSWRF_surface_36.5_32.5 <- DSWRF_surface[DSWRF_surface$lat %in% '36.5',]
DSWRF_surface_36.5_32.5 <- DSWRF_surface_36.5_32.5[-c(1:24),]
DSWRF_surface_36.5_32.5 <- DSWRF_surface_36.5_32.5[-c(26809:26952),]

DSWRF_surface_37_35.5 <- DSWRF_surface[DSWRF_surface$lat %in% '37',]
DSWRF_surface_37_35.5 <- DSWRF_surface_37_35.5[-c(1:24),]
DSWRF_surface_37_35.5 <- DSWRF_surface_37_35.5[-c(26809:26952),]

DSWRF_surface_38_32.5 <- DSWRF_surface[DSWRF_surface$lat %in% '38',]
DSWRF_surface_38_32.5 <- DSWRF_surface_38_32.5[-c(1:24),]
DSWRF_surface_38_32.5 <- DSWRF_surface_38_32.5[-c(26809:26952),]

DSWRF_surface_38.5_27 <- DSWRF_surface[DSWRF_surface$lat %in% '38.5',]
DSWRF_surface_38.5_27 <- DSWRF_surface_38.5_27[-c(1:24),]
DSWRF_surface_38.5_27 <- DSWRF_surface_38.5_27[-c(26809:26952),]

DSWRF_surface_39.75_30.5 <- DSWRF_surface[DSWRF_surface$lat %in% '39.75',]
DSWRF_surface_39.75_30.5 <- DSWRF_surface_39.75_30.5[-c(1:24),]
DSWRF_surface_39.75_30.5 <- DSWRF_surface_39.75_30.5[-c(26809:26952),]

DSWRF_surface_40_33 <- DSWRF_surface[DSWRF_surface$lat %in% '40',]
DSWRF_surface_40_33 <- DSWRF_surface_40_33[-c(1:24),]
DSWRF_surface_40_33 <- DSWRF_surface_40_33[-c(26809:26952),]

DSWRF_surface_41_28.75 <- DSWRF_surface[DSWRF_surface$lat %in% '41',]
DSWRF_surface_41_28.75 <- DSWRF_surface_41_28.75[-c(1:24),]
DSWRF_surface_41_28.75 <- DSWRF_surface_41_28.75[-c(26809:26952),]


bulk_imbalance <- as.data.table(bulk_imbalance)
bulk_imbalance[,DSWRF_surface_41_28.75 := DSWRF_surface_41_28.75$value]
bulk_imbalance[,DSWRF_surface_40_33 := DSWRF_surface_40_33$value]
bulk_imbalance[,DSWRF_surface_39.75_30.5 := DSWRF_surface_39.75_30.5$value]
bulk_imbalance[,DSWRF_surface_38.5_27 := DSWRF_surface_38.5_27$value]
bulk_imbalance[,DSWRF_surface_38_32.5 := DSWRF_surface_38_32.5$value]
bulk_imbalance[,DSWRF_surface_37_35.5 := DSWRF_surface_37_35.5$value]
bulk_imbalance[,DSWRF_surface_36.5_32.5 := DSWRF_surface_36.5_32.5$value]


# adding RH_2 information into our data

RH_2 <- weather[weather$variable %in% "RH_2.m.above.ground",]

RH_2_36.5_32.5 <- RH_2[RH_2$lat %in% '36.5',]
RH_2_36.5_32.5 <- RH_2_36.5_32.5[-c(1:24),]
RH_2_36.5_32.5 <- RH_2_36.5_32.5[-c(26809:26952),]

RH_2_37_35.5 <- RH_2[RH_2$lat %in% '37',]
RH_2_37_35.5 <- RH_2_37_35.5[-c(1:24),]
RH_2_37_35.5 <- RH_2_37_35.5[-c(26809:26952),]

RH_2_38_32.5 <- RH_2[RH_2$lat %in% '38',]
RH_2_38_32.5 <- RH_2_38_32.5[-c(1:24),]
RH_2_38_32.5 <- RH_2_38_32.5[-c(26809:26952),]

RH_2_38.5_27 <- RH_2[RH_2$lat %in% '38.5',]
RH_2_38.5_27 <- RH_2_38.5_27[-c(1:24),]
RH_2_38.5_27 <- RH_2_38.5_27[-c(26809:26952),]

RH_2_39.75_30.5 <- RH_2[RH_2$lat %in% '39.75',]
RH_2_39.75_30.5 <- RH_2_39.75_30.5[-c(1:24),]
RH_2_39.75_30.5 <- RH_2_39.75_30.5[-c(26809:26952),]

RH_2_40_33 <- RH_2[RH_2$lat %in% '40',]
RH_2_40_33 <- RH_2_40_33[-c(1:24),]
RH_2_40_33 <- RH_2_40_33[-c(26809:26952),]

RH_2_41_28.75 <- RH_2[RH_2$lat %in% '41',]
RH_2_41_28.75 <- RH_2_41_28.75[-c(1:24),]
RH_2_41_28.75 <- RH_2_41_28.75[-c(26809:26952),]

bulk_imbalance[,RH_2_41_28.75 := RH_2_41_28.75$value]
bulk_imbalance[,RH_2_40_33 := RH_2_40_33$value]
bulk_imbalance[,RH_2_39.75_30.5 := RH_2_39.75_30.5$value]
bulk_imbalance[,RH_2_38.5_27 := RH_2_38.5_27$value]
bulk_imbalance[,RH_2_38_32.5 := RH_2_38_32.5$value]
bulk_imbalance[,RH_2_37_35.5 := RH_2_37_35.5$value]
bulk_imbalance[,RH_2_36.5_32.5 := RH_2_36.5_32.5$value]

# adding TMP_2 information into our data

TMP_2 <- weather[weather$variable %in% "TMP_2.m.above.ground",]

TMP_2_36.5_32.5 <- TMP_2[TMP_2$lat %in% '36.5',]
TMP_2_36.5_32.5 <- TMP_2_36.5_32.5[-c(1:24),]
TMP_2_36.5_32.5 <- TMP_2_36.5_32.5[-c(26809:26952),]

TMP_2_37_35.5 <- TMP_2[TMP_2$lat %in% '37',]
TMP_2_37_35.5 <- TMP_2_37_35.5[-c(1:24),]
TMP_2_37_35.5 <- TMP_2_37_35.5[-c(26809:26952),]

TMP_2_38_32.5 <- TMP_2[TMP_2$lat %in% '38',]
TMP_2_38_32.5 <- TMP_2_38_32.5[-c(1:24),]
TMP_2_38_32.5 <- TMP_2_38_32.5[-c(26809:26952),]

TMP_2_38.5_27 <- TMP_2[TMP_2$lat %in% '38.5',]
TMP_2_38.5_27 <- TMP_2_38.5_27[-c(1:24),]
TMP_2_38.5_27 <- TMP_2_38.5_27[-c(26809:26952),]

TMP_2_39.75_30.5 <- TMP_2[TMP_2$lat %in% '39.75',]
TMP_2_39.75_30.5 <- TMP_2_39.75_30.5[-c(1:24),]
TMP_2_39.75_30.5 <- TMP_2_39.75_30.5[-c(26809:26952),]

TMP_2_40_33 <- TMP_2[TMP_2$lat %in% '40',]
TMP_2_40_33 <- TMP_2_40_33[-c(1:24),]
TMP_2_40_33 <- TMP_2_40_33[-c(26809:26952),]

TMP_2_41_28.75 <- TMP_2[TMP_2$lat %in% '41',]
TMP_2_41_28.75 <- TMP_2_41_28.75[-c(1:24),]
TMP_2_41_28.75 <- TMP_2_41_28.75[-c(26809:26952),]

bulk_imbalance[,TMP_2_41_28.75 := TMP_2_41_28.75$value]
bulk_imbalance[,TMP_2_40_33 := TMP_2_40_33$value]
bulk_imbalance[,TMP_2_39.75_30.5 := TMP_2_39.75_30.5$value]
bulk_imbalance[,TMP_2_38.5_27 := TMP_2_38.5_27$value]
bulk_imbalance[,TMP_2_38_32.5 := TMP_2_38_32.5$value]
bulk_imbalance[,TMP_2_37_35.5 := TMP_2_37_35.5$value]
bulk_imbalance[,TMP_2_36.5_32.5 := TMP_2_36.5_32.5$value]

# adding TCDC information into our data

TCDC <- weather[weather$variable %in% "TCDC_low.cloud.layer",]

TCDC_36.5_32.5 <- TCDC[TCDC$lat %in% '36.5',]
TCDC_36.5_32.5 <- TCDC_36.5_32.5[-c(1:24),]
TCDC_36.5_32.5 <- TCDC_36.5_32.5[-c(26809:26952),]

TCDC_37_35.5 <- TCDC[TCDC$lat %in% '37',]
TCDC_37_35.5 <- TCDC_37_35.5[-c(1:24),]
TCDC_37_35.5 <- TCDC_37_35.5[-c(26809:26952),]

TCDC_38_32.5 <- TCDC[TCDC$lat %in% '38',]
TCDC_38_32.5 <- TCDC_38_32.5[-c(1:24),]
TCDC_38_32.5 <- TCDC_38_32.5[-c(26809:26952),]

TCDC_38.5_27 <- TCDC[TCDC$lat %in% '38.5',]
TCDC_38.5_27 <- TCDC_38.5_27[-c(1:24),]
TCDC_38.5_27 <- TCDC_38.5_27[-c(26809:26952),]

TCDC_39.75_30.5 <- TCDC[TCDC$lat %in% '39.75',]
TCDC_39.75_30.5 <- TCDC_39.75_30.5[-c(1:24),]
TCDC_39.75_30.5 <- TCDC_39.75_30.5[-c(26809:26952),]

TCDC_40_33 <- TCDC[TCDC$lat %in% '40',]
TCDC_40_33 <- TCDC_40_33[-c(1:24),]
TCDC_40_33 <- TCDC_40_33[-c(26809:26952),]

TCDC_41_28.75 <- TCDC[TCDC$lat %in% '41',]
TCDC_41_28.75 <- TCDC_41_28.75[-c(1:24),]
TCDC_41_28.75 <- TCDC_41_28.75[-c(26809:26952),]

bulk_imbalance[,TCDC_41_28.75 := TCDC_41_28.75$value]
bulk_imbalance[,TCDC_40_33 := TCDC_40_33$value]
bulk_imbalance[,TCDC_39.75_30.5 := TCDC_39.75_30.5$value]
bulk_imbalance[,TCDC_38.5_27 := TCDC_38.5_27$value]
bulk_imbalance[,TCDC_38_32.5 := TCDC_38_32.5$value]
bulk_imbalance[,TCDC_37_35.5 := TCDC_37_35.5$value]
bulk_imbalance[,TCDC_36.5_32.5 := TCDC_36.5_32.5$value]

# adding ws information into our data

ws <- weather[weather$variable %in% "ws_10m",]

ws_36.5_32.5 <- ws[ws$lat %in% '36.5',]
ws_36.5_32.5 <- ws_36.5_32.5[-c(1:24),]
ws_36.5_32.5 <- ws_36.5_32.5[-c(26809:26952),]

ws_37_35.5 <- ws[ws$lat %in% '37',]
ws_37_35.5 <- ws_37_35.5[-c(1:24),]
ws_37_35.5 <- ws_37_35.5[-c(26809:26952),]

ws_38_32.5 <- ws[ws$lat %in% '38',]
ws_38_32.5 <- ws_38_32.5[-c(1:24),]
ws_38_32.5 <- ws_38_32.5[-c(26809:26952),]

ws_38.5_27 <- ws[ws$lat %in% '38.5',]
ws_38.5_27 <- ws_38.5_27[-c(1:24),]
ws_38.5_27 <- ws_38.5_27[-c(26809:26952),]

ws_39.75_30.5 <- ws[ws$lat %in% '39.75',]
ws_39.75_30.5 <- ws_39.75_30.5[-c(1:24),]
ws_39.75_30.5 <- ws_39.75_30.5[-c(26809:26952),]

ws_40_33 <- ws[ws$lat %in% '40',]
ws_40_33 <- ws_40_33[-c(1:24),]
ws_40_33 <- ws_40_33[-c(26809:26952),]

ws_41_28.75 <- ws[ws$lat %in% '41',]
ws_41_28.75 <- ws_41_28.75[-c(1:24),]
ws_41_28.75 <- ws_41_28.75[-c(26809:26952),]

bulk_imbalance[,ws_41_28.75 := ws_41_28.75$value]
bulk_imbalance[,ws_40_33 := ws_40_33$value]
bulk_imbalance[,ws_39.75_30.5 := ws_39.75_30.5$value]
bulk_imbalance[,ws_38.5_27 := ws_38.5_27$value]
bulk_imbalance[,ws_38_32.5 := ws_38_32.5$value]
bulk_imbalance[,ws_37_35.5 := ws_37_35.5$value]
bulk_imbalance[,Tws_36.5_32.5 := ws_36.5_32.5$value]

# adding wdir information into our data

wdir <- weather[weather$variable %in% "wdir_10m",]

wdir_36.5_32.5 <- wdir[wdir$lat %in% '36.5',]
wdir_36.5_32.5 <- wdir_36.5_32.5[-c(1:24),]
wdir_36.5_32.5 <- wdir_36.5_32.5[-c(26809:26952),]

wdir_37_35.5 <- wdir[wdir$lat %in% '37',]
wdir_37_35.5 <- wdir_37_35.5[-c(1:24),]
wdir_37_35.5 <- wdir_37_35.5[-c(26809:26952),]

wdir_38_32.5 <- wdir[wdir$lat %in% '38',]
wdir_38_32.5 <- wdir_38_32.5[-c(1:24),]
wdir_38_32.5 <- wdir_38_32.5[-c(26809:26952),]

wdir_38.5_27 <- wdir[wdir$lat %in% '38.5',]
wdir_38.5_27 <- wdir_38.5_27[-c(1:24),]
wdir_38.5_27 <- wdir_38.5_27[-c(26809:26952),]

wdir_39.75_30.5 <- wdir[wdir$lat %in% '39.75',]
wdir_39.75_30.5 <- wdir_39.75_30.5[-c(1:24),]
wdir_39.75_30.5 <- wdir_39.75_30.5[-c(26809:26952),]

wdir_40_33 <- wdir[wdir$lat %in% '40',]
wdir_40_33 <- wdir_40_33[-c(1:24),]
wdir_40_33 <- wdir_40_33[-c(26809:26952),]

wdir_41_28.75 <- wdir[wdir$lat %in% '41',]
wdir_41_28.75 <- wdir_41_28.75[-c(1:24),]
wdir_41_28.75 <- wdir_41_28.75[-c(26809:26952),]

bulk_imbalance[,wdir_41_28.75 := wdir_41_28.75$value]
bulk_imbalance[,wdir_40_33 := wdir_40_33$value]
bulk_imbalance[,wdir_39.75_30.5 := wdir_39.75_30.5$value]
bulk_imbalance[,wdir_38.5_27 := wdir_38.5_27$value]
bulk_imbalance[,wdir_38_32.5 := wdir_38_32.5$value]
bulk_imbalance[,wdir_37_35.5 := wdir_37_35.5$value]
bulk_imbalance[,wdir_36.5_32.5 := wdir_36.5_32.5$value]

# adding SMP information into our data
bulk_imbalance[,smp:=smp$SMF..TL.MWh.]

#Adding trend term
bulk_imbalance[,trnd := 1:.N]

#adding name of the days and month variable
bulk_imbalance[,datetime:=ymd(date)+dhours(hour)]
bulk_imbalance[,w_day := as.character(wday(datetime,label=T))]
bulk_imbalance[,mon := as.character(month(datetime,label=T))]

# Training and Test Data (Last 14 days are going to  be test data)

train <- bulk_imbalance[-c(26473:26808),]
test <- bulk_imbalance[c(26473:26808),]

# Now we can start to built linear regression models
#system direction is decided from `net` so our target variable is this one.
# we start with the basic one and contunie with adding new variables in it


lm_1 <- lm(net~ trnd + w_day + mon + as.factor(hour), data = train ) 
summary(lm_1)
# R-squared is very small

lm_2 <- lm(net~ trnd +w_day +mon +as.factor(hour) +MCP +SMP, data=train)
summary(lm_2)


lm_3 <- lm(net~. -datetime -date -hour +as.factor(hour) -upRegulationZeroCoded -upRegulationOneCoded -upRegulationTwoCoded 
           -downRegulationZeroCoded -downRegulationOneCoded -downRegulationTwoCoded -upRegulationDelivered -downRegulationDelivered 
           -system_direction
           , data = train)
summary(lm_3)

lm_4 <- lm(net~. -datetime -date -hour +as.factor(hour) -upRegulationZeroCoded -upRegulationOneCoded -upRegulationTwoCoded 
           -downRegulationZeroCoded -downRegulationOneCoded -downRegulationTwoCoded -upRegulationDelivered -downRegulationDelivered
           , data = bulk_imbalance)
summary(lm_4)

tmp=copy(bulk_imbalance)
tmp[,actual:=net]
tmp[,predicted:=predict(lm_4,tmp)]

tmp[,residual:=actual-predicted]

tmp2 <- tmp[,-c("datetime", "date","upRegulationZeroCoded","upRegulationOneCoded","upRegulationTwoCoded","downRegulationZeroCoded",
                "downRegulationOneCoded","downRegulationTwoCoded",
                "upRegulationDelivered","downRegulationDelivered",
                "net","actual","predicted")]

fit_res_tree=rpart(residual~.,tmp2,
                   control=rpart.control(cp=0,maxdepth=4))

fancyRpartPlot(fit_res_tree)

tmp[,TMP_2_41_depth_1:=as.numeric(TMP_2_41_28.75 < 30)]
tmp[,SMP_depth_2:=as.numeric(SMP < 352)]
tmp[,MCP_depth_3:=as.numeric(MCP >= 0.5)]
tmp[,system_direction_depth_4:=as.numeric(system_direction == "Positive")]

lm_4_iter_1 = lm(net~. -actual - predicted -residual -datetime -date -hour +as.factor(hour) -upRegulationZeroCoded -upRegulationOneCoded -upRegulationTwoCoded 
                 -downRegulationZeroCoded -downRegulationOneCoded -downRegulationTwoCoded -upRegulationDelivered -downRegulationDelivered
                 -TMP_2_41_depth_1 -SMP_depth_2 -MCP_depth_3 -system_direction_depth_4
                 +TMP_2_41_depth_1:SMP_depth_2:MCP_depth_3:system_direction_depth_4
                 , data = tmp)

summary(lm_4_iter_1)

tmp[,predicted:=predict(lm_4_iter_1,tmp)]
tmp[,residual:=actual-predicted]
tmp3 <- tmp[,-c("date", "net","datetime","upRegulationZeroCoded","upRegulationOneCoded","upRegulationTwoCoded","downRegulationZeroCoded",
                "downRegulationOneCoded","downRegulationTwoCoded",
                "upRegulationDelivered","downRegulationDelivered","actual","predicted",
                "TMP_2_41_depth_1", "SMP_depth_2", "MCP_depth_3","system_direction_depth_4")]
fit_res_tree_iter2=rpart(residual~.,tmp3,
                         control=rpart.control(cp=0,maxdepth=4))
fancyRpartPlot(fit_res_tree_iter2)

tmp[,TMP_2_41_depth_1_iter2:=as.numeric(TMP_2_41_28.75 >= 32)]
tmp[,trnd_depth_2_iter2:=as.numeric(trnd >= 23000)]
tmp[,w_day_depth_3_iter2:=as.numeric(!w_day %in% c('Sat','Tue'))]
tmp[,TMP_2_38_depth_4_iter2:=as.numeric(TMP_2_38_32.5 >= 31)]

lm_4_iter_2 = lm(net~. -actual - predicted -residual -datetime -date -hour +as.factor(hour) -upRegulationZeroCoded -upRegulationOneCoded -upRegulationTwoCoded 
                 -downRegulationZeroCoded -downRegulationOneCoded -downRegulationTwoCoded -upRegulationDelivered -downRegulationDelivered
                 -TMP_2_41_depth_1 -SMP_depth_2 -MCP_depth_3 -system_direction_depth_4
                 -TMP_2_41_depth_1_iter2 -trnd_depth_2_iter2 -w_day_depth_3_iter2 -TMP_2_38_depth_4_iter2
                 +TMP_2_41_depth_1:SMP_depth_2:MCP_depth_3:system_direction_depth_4
                 +TMP_2_41_depth_1_iter2:trnd_depth_2_iter2:w_day_depth_3_iter2:TMP_2_38_depth_4_iter2
                 , data = tmp)

summary(lm_4_iter_2)
