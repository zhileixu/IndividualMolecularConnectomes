require( xgboost )

InputPath <- "YourPath/ConnectomeClassification"

IndividualTauConnectome <- read.table( paste( InputPath, "/IndividualTauConnectome565x2278.csv", sep="" ), header = FALSE, sep = ',' )
GroupIndex <- read.table( paste( InputPath, "/GroupIndex565.csv", sep="" ), header = FALSE, sep = ',' )
SampleTrainTest <- read.table( paste( InputPath, "/Sample565TrainTest.csv", sep="" ), header = FALSE, sep = ',' )
	
CPU <- 16
Fold <- 10
Step <- 0.05

OutputPath <- paste( InputPath, "/CV", sprintf( "%02d", Fold ), "Fold", sep="" )
dir.create( OutputPath )

for( RandSeed in 1:1000 )
{
	if( !file.exists( paste( OutputPath, "/Prediction", sprintf( "%04d", RandSeed ), ".txt", sep="" ) ) )
	{
		print( paste( "RandSeed:", sprintf( "%04d", RandSeed ) ) )
		
		TrainData <- xgb.DMatrix( as.matrix( IndividualTauConnectome[ unlist( SampleTrainTest[ RandSeed, 1:300 ] ), ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 1:300 ] ), ] ) )
		TestData <- xgb.DMatrix( as.matrix( IndividualTauConnectome[ unlist( SampleTrainTest[ RandSeed, 301:565 ] ), ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 301:565 ] ), ] ) )
		
		CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "multi:softprob", num_class = 3, eval_metric = 'auc', nthread = CPU )
		write.table( CVModel$pred, file = paste( OutputPath, "/CV", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		write.table( CVModel$best_iteration, file = paste( OutputPath, "/BestIteration", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
		TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "multi:softprob", num_class = 3, eval_metric = 'auc', nthread = CPU )
		Importance <- xgb.importance( model = TrainModel )
		write.table( Importance, file = paste( OutputPath, "/Importance", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
		Prediction <- predict( TrainModel, TestData )
		write.table( Prediction, file = paste( OutputPath, "/Prediction", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	}
	
	if( !file.exists( paste( OutputPath, "/Prediction01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ) ) )
	{
		print( paste( "RandSeed:", sprintf( "%04d", RandSeed ) ) )
		
		TrainData <- xgb.DMatrix( as.matrix( IndividualTauConnectome[ unlist( SampleTrainTest[ RandSeed, 1:200 ] ), ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 1:200 ] ), ] ) )
		TestData <- xgb.DMatrix( as.matrix( IndividualTauConnectome[ unlist( SampleTrainTest[ RandSeed, 301:540 ] ), ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 301:540 ] ), ] ) )
		
		CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
		write.table( CVModel$pred, file = paste( OutputPath, "/CV01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		write.table( CVModel$best_iteration, file = paste( OutputPath, "/BestIteration01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
		TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
		Importance <- xgb.importance( model = TrainModel )
		write.table( Importance, file = paste( OutputPath, "/Importance01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
		Prediction <- predict( TrainModel, TestData )
		write.table( Prediction, file = paste( OutputPath, "/Prediction01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	}
	
	if( !file.exists( paste( OutputPath, "/Prediction12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ) ) )
	{
		print( paste( "RandSeed:", sprintf( "%04d", RandSeed ) ) )
		
		TrainData <- xgb.DMatrix( as.matrix( IndividualTauConnectome[ unlist( SampleTrainTest[ RandSeed, 101:300 ] ), ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 101:300 ] ), ] ) - 1 )
		TestData <- xgb.DMatrix( as.matrix( IndividualTauConnectome[ unlist( SampleTrainTest[ RandSeed, 437:565 ] ), ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 437:565 ] ), ] ) - 1 )
		
		CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
		write.table( CVModel$pred, file = paste( OutputPath, "/CV12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		write.table( CVModel$best_iteration, file = paste( OutputPath, "/BestIteration12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
		TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
		Importance <- xgb.importance( model = TrainModel )
		write.table( Importance, file = paste( OutputPath, "/Importance12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
		Prediction <- predict( TrainModel, TestData )
		write.table( Prediction, file = paste( OutputPath, "/Prediction12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	}
	
	if( !file.exists( paste( OutputPath, "/Prediction02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ) ) )
	{
		print( paste( "RandSeed:", sprintf( "%04d", RandSeed ) ) )
		
		TrainData <- xgb.DMatrix( as.matrix( IndividualTauConnectome[ unlist( SampleTrainTest[ RandSeed, c( 1:100, 201:300 ) ] ), ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, c( 1:100, 201:300 ) ] ), ] )/2 )
		TestData <- xgb.DMatrix( as.matrix( IndividualTauConnectome[ unlist( SampleTrainTest[ RandSeed, c( 301:436, 541:565 ) ] ), ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, c( 301:436, 541:565 ) ] ), ] )/2 )
		
		CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
		write.table( CVModel$pred, file = paste( OutputPath, "/CV02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		write.table( CVModel$best_iteration, file = paste( OutputPath, "/BestIteration02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
		TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
		Importance <- xgb.importance( model = TrainModel )
		write.table( Importance, file = paste( OutputPath, "/Importance02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
		Prediction <- predict( TrainModel, TestData )
		write.table( Prediction, file = paste( OutputPath, "/Prediction02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	}
}
