# Regularized Regression
mock example for science forum


**glmnet** is R packeage written by Jerome Friedman, Trevor Hastie, Noah Simon, and Rob Tibshirani that allows for easy application of regularized generalized linear models to data.  

### Theoretical background on regularized regression and glmnet tutorials can be found below:
* [Ridge Regression: Biased Estimation for Nonorthogonal Problems](http://math.arizona.edu/~hzhang/math574m/Read/Ridge.pdf)  (Hoerl and Kennard 1970)
* [Regression Shrinkage and Selection via the Lasso](http://statweb.stanford.edu/~tibs/lasso/lasso.pdf) (Tibshirani 1996)
* Additional theoretical and intuition background available from [Elements of Statisitcal Learning](http://statweb.stanford.edu/~tibs/ElemStatLearn/) (Hastie, Tibshirani, and Friedman) and [Introduction to Statistical Learning](http://www-bcf.usc.edu/~gareth/ISL/ISLR%20Fourth%20Printing.pdf) (James, Witten, Hastie, and Tibshirani)
* [Ridge Lecture: Carnegie Mellon University](http://www.stat.cmu.edu/~ryantibs/datamining/lectures/16-modr1-marked.pdf) and [Lasso Lecture: Carnegie Mellon University](http://www.stat.cmu.edu/~ryantibs/datamining/lectures/17-modr2.pdf) (Ryan Tibshriani) 
* **glmnet** tutorial [glmnet Vignette](https://web.stanford.edu/~hastie/glmnet/glmnet_alpha.html) (Hastie and Qian) 

### Using lasso regression to predict baseball salaries
#### Data
* We will use a small data set avaialbe in CRAN to try to predict log MLB salaries.  You can access the data through R by installing the Introduction to Statisitcal Learning data package (ISLR) and then loading the ISLR library
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
* Split data into training and test sets so you can determine if the resulting model output will generalize well.  Below, I use 80% of the original data set to train and the other 20% of the orininal data set to test.
```s
set.seed(21)
train_idx <- sample(1:nrow(Hitters),round(0.8 * nrow(Hitters), 0),replace=FALSE)
traindat <- Hitters[train_idx,]
testdat <- Hitters[-train_idx,]
```
* To use ```glmnet``` functions, **data must be in matrix format**. Below is how I converted the training and test data sets created above from data frames to matrices: 
```s
xtrain <- model.matrix(Salary ~., traindat )[,-1]
ytrain <- log(traindat$Salary)

xtest <- model.matrix(Salary ~., testdat )[,-1]
ytest <- log(testdat$Salary)
```
### Methodology
* We are using linear lasso regression regression to predict log MLB player salary from individual player characteristics.  The obbjective function for lasso regression is below:
![lassobeta](https://cloud.githubusercontent.com/assets/10633220/10624126/8adef034-7763-11e5-91bc-95824916ed18.png)
* We want to choose the &#946;'s that minimize the above function. Notice if we set &#955;=0 then the estimate for &#946; is just standard OLS.  As &#955; &#8594; &#8734;, the estimate for the lasso &#946;=0.  &#955; is a known as the penalty or regularization parameter and is typically choosen by cross-validation.  
* Typically, the intercept is not penalized, so we have the below estimate for &#946;'s:
![lassointer](https://cloud.githubusercontent.com/assets/10633220/10641478/6c54deba-77e7-11e5-9e82-221b9ff8659f.png)
* The penalty term, ||&#946;||<sub>1</sub>, will cause predictions to be unfair if feature variables are not on the same scale.  Both ``` glmnet``` and ``` cv.glmnet``` functions in **glmnet** scale input features by default
* In the predicting MLB player salary, I use a naive lasso regression.  I pluck player salary and make it the dependent variable and use the rest of the variables as features to predict player salary.  
* I rely on the lasso subsetting property to preform automatic variable selection.  To understand how the lasso preforms variable selection, considered the following constrained optimization problem:
![laasoconopt](https://cloud.githubusercontent.com/assets/10633220/10644493/0a1c3800-77f7-11e5-8d29-d6fec2125957.png)
* In a simple two diminsion case, we can view the problem geometrically as
![geographiclasso](https://cloud.githubusercontent.com/assets/10633220/10644667/e0693638-77f7-11e5-8d6a-eed9a830922d.png)
* The blue diamond is the constraint region |&#946;|<sub>1</sub> + |&#946;|<sub>2</sub> &#8804; t, where t is the regularization parameter (previously &#955;).  The red elispes are countours of the least squares loss function.  Each ellipse has a constant residual sum of squares.   As the ellipses expand away from the least squares coefficient estimates, the residual sum of squares increases.  The lasso objective function is minimized at the point where the red ellispe touches the blue diamond (i.e., the smallest residual sum of squares subject to the regularization parameter).  Because of the shape of the blue diamond constraint, often the minimal residual sum of squares will satisfy the regularization constraint at a corner, resulting in one coefficient esimate being set to 0.

### Results 
* Below is the **R** code used to search &#955; values using cross-validation to find the &#955; that minimizies MSE within the specified regression model.  In this case we are regressing the 19 features in the set: AtBat, Hits, HmRun, Runs, RBI, Walks, Years, CAtBat, CHits, CHmRun, CRuns, CRBI, CWalks, League, Division, PutOuts, Assists, Errors, Salary, and NewLeague on log MLB player salary
```s
### use glmnet's built-in k-fold cross-validation to tune lambda
set.seed(22)
lasso <- cv.glmnet(x = xtrain            # feature matrix
                  ,y = ytrain            # response vector
                  ,nfolds = 5            # folds for CV
                  ,lambda =              # path for lambda but we use the build in search for lambda provided by cv.glmnet
                  ,family = 'gaussian'   # error distribution (gaussian is linear regression, binomial is logistic, etc.)
                  ,alpha = 1)            # type of regularization. alpha=0 is ridge, alpha=1 is lasso, alpha between 0 and 1 is elastic net
```
* We can visually inspect the relationship between log(&#955;) and MSE by using the ```plot(lasso)``` function
![lambdamin](https://cloud.githubusercontent.com/assets/10633220/10830793/0ce66468-7e58-11e5-934c-b9375fd5125e.png)

* The vertical line at log(&#955;) approximately -5 is the &#955; value that minimizing mean squared error and the vertical line at log(&#955;) approximately -2 is the &#955; value that minimizes MSE plus 1 standard deviation.  Below are the outputed coeficients from glmnet.  The coefficients on the left are produced by using &#955;<sub>min</sub> and the coefficients on the right are produced using &#955;<sub>1se</sub>.  I used the &#955;<sub>1se</sub> because a larger &#955; produces a more simple model.  To show that &#955;<sub>1se</sub> produces a more simple model than &#955;<sub>min</sub> we can fit two lasso models using the same independent and dependent variables and use different values for &#955;.  Looking at the charts below, it is clear that the lasso using &#955;<sub>1se</sub> has fewer coefficents.
```s
### fit the lasso model to the training data using the min lambda and the 1se lambda
### lambda min
lasso_model_min <- glmnet(x = xtrain, y = ytrain, alpha = 1, family = 'gaussian', lambda = lambda_min)
### get the lasso coefficients using lambda min
lasso_coef <- coef(lasso_model_min)
### lambda 1se
lasso_model <- glmnet(x = xtrain, y = ytrain, alpha = 1, family = 'gaussian', lambda = lambda_1se)
### get the lasso coefficients using lambda 1se
lasso_coef <- coef(lasso_model)
```
<img width="548" alt="minvs1se" src="https://cloud.githubusercontent.com/assets/10633220/10793629/12089eb6-7d68-11e5-9467-ef020f084cae.png">

* I used the ```predict()``` function to get the training predictions:
```s 
### apply lasso parameters to test dataset to get yhats
yhattest <- predict(lasso_model, newx = xtest, s = lambda_1se)
```
* Taking a look at the predicted vs actuals scatter plot can give us an idea of model performance.   I calculated the % difference between the training predictions and the actual values for log MLB player salary. I then used the % diffence values to color predicted vs actual scatter plot values to differentiate pairs that are within 5%, within 15%, and greater than 15%:
```s
### Residual Scatterplot (Predicted vs Actual) for training data
lasso_pct_difference_train <- (yhattrain - ytrain) / ((yhattrain + ytrain / 2))
color_train <- rep("dark red", length(lasso_pct_difference_train))
color_train[lasso_pct_difference_train > -.155 & lasso_pct_difference_train < .155] <- "dark orange"
color_train[lasso_pct_difference_train > -.055 & lasso_pct_difference_train < .055] <- "dark green"
plot(yhattrain, ytrain ,col=color_train, main = "Training: Predicted vs Actuals")
abline(a = 0, b = 1)
legend("bottomright",c("Witin 5%", "Within 15%", "> 15%"), col=c("dark green", "dark orange", "dark red"),lty=1, lwd=4)
```
![trainpva](https://cloud.githubusercontent.com/assets/10633220/10830188/b5272af8-7e54-11e5-9173-960c240530a6.png)

* I repeat the same process with the test data:
```s
### apply lasso parameters to test dataset to get yhats
yhattest <- predict(lasso_model, newx = xtest, s = lambda_1se)

### Residual Scatterplot (Predicted vs Actual) for test data
lasso_pct_difference_test <- (yhattest - ytest) / ((yhattest + ytest / 2))
color_train <- rep("dark red", length(lasso_pct_difference_test))
color_train[lasso_pct_difference_test > -.155 & lasso_pct_difference_test < .155] <- "dark orange"
color_train[lasso_pct_difference_test > -.055 & lasso_pct_difference_test < .055] <- "dark green"
plot(yhattest, ytest ,col=color_train, main = "Test: Predicted vs Actuals")
abline(a = 0, b = 1)
legend("bottomright",c("Witin 5%", "Within 15%", "> 15%"), col=c("dark green", "dark orange", "dark red"),lty=1, lwd=4)
```
![testpva](https://cloud.githubusercontent.com/assets/10633220/10830155/85179f3c-7e54-11e5-8781-d252fb5332d0.png)

* Training residual distribution for the &#955;<sub>1se</sub> lasso regression model

![trainresiddist](https://cloud.githubusercontent.com/assets/10633220/10796913/9eefbf2c-7d76-11e5-839a-4d0aeaafe3a3.png)

* Test residual distribution for the &#955;<sub>1se</sub> lasso regression model

![testresiddist](https://cloud.githubusercontent.com/assets/10633220/10796973/d8696208-7d76-11e5-87e4-518ef7ecf1df.png)
