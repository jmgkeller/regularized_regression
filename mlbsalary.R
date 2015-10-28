fushia <- rgb(163,26,126, ,max=255) #Fushsia
teal <- rgb(0,155,116, max=255) # Teal
pumpkin <- rgb(225,112,0, max=255) # pumpkin
sage <- rgb(177,155,0, max=255) # sage

GLASS <- rgb(222,227,229, max=255)
SPACE <- rgb (76,72,69, max=255)
MAGENTA <- rgb(236,0,139, max=255)
ORANGE <- rgb(244,126,36, max=255)
YELLOW <- rgb(255,224,0, max=255)
GREEN <- rgb(0,174,93, max=255)
BLUE <- rgb(0,143,201, max=255)

print("The following 84.51 colors are available: GLASS, SPACE, MAGENTA, ORANGE, YELLOW, GREEN, BLUE. They are case sensative")
library(ISLR)

library(glmnet)
options(scipen=5)

### na.omit() function removes all of the rows that have missing values in any variable
### this is a simple example, so we fix the problem of missing data by deleting observations
### deleting observation due may be undesirable and simple and sophisticated data imputatation methods exist 
Hitters <- na.omit(Hitters)


### set seed and spilt data into training and testing sets
set.seed(21)
train_idx <- sample(1:nrow(Hitters),round(0.8 * nrow(Hitters), 0),replace=FALSE)
traindat <- Hitters[train_idx,]
testdat <- Hitters[-train_idx,]

### format test and training data to matrixdata because data must be in matrix format for glmnet
xtrain <- model.matrix(Salary ~., traindat )[,-1]
ytrain <- traindat$Salary

xtest <- model.matrix(Salary ~., testdat )[,-1]
ytest <- testdat$Salary

### lasso regression

### use glmnet's built-in k-fold cross-validation to tune lambda
lasso <- cv.glmnet(x = xtrain             # feature matrix
                   ,y = ytrain            # response vector
                   ,nfolds = 5            # folds for CV
                   ,lambda =              # path for lambda but we use the build in search for lambda provided by cv.glmnet
                   ,family = 'gaussian'   # error distribution (gaussian is linear regression, binomial is logistic, etc.)
                   ,alpha = 1)            # type of regularization. alpha=0 is ridge, alpha=1 is lasso, alpha between 0 and 1 is elastic net

### plot error curve across log(lambda)
plot(lasso)

### store the value of lambda that minimizes mse
lambda_min <- lasso$lambda.min
lambda_1se <- lasso$lambda.1se


### fit the lasso model to the training data using the 1se lambda
lasso_model <- glmnet(x = xtrain, y = ytrain, alpha = 1, family = 'gaussian', lambda = lambda_1se)
lasso_coef <- coef(lasso_model)


### apply lasso parameters to training dataset to get yhats
yhattrain <- predict(lasso_model, newx = xtrain, s = lambda_1se)

### Residual Scatterplot (Predicted vs Actual) for training data
lasso_pct_difference_train <- (yhattrain - ytrain) / ((yhattrain + ytrain / 2))
color_train <- rep("red", length(lasso_pct_difference_train))
color_train[lasso_pct_difference_train > -.255 & lasso_pct_difference_train < .255] <- "yellow"
color_train[lasso_pct_difference_train > -.055 & lasso_pct_difference_train < .055] <- "green"
plot(yhattrain, ytrain ,col=color_train)
abline(a = 0, b = 1)


length(lasso_pct_difference_train[lasso_pct_difference_train > -.055 & lasso_pct_difference_train < .055])/length(lasso_pct_difference_train)
length(lasso_pct_difference_train[lasso_pct_difference_train > -.15 & lasso_pct_difference_train < .15])/length(lasso_pct_difference_train)
length(lasso_pct_difference_train[lasso_pct_difference_train > -.255 & lasso_pct_difference_train < .255])/length(lasso_pct_difference_train)    
length(lasso_pct_difference_train[lasso_pct_difference_train > -.505 & lasso_pct_difference_train < .505])/length(lasso_pct_difference_train)    

### residual distribution for training data
plot(density(yhattrain - ytrain), main="Residual Distribution", yaxt="n", xlab="Predicted Salary - Actual Salary",
     ylab="", col=BLUE, lwd=3)
hist(yhattrain - ytrain)

### apply lasso parameters to test dataset to get yhats
yhattest <- predict(lasso_model, newx = xtest, s = lambda_1se)

### Residual Scatterplot (Predicted vs Actual) for test data
lasso_pct_difference_test <- (yhattest - ytest) / ((yhattest + ytest / 2))
color_train <- rep("red", length(lasso_pct_difference_test))
color_train[lasso_pct_difference_test > -.255 & lasso_pct_difference_test < .255] <- "yellow"
color_train[lasso_pct_difference_test > -.055 & lasso_pct_difference_test < .055] <- "green"
plot(yhattest, ytest ,col=color_train)
abline(a = 0, b = 1)


length(lasso_pct_difference_test[lasso_pct_difference_test > -.055 & lasso_pct_difference_test < .055])/length(lasso_pct_difference_test)
length(lasso_pct_difference_test[lasso_pct_difference_test > -.15 & lasso_pct_difference_test < .15])/length(lasso_pct_difference_test)
length(lasso_pct_difference_test[lasso_pct_difference_test > -.255 & lasso_pct_difference_test < .255])/length(lasso_pct_difference_test)    
length(lasso_pct_difference_test[lasso_pct_difference_test > -.505 & lasso_pct_difference_test < .505])/length(lasso_pct_difference_test)    

### residual distribution for test data
plot(density(yhattest - ytest), main="Residual Distribution", yaxt="n", xlab="Predicted Salary - Actual Salary",
     ylab="", col=BLUE, lwd=3)
