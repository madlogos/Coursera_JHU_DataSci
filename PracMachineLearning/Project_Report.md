# Model with Human Activity Recognition Data
`r Sys.info()[['user']]`  
`r Sys.time()`  

# Executive Summary

> Using devices such as _Jawbone Up_, _Nike FuelBand_, and _Fitbit_ it is now possible to collect a large amount of data about personal activity relatively inexpensively. These type of devices are part of the quantified self movement - a group of enthusiasts who take measurements about themselves regularly to improve their health, to find patterns in their behavior, or because they are tech geeks. One thing that people regularly do is quantify how __much__ of a particular activity they do, but they rarely quantify __how well they do it__. 

> The aim of this report was to use data from accelerometers placed on the belt, forearm, arm, and dumbell of six participants to predict how well they were doing the exercise in terms of the classification in the data. The data comes from the [Human Activity Recognition](http://groupware.les.inf.puc-rio.br/har) project.

Three different predicative machine learning methods (`pca`,`rf` and `rpart2`) were applied independently to yield predicative models. Finally random forest turned out to be the best. 

# Data Process

## Loading R packages
In this report, the R package `caret` was used. In order to make the report reproducible, the seed was set 12345 globally.


```r
sapply(c('caret','randomForest'),require,c=T)
```

```
## Loading required package: caret
## Loading required package: lattice
## Loading required package: ggplot2
## Loading required package: randomForest
## randomForest 4.6-10
## Type rfNews() to see new features/changes/bug fixes.
```

```r
knitr::opts_chunk$set(resutls='asis',dev='svg')
set.seed(12345)
```

## Loading Raw Data
Training (`pml-training.csv`) and test (`pml-testing.csv`) data were stored in two .csv files on Amazon's cloudfront. They were dowloaded to local folder using `download.file`.


```r
# download the files
url1 <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
download.file(url=url1,  destfile = "~/R/Work/pml-training.csv")
url2 <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"
download.file(url=url2, destfile = "~/R/Work/pml-testing.csv")
```

The training and test datasets were then loaded into R by `read.csv`.


```r
# read the csv file for training 
data_training <- read.csv("~/R/Work/pml-training.csv", na.strings= c("NA",""," "))
data_training$classe <- as.factor(data_training$classe)
# read the csv file for testing
data_testing <- read.csv("~/R/Work/pml-testing.csv", na.strings= c("NA",""," "))
```

## Pre-processing the Data

### Remove NAs
By `summary(data_training)`, we could discovery that there are a lot of NAs in the dataset, of which 160 variables have up to 98% NAs while the rest 60 ones have completely no NAs. NAs would create noise when fitting models. Here, I only kept the 60 variables without NAs. Plus, the first eight columns containing merely individuals' identifiers and timestamps were also removed. Thus we get a relatively clean dataset.


```r
data_training_NAs <- apply(data_training, 2, function(x) {sum(is.na(x))})
data_training_NApct <- 100 * round(data_training_NAs/nrow(data_training),3)
dt <- as.data.frame(table(data_training_NApct))
names(dt) <- c("Percent of NAs (%)","N of Variables")
knitr::kable(dt,format='markdown',caption="Variable Pattern: Percent of NAs")
```



|Percent of NAs (%) | N of Variables|
|:------------------|--------------:|
|0                  |             60|
|97.9               |            100|


```r
data_training_clean <- data_training[,which(data_training_NAs == 0)]
data_training_clean <- data_training_clean[,8:ncol(data_training_clean)]
```

### Remove Near-zero-variance Variables

Then Remove the variables with variance near zero, since near-zero-variance values have little meaning during prediction. This step retained all the variables selected above.


```r
nzv <- nearZeroVar(data_training_clean,saveMetrics=TRUE)
data_training_clean <- data_training_clean[,nzv$nzv==FALSE]
```

### Working Datasets
The clean training dataset was then splitted into training and cross validation datasets in a 3:1 ratio. So eventually we have 3 datasets:

- training set: to build predicative models (14718 rows)
- cross validation set: to validate the models (4904 rows)
- testing set: to test the model finally (20 rows)


```r
# split the cleaned testing data into training and cross validation
inTrain <- createDataPartition(y = data_training_clean$classe, p = 0.75, list = FALSE)
training <- data_training_clean[inTrain, ]
crossval <- data_training_clean[-inTrain, ]
```

# Predicative Models
## Fit 3 Models Independently
We built 3 models using principle components analysis (`pca`), random forest (`rf`), classification tree model (`rpart2`), respectively.


```r
model1 <- train(classe~.,data=training,method='knn',preProcess='pca')
model2 <- randomForest(classe~.,data=training)
model3 <- train(classe~.,data=training,method='rpart2')
save(model1,model2,model3,file="~/R/Work/predmodels.Rdata")
```




```r
bestModel <- function(model,method){
    modelResult <- model$results[order(model$results[,"Accuracy"],decreasing=TRUE),]
    return(data.frame(method=method,time=model$times$final[[3]],modelResult[1,2:5]))
}
df <- rbind(bestModel(model1,'pca'),bestModel(model2,'rf'),bestModel(model3,'rpart2'))
knitr::kable(df,format='markdown',caption='Comparison of accuracy of 3 models',
             row.names=FALSE)
```



|method |   time|  Accuracy|     Kappa| AccuracySD|   KappaSD|
|:------|------:|---------:|---------:|----------:|---------:|
|pca    |   1.31| 0.9365871| 0.9197317|  0.0037062| 0.0047197|
|rf     | 167.08| 0.9917791| 0.9896004|  0.0012550| 0.0015874|
|rpart2 |   1.05| 0.6417584| 0.5484273|  0.0230558| 0.0293272|

The training process showed that random forest is the most accurate predecative model in this case. Principle component analysis is also good and it took far less time to execute the predication. Classification tree model did not fit a well-performed model.

We will use random forest to perform cross-validation and testing.

## Cross-validation
Using random forest model, we got a promising cross validation result of 0.99 accuracy. The sensitivity, specificity and balanced accuracy rate are equally good across all the 5 classe levels. 


```r
# crossvalidate the model using the remaining 30% of data
predictCrossVal <- predict(model2, crossval)
confusionMatrix(crossval$classe, predictCrossVal)
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction    A    B    C    D    E
##          A 1394    1    0    0    0
##          B    9  938    2    0    0
##          C    0    3  852    0    0
##          D    0    0   10  794    0
##          E    0    0    0    3  898
## 
## Overall Statistics
##                                           
##                Accuracy : 0.9943          
##                  95% CI : (0.9918, 0.9962)
##     No Information Rate : 0.2861          
##     P-Value [Acc > NIR] : < 2.2e-16       
##                                           
##                   Kappa : 0.9928          
##  Mcnemar's Test P-Value : NA              
## 
## Statistics by Class:
## 
##                      Class: A Class: B Class: C Class: D Class: E
## Sensitivity            0.9936   0.9958   0.9861   0.9962   1.0000
## Specificity            0.9997   0.9972   0.9993   0.9976   0.9993
## Pos Pred Value         0.9993   0.9884   0.9965   0.9876   0.9967
## Neg Pred Value         0.9974   0.9990   0.9970   0.9993   1.0000
## Prevalence             0.2861   0.1921   0.1762   0.1625   0.1831
## Detection Rate         0.2843   0.1913   0.1737   0.1619   0.1831
## Detection Prevalence   0.2845   0.1935   0.1743   0.1639   0.1837
## Balanced Accuracy      0.9966   0.9965   0.9927   0.9969   0.9996
```

## Predictions
Kept the identical variables as training dataset in testing dataset.


```r
data_testing_clean <- data_testing[,which(names(data_testing) %in%
                                              names(data_training_clean))]
```

Now we can test the results using the testing dataset, applying random forest model we yielded from previous steps.


```r
# predict the classes of the test set
predictTest <- predict(model2, data_testing_clean)
predictTest
```

```
##  [1] B A B A A E D B A A B C B A E E A B B B
## Levels: A B C D E
```

## Output for submissions
Following the course instructions, the 20 output files are generated using codes below:


```r
pml_write_files = function(x){
  n = length(x)
  for(i in 1:n){
    filename = paste0("problem_id_",i,".txt")
    write.table(x[i],file=filename,quote=FALSE,row.names=FALSE,col.names=FALSE)
  }
}

pml_write_files(predictTest)
```

# Conclusions
Comparing the 3 predicative models of principle components analysis, random forest and classification tree, random forest is the best method. Based on `rf`, we are able to accurately predict how well a person is preforming an excercise. 
