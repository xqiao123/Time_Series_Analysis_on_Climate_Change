# Time Series Analysis on Climate Change
Eden Belay, Shakeeb Habash, Beza Lemma, Jiajia Liu, Xuefei Qiao, Kexuan Song


## Abstract
Climate change has been a controversial topic in many aspects, such as whether climate change is really happening and if so to what extent? Another question often posed is whether climate change is caused by a natural progression or is affected by human activity. With these questions in mind, we found a dataset containing monthly average land temperature at the global, country, state, and city level from 1750 to 2013. We conducted preliminary research and selected three representative countries - India, Colombia, Australia - and three representative states – California, New York, and Texas - as our study objects. Through time series analysis, we discovered that the average land temperature of all countries and states has been increasing over the past 250 years, but at a slow rate. We also compared the accuracy of ETS, ARIMA, neural network, and bagging models and selected the best candidate to forecast the average land temperature for those countries and states. In addition, we brought in a yearly 𝐶𝑂! and greenhouse gas emission dataset and found out that human activity may be positively correlated with the temperature increase.

*Index Terms: Temperature, ETS, ARIMA, neural network, bagging, emission*

##Introduction and Motivation
The purpose of this report is to forecast climate change. Hot days and heatwaves are becoming increasingly common in all geographical areas; 2020 was one of the warmest years on record. Temperature changes can also lead to increases in rainfall. As a result, storms become more severe and frequent and can damage land and human lives. More areas are experiencing water scarcity. Droughts can cause devastation by causing massive sand and dust storms that can move billions of tons of sand across continents. Predicting climate change will help us understand how climate is changing and will also be helpful to prepare for future natural disasters. Through the analysis of this paper, we will compare the trend and seasonality of three countries and three states. Then we will move on to build and compare several forecasting models. Lastly, we will also compare the greenhouse effect as it is related to global warming and climate change.

## The Data Set
Our global earth surface temperature data set contains monthly data on land average temperature, maximum temperature, minimum temperature, land and ocean average temperature between 1850 and 2015. In addition, we have separate temperature data sets on the country level and city level worldwide.

We will start with exploring global temperature change, then move on to several selected countries and cities. We also consider adding data sets of CO2/Green House Gas emissions, GDP by country in order to discover whether some of these factors have been contributing to climate change.

Furthermore, we’ll determine the training and test dataset for all countries with the window () function and do the test on our training datasets to see if they’re linear. If the test shows the linearity, we can use the training dataset to build stl, ETS, and ARIMA models to forecast values, otherwise, we’ll use neural network to forecast. Lastly, we’ll check the assumptions of all models and pick the winner for each country through some metrics on the test dataset, including MAPE, MASE, AIC, etc.

To better understand how the changes in temperature spread globally, instead of analyzing the global temperature as a whole, we intentionally select three coutries to represent different longitude and latitude combinations:
- India is located in both the Northern and Eastern hemispheres
- Colombia is located in both the Southern and Western hemispheres q Australia is located in both the Southern and Eastern hemispheres

In addition, we would like to further investigate how temperature changes within one country. Thus in this case, we select three states from different parts of the United States:
- New York State from the Northeast 
- California from the Southwest
- Texas from the South
