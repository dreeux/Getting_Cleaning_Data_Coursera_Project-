tra <- train[, feature.names]

split <- createDataPartition(y = train$TripType, p = 0.9, list = F) 

response_val <- train$TripType[-split]

response_train <- train$TripType[split]

dval <- xgb.DMatrix(data=data.matrix(tra[-split,]),  label = response_val )

dtrain <- xgb.DMatrix(data=data.matrix(tra[split,]), label = response_train)

watchlist <- list(val=dval, train=dtrain)

#basic training----------------------------------------------------------------------------------

numberOfClasses <- max(train$TripType) + 1

param <- list(objective = "multi:softprob",
              
              eval_metric = "mlogloss",
              
              num_class = numberOfClasses,
              
              nthreads = 4)
gc()

cl <- makeCluster(4); registerDoParallel(cl)

start <- Sys.time()

clf <- xgb.train(params = param, data = dtrain, nrounds = 50, watchlist = watchlist,
                 verbose = 1, maximize = T)

Time_Taken <- Sys.time() - start

##after 900 rounds it increases then falls off hd check it`s behaviour further

pred <- predict(clf, data.matrix(test[, feature.names])) 

pred <- matrix(pred, nrow=38, ncol=length(pred)/38) #there are total 38 classes 

pred = data.frame(t(pred))

sample <- read_csv('sample_submission.csv') 

cnames <- names(sample)[2:ncol(sample)] 

names(pred) <- cnames

submission <- cbind.data.frame(VisitNumber = test$VisitNumber, pred) 

submission <- setDT(submission)

submission <- (submission[ , lapply(.SD, harmonic.mean), by = VisitNumber])

#assuming you consolidated the data by visit number 

write_csv(submission, "D:/kaggle/walmart_seg/submission/1162015_2.csv")

##------------------------------------------------------------------------------------------------------------
cv.nround <- 5

cv.nfold <- 3

bst.cv = xgb.cv(param=param, data = dtrain, label = train$TripType, 
                
                nfold = cv.nfold, nrounds = cv.nround)
