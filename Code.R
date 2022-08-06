library(ggplot2)
library(forecast)
library(TSclust)
library(nonlinearTseries)
library(TSEntropies)

#India & Columbia & Australia
###EDA 
temp=GlobalLandTemperaturesByCountry

India=subset(temp, Country == "India")
Colombia = subset(temp, Country == "Colombia")
Australia=subset(temp, Country == "Australia")

india=subset(India, dt >= "1852-07-01")[,2]
colombia=subset(Colombia, dt >= "1852-07-01")[,2]
australia=subset(Australia, dt>="1852-07-01")[,2]

threecountry.ts=ts(cbind(india,colombia, australia), start=c(1852, 7), end=c(2013, 8), freq=12)
threecountry.ts

#plot for original time series: trend check
autoplot(threecountry.ts,facets=T)+geom_smooth()+ylab("Average Temperature")+
  ggtitle("Average Temperature by India, Colombia and Australia")
#from the plot, all of them don't have trend


##polar plot: seasonality check
india.ts=ts(india,start=c(1852,7), end=c(2013,8),freq=12)
colom.ts=ts(colombia,start=c(1852,7),end=c(2013,8), freq=12)
aus.ts=ts(australia,start=c(1852,7), end=c(2013,8),freq=12)

ggseasonplot(india.ts, year.labels=FALSE, continuous=TRUE, polar = TRUE)+
  ggtitle("Seasonality through polarmap for India")

ggseasonplot(colom.ts, year.labels=FALSE, continuous=TRUE, polar = TRUE)+
  ggtitle("Seasonality through polarmap for Colombia")

ggseasonplot(aus.ts, year.labels=FALSE, continuous=TRUE, polar = TRUE)+
  ggtitle("Seasonality through polarmap for Australia")
#from the polar plot, all of them don't show the trend but show the strong seasonality


##Missing value check
sum(is.na(india.ts)) #33
sum(is.na(colom.ts)) #0
sum(is.na(aus.ts)) #4

##Outlier Check
tsoutliers(india.ts, lambda='auto') #298, 312...
tsoutliers(colom.ts, lambda='auto') #309
tsoutliers(aus.ts, lambda='auto') #372

#---Locating the troublemakers on a data-frame---#
Time.Stamp=seq(1,nrow(threecountry.ts),1)
e.india=cbind(Time.Stamp,india)
e.india

e.colom=cbind(Time.Stamp,colombia)
e.colom

e.aus=cbind(Time.Stamp,australia)
e.aus

#---Cleaning the data---#
clean.india=tsclean(india.ts, replace.missing = TRUE,lambda="auto")
clean.india

clean.colom=tsclean(colom.ts, replace.missing = TRUE,lambda="auto")
clean.colom

clean.aus=tsclean(aus.ts, replace.missing = TRUE,lambda="auto")
clean.aus

#---Comparing them side by side on a data-frame---#
cbind(Time.Stamp,india.ts,clean.india)
cbind(Time.Stamp,colom.ts,clean.colom)
cbind(Time.Stamp,aus.ts,clean.aus)

#---Comparing them on the same graph---#
autoplot(ts(cbind(india.ts,clean.india),start=c(1852,7),end=c(2013,8),frequency = 12))+
  ylab("Dirty and clean India time series")+ggtitle("Graph demonstrating data cleaning")

autoplot(ts(cbind(colom.ts,clean.colom),start=c(1852,7),end=c(2013,8), frequency = 12))+
  ylab("Dirty and clean Colombia time series")+ggtitle("Graph demonstrating data cleaning")

autoplot(ts(cbind(aus.ts,clean.aus),start=c(1852,7),end=c(2013,8),frequency = 12))+
  ylab("Dirty and clean Australia time series")+ggtitle("Graph demonstrating data cleaning")

##Classical Decomposition
india.decom=decompose(clean.india)
colom.decom=decompose(clean.colom)
aus.decom=decompose(clean.aus)

plot(india.decom)
plot(colom.decom)
plot(aus.decom)

##STL decomposition
india.stl=stl(clean.india, t.window = 5, s.window="periodic", robust=TRUE)
colom.stl=stl(clean.colom, t.window = 5, s.window="periodic", robust=TRUE)
aus.stl=stl(clean.aus, t.window = 5, s.window='periodic', robust=TRUE) 

autoplot(india.stl)+
  ggtitle("stl decomposition of India")
autoplot(colom.stl)+
  ggtitle("stl decomposition of Colombia")
autoplot(aus.stl)+
  ggtitle("stl decomposition of Australia")

##--Checking the strength of trend and seasonality
1-var(india.decom$random,na.rm=TRUE)/var((india.decom$trend+india.decom$random),na.rm=TRUE) #0.42
1-var(india.decom$random,na.rm=TRUE)/var((india.decom$seasonal+india.decom$random),na.rm=TRUE) #0.99

1-var(colom.decom$random,na.rm=TRUE)/var((colom.decom$trend+colom.decom$random),na.rm=TRUE) #0.77
1-var(colom.decom$random,na.rm=TRUE)/var((colom.decom$seasonal+colom.decom$random),na.rm=TRUE) #0.41

1-var(aus.decom$random,na.rm=TRUE)/var((aus.decom$trend+aus.decom$random),na.rm=TRUE) #0.36
1-var(aus.decom$random,na.rm=TRUE)/var((aus.decom$seasonal+aus.decom$random),na.rm=TRUE) #0.98
#the results verify my previous results from trend and polar plot

##Correlation Pattern
clean.threecountry=cbind(clean.india, clean.colom, clean.aus)
clean.threecountry
dissimilarity=diss(clean.threecountry,METHOD="COR") #the correlation method
dissimilarity

hc.dpred <- hclust(dissimilarity)
plot(hc.dpred,main="Cluster dendogram, Three Countries, Correlation distance")

##Euclidean Pattern: same result as above
dissimilarity2=diss(clean.threecountry,METHOD="EUCL")

hc.dpred2 <- hclust(dissimilarity2)
plot(hc.dpred2,main="Cluster dendogram, Three Countries, Euclidean distance")


##Entropy
SampEn(clean.india) #0.47
SampEn(clean.colom) #1.68
SampEn(clean.aus) #0.58


#############################################################
###Modeling
##train: everything prior to and including (1980,1)
train.usTS=window(clean.us, end=c(1980,1))
train.usTS

train.chinaTS=window(clean.china, end=c(1980,1))
train.chinaTS

train.ausTS=window(clean.aus, end=c(1980,1))
train.ausTS

##Nonlinearity Test
nonlinearityTest(train.usTS) #non-linearity
nonlinearityTest(train.chinaTS) #non-linearity
nonlinearityTest(train.ausTS) #non-linearity

##best ETS model
train.usTS.ets=ets(train.usTS) #ETS(A,N,A)
train.usTS.ets
checkresiduals(train.usTS.ets) #not good

train.chinaTS.ets=ets(train.chinaTS) #ETS(A,N,A)
train.chinaTS.ets
checkresiduals(train.chinaTS.ets) #not good

train.ausTS.ets=ets(train.ausTS) #ETS(A,N,A)
train.ausTS.ets
checkresiduals(train.ausTS.ets) #not good
#ETS model is not good fit


##ARIMA
#----Manually figuring out p and d---#
#the original time series is not stationary, so we use diff() to make it stationary (Yt)
ndiffs(train.usTS) #0, objective method to find d
ggPacf(train.usTS,lag.max = 40)+ggtitle("US, training, d=0 data PACF")

ndiffs(train.chinaTS) #0, objective method to find d
ggPacf(train.chinaTS,lag.max = 40)+ggtitle("China, training, d=0 data PACF")

ndiffs(train.ausTS) #0, objective method to find d
ggPacf(train.ausTS,lag.max = 40)+ggtitle("AUS, training, d=0 data PACF")

#--Automatic---#
auto.arima(train.usTS,D=NA, max.q = 0,max.P = 0,max.Q = 0,seasonal = F, stepwise = F,trace=T)
#ARIMA(3,0,0), p=3, d=0

auto.arima(train.chinaTS,D=NA, max.q = 0,max.P = 0,max.Q = 0,seasonal = F, stepwise = F,trace=T)
#ARIMA(2,0,0), p=2, d=0

auto.arima(train.ausTS,D=NA, max.q = 0,max.P = 0,max.Q = 0,seasonal = F, stepwise = F,trace=T)
#ARIMA(4,0,0), p=4, d=0

#----So let's fit an ARIMA---#
train.usTS.ari=Arima(train.usTS,c(3,0,0),include.drift = T)
train.usTS.ari #all parameters are significant

train.chinaTS.ari=Arima(train.chinaTS,c(2,0,0),include.drift = T)
train.chinaTS.ari #all parameters are significant

train.ausTS.ari=Arima(train.ausTS,c(4,0,0),include.drift = T)
train.ausTS.ari #ar2 is not significant

#---Graphic comparison----#
autoplot(train.usTS)+autolayer(fitted(train.usTS.ari))+autolayer(fitted(train.usTS.ets))+
  autolayer(forecast(train.usTS.ari))+autolayer(forecast(train.usTS.ets))+
  ggtitle("US, graphical comparisons between fitted models")

autoplot(train.chinaTS)+autolayer(fitted(train.chinaTS.ari))+autolayer(fitted(train.chinaTS.ets))+
  autolayer(forecast(train.chinaTS.ari))+autolayer(forecast(train.chinaTS.ets))+
  ggtitle("China, graphical comparisons between fitted models")

autoplot(train.ausTS)+autolayer(fitted(train.ausTS.ari))+autolayer(fitted(train.ausTS.ets))+
  autolayer(forecast(train.ausTS.ari))+autolayer(forecast(train.ausTS.ets))+
  ggtitle("Australia, graphical comparisons between fitted models")

#---Residual diagnostics---#
checkresiduals(train.usTS.ari) #not good

checkresiduals(train.chinaTS.ari) #not good

checkresiduals(train.ausTS.ari) #not good

#---Accuracy checking---#
#I don't need to transform the original time series indusTS, the function helps us do that automically
accuracy(forecast(train.usTS.ari),clean.us)
accuracy(forecast(train.usTS.ets),clean.us)
#ARI is better on MAPE

accuracy(forecast(train.chinaTS.ari),clean.china)
accuracy(forecast(train.chinaTS.ets),clean.china)
#ETS is better on both MAPE and MASE

accuracy(forecast(train.ausTS.ari),clean.aus)
accuracy(forecast(train.ausTS.ets),clean.aus)
#ETS is better on both MAPE and MASE


##Bagged Tree
us.bm=baggedModel(train.usTS, bootstrapped_series = bld.mbb.bootstrap(train.usTS, 15))
china.bm=baggedModel(train.chinaTS, bootstrapped_series = bld.mbb.bootstrap(train.chinaTS, 15))
aus.bm=baggedModel(train.ausTS, bootstrapped_series = bld.mbb.bootstrap(train.ausTS, 15))

#---Accuracy checking---#
accuracy(forecast(us.bm), clean.us)
accuracy(forecast(china.bm), clean.china)
accuracy(forecast(aus.bm), clean.aus)


##Neural Network
us.best.neural=nnetar(train.usTS)
china.best.neural=nnetar(train.chinaTS)
aus.best.neural=nnetar(train.ausTS)

#Accuracy checking
accuracy(forecast(us.best.neural), clean.us)
accuracy(forecast(china.best.neural), clean.china)
accuracy(forecast(aus.best.neural), clean.aus)


###Accuracy Comparison among All models
accuracy(forecast(train.usTS.ari),clean.us)
accuracy(forecast(train.usTS.ets),clean.us)
accuracy(forecast(us.bm), clean.us)
accuracy(forecast(us.best.neural), clean.us)
#MAPE: ARIMA, MASE: Bagged Tree

accuracy(forecast(train.chinaTS.ari),clean.china)
accuracy(forecast(train.chinaTS.ets),clean.china)
accuracy(forecast(china.bm), clean.china)
accuracy(forecast(china.best.neural), clean.china)
#MAPE&MASE: Bagged Tree 

accuracy(forecast(train.ausTS.ari),clean.aus)
accuracy(forecast(train.ausTS.ets),clean.aus)
accuracy(forecast(aus.bm), clean.aus)
accuracy(forecast(aus.best.neural), clean.aus)
#MAPE&MASE: ETS


