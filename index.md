This page created to be in one hand of my homeworks, tasks and projects about Time Series Analysis, Data Mining etc.

Please also note that, This works sorted by chronologically so the works done in the beginning are more inexperienced .

Below you can see my works classied with respect to courses.

## IE360 Time Series Analysis

### HW1 Basic Data Visualization

In this work, we  import some datasets from Turkish Central Bank's database and from Google Trends. 
And then, visualize it with simple plot functions to see how it behave and try to do little analysis about the data.

You can find [Task Description](https://github.com/SinaOzturk/Projects/blob/main/IE360_Statistical_Forecasting_and_Time_Series/HW1/IE%20360%20HW1.pdf), [Report](IE360_Statistical_Forecasting_and_Time_Series/HW1/IE360_HW1_Markdown_Report.html) and [Code](https://github.com/SinaOzturk/Projects/blob/main/IE360_Statistical_Forecasting_and_Time_Series/HW1/IE%20360%20HW1%20R%20Script.R) by click into.

### HW2 Simple Forecast for CPI by using Linear Regression

In this work, we import some general data of Turkish economy such as consumer price index and USD/TRY ratio and try to fit a model using such variables for CPI of Footwear and Clothing Category.
We start with simple models, and continue with adding seasonality, different datasets, lags etc. Finally, we had a nice prediction for the test set with our final linear regression model.

You can find [Task Description](https://github.com/SinaOzturk/Projects/blob/main/IE360_Statistical_Forecasting_and_Time_Series/HW2/IE%20360%20HW2.pdf), [Report](IE360_Statistical_Forecasting_and_Time_Series/HW2/IE360_HW2_Mardown_Report.html), and [Code](https://github.com/SinaOzturk/Projects/blob/main/IE360_Statistical_Forecasting_and_Time_Series/HW2/IE%20360%20HW2%20R%20Script.R) by click into.

### HW3 Forecasting approach to hourly electricty consumption in Turkey by using ARIMA models

In this work, since electricity consumption is very seasonal data, first we start to understand in which time intervals we have seasonality with decompose the data. After understand the seasonality characteristic of the data, we start to fit a model with AR, MA, ARIMA and paramater tuning. After finding the best model, we forecast for the next 2 weeks. At the end, we calculate errors and discussed what can be done for the next steps.

You can find [Task Description](https://github.com/SinaOzturk/Projects/blob/main/IE360_Statistical_Forecasting_and_Time_Series/HW3/IE360%20HW3.pdf), [Report](IE360_Statistical_Forecasting_and_Time_Series/HW3/IE360_HW3_Markdown_Report.html), and [Code](https://github.com/SinaOzturk/Projects/blob/main/IE360_Statistical_Forecasting_and_Time_Series/HW3/IE360%20HW3%20R%20Script.R) by click into.

### Project Forecasting approach to sales of several products in one of the main e-commerce website in Turkey 

In this work, we had 9 different products' sales data for 1  year and some additional data that can be useful for modelling such as category visits. We investigate different forecasting techniques and following models were implemented: Multiple Linear Regression, ARIMAX and ARIMA. Because each product has different characterisctics with respect to consumption behaviour and seasonality, different models are used for each product.
IF we talk briefly about the model selection, if the product has a lot of missing data, we used linear regression because ARIMA or ARIMAX models could not usable if data has a big period of missing data. ARIMA or ARIMAX models selected for the products that has more data then the others. You can find the results and future work can be done in the report. It was very joyful and educative project for us because handling with real time data and see the results of your work motivate me and my team members. 

You can find [Task Description](https://github.com/SinaOzturk/Projects/blob/main/IE360_Statistical_Forecasting_and_Time_Series/Project/IE%20360%20Project.pdf) and [Report](IE360_Statistical_Forecasting_and_Time_Series/Project/FinalProjectReport.html). You also can find the links for codes of prediction modelling is at the end of the report.

### HW4 Application of ARIMA and ARIMAX techniques for the e-commerce sales of specific products

This task is a detailed work for what we have done in the project. We simply apply ARIMA or ARIMAX models to each product and see the prediction results. Basically we have done decompose data, detect trend and seasonality. See some plots to understand the data such as using ACF and PACF pilots to see the correlation between lags etc. And then, determine ARIMA or ARIMAX models are suitable for that product.

You can find [Task Description](https://github.com/SinaOzturk/Projects/blob/main/IE360_Statistical_Forecasting_and_Time_Series/HW4/IE360%20HW4.pdf), and [Report](IE360_Statistical_Forecasting_and_Time_Series/HW4/IE360_HW4_Markdown_Report.html) by click into.


## IE425 Data Mining

### HW1 Introduction to Data Mining (Rpart and Tree Package)

In this work, we start how the data science steps are taken such as spliting train and test sets for built-in datasets R included itself. Afterwards, we continue with creating `rpart` tree for specific parameters and see the error rates. Afterwards, we have done cross validation to find the best tree and make the predictions. 
Also, I have created another tree with using `tree` package and followed same steps and compare the results and saw which package give better results.

You can find [Task Description](https://github.com/SinaOzturk/Projects/blob/main/IE425_Data_Mining/HW1/IE425%20HW1.pdf), [Report](IE425_Data_Mining/HW1/IE425_HW1_Markdown_Report.html) and [Code](https://github.com/SinaOzturk/Projects/blob/main/IE425_Data_Mining/HW1/IE%20425%20HW1%20R%20Script.R) by click into.

### HW2 Dealing with Parameter Tuning (k-fold Cross-Validation and Gradient Boosting Machines)

In this work, I practised parameter tuning. After splitting dataset to train and test sets, I used `k-fold cross-validation` approach. Because there was plenty of parameters, I deal with parameter tuning a lot. In the second part of the task, I used `Gradient Boosting Machine` for the same dataset and play with paramaters to find the best model.

You can find [Task Description](https://github.com/SinaOzturk/Projects/blob/main/IE425_Data_Mining/HW2/IE452%20HW2.pdf), [Report](IE425_Data_Mining/HW2/IE452_HW2_Markdown_Report.html) and [Code](https://github.com/SinaOzturk/Projects/blob/main/IE425_Data_Mining/HW2/IE452%20HW2%20R%20Script.R) by click into.

### Project (Kaggle Competition with my Classmates in one of the famous Data Set in Kaggle)

In this work, we have dataset of Kobe Bryant's statistics in his games. There were plenty of statistics about his shots' performance such as distance, location and time of the shots that he take.  
First we start with simple `logistic regression` because we try to predict that the shot will be point or not. We start with very simple models and add variables one by one. Afterwards, we model `Gradient Boosting Machines`, with doing some parameter tuning. Compare the logistic regression and GBM models and make our predictions with using our Final GBM Model.
In the Kaggle results, we were in the second position before teh evaluation phase but unfortunately we ended up at sixth place after all the data included in final phase of the competition.

You can find [Report](IE425_Data_Mining/Project/IE425_Project_Markdown_Report.html) and [Code](https://github.com/SinaOzturk/Projects/blob/main/IE425_Data_Mining/Project/IE425%20Project%20R%20Script.R) by click into.

## IE48B Special Topic in Time Series Analysis

### HW1 Data Representation Techniques and Clustering with Autoregressive Models

In this task, I have a dataset which represents gesture recognition of, let's say a phone, the data is a time series and there is 3 variable x,y and z coordinates and these are the locations. My first task is visualize the data. I have try to take the cumulative sum of the data with respect to time to get speed in a way and visualize it. It worked somehow that task description says. Second task is represent the data in a different way and with using autoregressive modeling try to detect which class does it look like.

You can find [Task Description](https://github.com/SinaOzturk/Projects/blob/main/IE48B_Special_Topic_in_Time_Series_Analysis/HW1/IE48B%20HW1.pdf), and [Jupyter Notebook](IE48B_Special_Topic_in_Time_Series_Analysis/HW1/IE48B_HW1_Jupyter_Notebook_Report.html) by click into.

### HW3 Comparison of different distance measures with using different time series representations for different data sets

In this task, we try to represent our 5 different data sets with `Piecewise Aggregate Approximation` and `Symbolic Aggregate Approximation (SAX)`. Also I have used 4 different distance measure. Those are `Euclidian Distance`, `Dynamic Time Warping (DTW)`, `LCSS` and `ERP`.
After represent my data with different representation techniques using different distance measurement, I have done `Cross Validation` to classify my data. And compare the representation and distance measurements with respect to which representation worked better.

You can find [Task Description](https://github.com/SinaOzturk/Projects/blob/main/IE48B_Special_Topic_in_Time_Series_Analysis/HW3/IE48B%20HW3.pdf), [Report](IE48B_Special_Topic_in_Time_Series_Analysis/HW3/IE48B_HW3_Markdown_Report.html) and [Code](https://github.com/SinaOzturk/Projects/blob/main/IE48B_Special_Topic_in_Time_Series_Analysis/HW3/IE48B%20HW3%20R%20Script.R) by click into.

### Project Predcition of Sign of the difference between the total volume of the Down and Up Instructions in Turkish Electricity Market

In Turkish electricity market, the prediction of the sign of difference between the volume of up and down instruciton play an important role because electirciy supplier has to take some actions with respect to this sign. 
We have had historical data of the market with some additional variables that could be useful. We start with linear regression model to fit in our training set and use `Regression Tree Based Approach (EBLR)` order to improve the model. Also we represent to do classification `Piecewise Aggregate Approximation` and `Symbolic Aggregate Appriximation (SAX)` and different distance measurements. 
With those representations, we predict the system sign with our improved model.

You can find [Task description](https://github.com/SinaOzturk/Projects/blob/main/IE48B_Special_Topic_in_Time_Series_Analysis/Project/IE48B%20Project.pdf), [Report](IE48B_Special_Topic_in_Time_Series_Analysis/Project/IE48B_Project_Markdown_Report.html) and [Code](https://github.com/SinaOzturk/Projects/blob/main/IE48B_Special_Topic_in_Time_Series_Analysis/Project/Project_Report.ipynb)  by click into.

## IE440 Non Linear Models in Operations Research

In this course, we learnt how to find global minima or maxima in nonlinear models with lenty of methods. The reason I put this course in this page is because we learnt at teh end of the course how to build a neural network. 
Therefore, I just want to mention about all the works I have done in this course but the main work is project.

In the first task, I have applied `bisection`, `golden-section`, `newton's` and `secant` methods to find global optima. You can find the [Task Description](https://github.com/SinaOzturk/Projects/blob/main/IE440_Nonlinear_Models_in_Operations_Research/HW1/IE440%20HW1.pdf) and [Report](IE440_Nonlinear_Models_in_Operations_Research/HW1/IE440_HW1_Jupyter_Notebook_Report.html) by click into.

In the second task, I solved `multi-facility weber problem` with using `Weiszfeld's Algorithm` and `Alternative Location - Allocation (ALA) Heuristic` method and compare the results of the algortihms. You can find [Task Description](https://github.com/SinaOzturk/Projects/blob/main/IE440_Nonlinear_Models_in_Operations_Research/HW2/IE440%20HW2.pdf) and [Report](IE440_Nonlinear_Models_in_Operations_Research/HW2/IE440_HW2_Jupyter_Notebook_Report.html) by click into. 

In the third task, I tried to find the global optima for a specific nonlinear function  with using `Cyclic Coordinate Search`, `Hook & Jeeves Method` and `Simplex Search` algorithms. You can find [Task Description](https://github.com/SinaOzturk/Projects/blob/main/IE440_Nonlinear_Models_in_Operations_Research/HW3/IE440%20HW3.pdf) and [Report](IE440_Nonlinear_Models_in_Operations_Research/HW3/IE440_HW3_Jupyter_Notebook_Report.html) by click into. 

In the fourth task, I tried to find the global optima for a specific nonlinear function with using `Steepest Descent Method`, `Newton’s Method (with exact line search)`, `DFP (Davidon - Fletcher - Powell) Method` and `BFGS (Broyden - Fletcher - Goldfarb - Shanno) Method`. You can find [Task Description](https://github.com/SinaOzturk/Projects/blob/main/IE440_Nonlinear_Models_in_Operations_Research/HW4/IE440%20HW4.pdf) and [Report](IE440_Nonlinear_Models_in_Operations_Research/HW4/IE440_HW4_Jupyter_Notebook_Report.html) by click into.

### Project Comparison of A Neural Network with other Methods

In the first part of the project, I tried to find local minima with `Least Square Method`, and `DFP Method` that I created already in previous tasks. 
In the second part of the project, I built a neural network that has one output unit, two-four input terminals and one hidden layer with given activation factor. 
And we compared results of the methods and neural networks with each other.

You can find [Task Description](https://github.com/SinaOzturk/Projects/blob/main/IE440_Nonlinear_Models_in_Operations_Research/Project/IE440%20Project.pdf) and [Report](IE440_Nonlinear_Models_in_Operations_Research/Project/IE440_Project_Jupyter_Notebook_Report.html) by click into.

## IE492 Graduation Project

In this project we try to find a state-of-art method that predict short-term wind turbines electricity production.

We have the spatio-temporal data from Numerical Weather Prediction (NWP) model. The data include longitude, latitude, altitude and time at the same time and have U and V vectors of wind.
Our first task is to built base line models to compare our final model with them. 
We start with Principal Component Analysis, Gaussian Process Regression and Lasso Regression as base line models.
In the second part of the project, we will built physics-oriented neural networks model to predict the production. 
Because the work is not finished, I am not able to show the works we have done. 