# Regularized Regression
mock example for science forum


**glmnet** is R packeage written by Jerome Friedman, Trevor Hastie, Noah Simon, and Rob Tibshirani that allows for easy application of regularized generalized linear models to data.  

### Theoretical background on regularized regression and glmnet tutorials can be found below:
* [Ridge Regression: Biased Estimation for Nonorthogonal Problems](http://math.arizona.edu/~hzhang/math574m/Read/Ridge.pdf)  (Hoerl and Kennard 1970)
* [Regression Shrinkage and Selection via the Lasso](http://statweb.stanford.edu/~tibs/lasso/lasso.pdf) (Tibshirani 1996)
* Additional theoretical and intuition background available from [Elements of Statisitcal Learning](http://statweb.stanford.edu/~tibs/ElemStatLearn/) (Hastie, Tibshirani, and Friedman) and [Introduction to Statistical Learning](http://www-bcf.usc.edu/~gareth/ISL/ISLR%20Fourth%20Printing.pdf) (James, Witten, Hastie, and Tibshirani)
* [Lasso Lecture: Carnegie Mellon University](http://www.stat.cmu.edu/~ryantibs/datamining/lectures/17-modr2.pdf) (Ryan Tibshriani ) 
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
![lassobeta](https://cloud.githubusercontent.com/assets/10633220/10624126/8adef034-7763-11e5-91bc-95824916ed18.png)
* We want to choose the &#946;'s that minimize the above function. Notice if we set &#955;=0 then the estimate for &#946; is just standard OLS.  As &#955; approaches &#8734;, the estimate for the lasso &#946;=0.  &#955; is a known as the penalty or regularization parameter and is typically choosen by cross-validation.  
* Typically, the intercept is not penalized, so we have the below estimate for &#946;'s:
![lassointer](https://cloud.githubusercontent.com/assets/10633220/10641478/6c54deba-77e7-11e5-9e82-221b9ff8659f.png)
* The penalty term, ||&#946;||<sub>1</sub>, will cause predictions to be unfair if feature variables are not on the same scale.  Both ``` glmnet``` and ``` cv.glmnet``` functions in **glmnet** scale input features by default
