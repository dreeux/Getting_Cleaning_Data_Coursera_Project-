#feature hashing

# didn`t show much of a difference in eval_metric for50 trees and default param

train_hash <- train

train_hash[is.na(train_hash)] <- 0

split <- createDataPartition(y = train_hash$TripType, p = 0.9, list = F) 

training <- train_hash[split,]

validation <- train_hash[-split,]

training_hash = hashed.model.matrix(~., data=training[,feature.names],  hash.size=2^16,  
                                    
                                    transpose=FALSE, create.mapping=TRUE, is.dgCMatrix = TRUE)

validation_hash = hashed.model.matrix(~., data=validation[,feature.names],  hash.size=2^16,  
                                      
                                      transpose=FALSE, create.mapping=TRUE, is.dgCMatrix = TRUE)

response_val <- train_hash$TripType[-split]

response_train <- train_hash$TripType[split]

dval <- xgb.DMatrix(data=validation_hash, label = response_val )

dtrain <- xgb.DMatrix(data=training_hash,  label = response_train)

watchlist <- list(val=dval, train=dtrain)

clf <- xgb.train(params = param, data = dtrain, nrounds = 500, watchlist = watchlist,
                 
                 verbose = 1, maximize = T)






#################################################################################################

#normal training method

feature.names <- names(train)[-179]

tra <- train[, feature.names]

split <- createDataPartition(y = train_raw$TripType, p = 0.9, list = F) 

response_val <- train_raw$TripType[-split]

response_train <- train_raw$TripType[split]

dval <- xgb.DMatrix( data = data.matrix(tra[-split,]),  label = response_val )

dtrain <- xgb.DMatrix( data = data.matrix(tra[split,]), label = response_train)

watchlist <- list(val=dval, train=dtrain)

#basic training----------------------------------------------------------------------------------

numberOfClasses <- max(train_raw$TripType) + 1

param <- list(objective = "multi:softprob",
              
              eval_metric = "mlogloss",
              
              num_class = numberOfClasses,
              
              max_depth = 12,
              
              eta = 0.01,
              
              colsample_bytree = 0.8,
              
              subsample = 0.8
              
              )

gc()


cl <- makeCluster(detectCores()); registerDoParallel(cl)


start <- Sys.time()

#############################################################################################################


clf <- xgb.train(params = param, data = dtrain, nrounds = 50, watchlist = watchlist,
                 
                 verbose = 1, maximize = T, nthread = 2)

time_taken <- Sys.time() - start

#############################################################################################################


#grid search

for (depth in c(9, 10, 8)) {
  
  for (rounds in c(2000, 3000)) {
    
    for(eta in c(0.3, 0.2, 0.1)){
      
      # train
      param <- list(objective = "multi:softprob",
                    
                    eval_metric = "mlogloss",
                    
                    num_class = numberOfClasses,
                    
                    max_depth = depth ,
                    
                    eta = eta
                    )
      
      
      clf <- xgb.train(params = param, data = dtrain, watchlist = watchlist, nrounds = rounds,
                       
                       verbose = 1, maximize = T, nthread = 2)
      gc()
      
      
      xgb.save(clf, paste0("clf", "_", rounds, "_",depth, "_", eta) )
      
      #scoring to be done -- issues with function scoring
      
    }     
  }
}  


Time_Taken <- Sys.time() - start


##after 900 rounds it increases then falls off check it`s behaviour further

# NOT USING THE SUBMISSION FUNCTION PRED FUNCTION FOR NOW 11-10-2015

#submit(clf, test, "1172015.csv")

pred <- predict(clf, data.matrix(test[, feature.names])) 

pred <- matrix(pred, nrow=38, ncol=length(pred)/38) #there are total 38 classes 

pred <-  data.frame(t(pred))

sample <- read_csv("D:/kaggle/walmart_seg/Data/sample_submission.csv") 

cnames <- names(sample)[2:ncol(sample)] 

names(pred) <- cnames

submission <- cbind.data.frame(VisitNumber = visit_num , pred) 

submission <- setDT(submission)

submission <- (submission[ , lapply(.SD, mean), by = VisitNumber])

write_csv(submission, "D:/kaggle/walmart_seg/submission/11102015.csv")

####################################################################################################################

#save and retrain model later

ptrain <- predict(clf, dtrain, outputmargin = T)

setinfo(dtrain, "base_margin", ptrain)

clf_extra <- xgboost(params = param, data = dtrain, nround = 1500)
