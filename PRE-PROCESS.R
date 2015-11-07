require(xgboost); require(readr); require(caret); require(doParallel); require(psych); require(FeatureHashing)

train <- read_csv("C:/Users/amulya/Documents/Kaggle/Walmart/train.csv")

test <- read_csv("C:/Users/amulya/Documents/Kaggle/Walmart/test.csv")

visit_num <- test$VisitNumber

feature.names <- names(train)[!names(train) %in% c("TripType")]

response <- names(train)[1]

response <- train[ , response] ; response <- as.numeric(response)

class_old <- sort(unique(response))

class_new <- seq(0, 37)

#replace elements of class_old with elements of class_new in response

for( i in 1:38 ){
  
  train$TripType[train$TripType == class_old[i]] <- class_new[i]
  
}

table(train$TripType)

#############################################################################################################


#very basic stuff--------------------------------------------------------------------------------

cat("assuming text variables are categorical & replacing them with numeric ids\n")

for (f in feature.names) {
  
  if (class(train[[f]])=="character") {
    
    levels <- unique(c(train[[f]], test[[f]]))
    
    train[[f]] <- as.integer(factor(train[[f]], levels=levels))
    
    test[[f]]  <- as.integer(factor(test[[f]],  levels=levels))
  }
}

train[is.na(train)] <- 0

test[is.na(test)] <- 0
