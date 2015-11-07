
#feature hashing

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
              
              nthreads = 4
              
              )
gc()

cl <- makeCluster(detectCores()); registerDoParallel(cl)

start <- Sys.time()

#############################################################################################################
  
clf <- xgb.train(params = param, data = dtrain, nrounds = 50, watchlist = watchlist,
                 
                 verbose = 1, maximize = T, early.stop.round = 50)

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
                    
                    eta = eta,
                    
                    nthreads = 4
                    
      )
      
      
      clf <- xgb.train(params = param, data = dtrain, watchlist = watchlist, nrounds = rounds,
                       
                       verbose = 1, maximize = T)
      gc()
      
      
      xgb.save(clf, paste0("clf", "_", rounds, "_",depth, "_", eta) )
      
      #scoring to be done -- issues with function scoring
      
    }     
  }
}  


Time_Taken <- Sys.time() - start


##after 900 rounds it increases then falls off hd check it`s behaviour further

submit(clf, test, "1172015.csv")
