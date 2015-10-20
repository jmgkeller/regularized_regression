# Regularized Regression
mock example for science forum


**glmnet** is R packeage written by Jerome Friedman, Trevor Hastie, Noah Simon, and Rob Tibshirani that allows for easy application of regularized generalized linear models to data.  

### Theoretical background on regularized regression and glmnet tutorials can be found below:
* [Ridge Regression: Biased Estimation for Nonorthogonal Problems](http://math.arizona.edu/~hzhang/math574m/Read/Ridge.pdf)  (Hoerl and Kennard 1970)
* [Regression Shrinkage and Selection via the Lasso](http://statweb.stanford.edu/~tibs/lasso/lasso.pdf) (Tibshirani 1996)
* Additional theoretical and intuition background available from [Elements of Statisitcal Learning](http://statweb.stanford.edu/~tibs/ElemStatLearn/) (Hastie, Tibshirani, and Friedman) and [Introduction to Statistical Learning](http://www-bcf.usc.edu/~gareth/ISL/ISLR%20Fourth%20Printing.pdf) (James, Witten, Hastie, and Tibshirani) 
* **glmnet** tutorial [glmnet Vignette](https://web.stanford.edu/~hastie/glmnet/glmnet_alpha.html) (Hastie and Qian) 

### Using lasso regression to predict baseball salaries
#### Data
* We will use a small data set avaialbe in CRAN to try to predict MLB salaries.  You can access the data through R by installing the Introduction to Statisitcal Learning data package (ISLR) and then loading the ISLR library
```s
install.packages("ISLR")
library(ISLR)
```
* We will preform minimal data preprocessing.  There are 59 player with missing salaries, so we will simply remove observations with missing salary or have missing values in any variable using the [na.omit()](http://www.inside-r.org/r-doc/stats/na.fail) function
```s
Hitters <- na.omit(Hitters)
```
* Before modeling, check summary statistics, scatter plots and correlation between independent and dependent variablies and among dependent variables 
* Although not preformed in this demo, it is generally a good idea explore how transforming and interacting features may improve your model
* Split data into training and test sets so you can determine if the resulting model output will generalize well
```s
set.seed(21)
train_idx <- sample(1:nrow(Hitters),round(0.8 * nrow(Hitters), 0),replace=FALSE)
traindat <- Hitters[train_idx,]
testdat <- Hitters[-train_idx,]
```
### Methodology
* We are using linear lasso regression regression to predict MLB player salary from individual player characteristics.  The obbjective function for lasso regression is below:
![lasso_form](https://cloud.githubusercontent.com/assets/10633220/10622472/d3b6c952-7755-11e5-9b59-5e02e49ff5fb.png)
* Notice the first bit of the objective function is just standard OLS. Lambda is a penalty parameter choosen by cross-validation.  As Lambda increases coefficents are shrunken towards zero.

