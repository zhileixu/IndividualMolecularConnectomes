require( xgboost )

InputPath <- "YourPath/ConnectomeClassification"
GroupIndex <- read.table( paste( InputPath, "/GroupIndex565.csv", sep="" ), header = FALSE, sep = ',' )
SampleTrainTest <- read.table( paste( InputPath, "/Sample565TrainTest.csv", sep="" ), header = FALSE, sep = ',' )

InputPath <- "YourPath/ConnectomeAlterationClassification"
TauBraak <- read.table( paste( InputPath, "/TauBraak565x3.csv", sep="" ), header = FALSE, sep = ',' )
TauDDS <- read.table( paste( InputPath, "/TauDDS565x5.csv", sep="" ), header = FALSE, sep = ',' )
TauAlteration <- read.table( paste( InputPath, "/TauAlteration565.csv", sep="" ), header = FALSE, sep = ',' )
	
CPU <- 16
Fold <- 10
Step <- 0.05

OutputPath <- paste( InputPath, "/CV", sprintf( "%02d", Fold ), "Fold", sep="" )
dir.create( OutputPath )

for( RandSeed in 1:1000 )
{
	for( Braak in 1:3 )
	{
		if( !file.exists( paste( OutputPath, "/Braak", sprintf( "%01d", Braak*2 - 1 ), "-Prediction01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ) ) )
		{
			TrainData <- xgb.DMatrix( as.matrix( TauBraak[ unlist( SampleTrainTest[ RandSeed, 1:200 ] ), Braak ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 1:200 ] ), ] ) )
			TestData <- xgb.DMatrix( as.matrix( TauBraak[ unlist( SampleTrainTest[ RandSeed, 301:540 ] ), Braak ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 301:540 ] ), ] ) )
		
			CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
			write.table( CVModel$pred, file = paste( OutputPath, "/Braak", sprintf( "%01d", Braak*2 - 1 ), "-CV01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
			write.table( CVModel$best_iteration, file = paste( OutputPath, "/Braak", sprintf( "%01d", Braak*2 - 1 ), "-BestIteration01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
			TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
			
			Prediction <- predict( TrainModel, TestData )
			write.table( Prediction, file = paste( OutputPath, "/Braak", sprintf( "%01d", Braak*2 - 1 ), "-Prediction01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		}
	
		if( !file.exists( paste( OutputPath, "/Braak", sprintf( "%01d", Braak*2 - 1 ), "-Prediction12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ) ) )
		{
			TrainData <- xgb.DMatrix( as.matrix( TauBraak[ unlist( SampleTrainTest[ RandSeed, 101:300 ] ), Braak ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 101:300 ] ), ] - 1 ) )
			TestData <- xgb.DMatrix( as.matrix( TauBraak[ unlist( SampleTrainTest[ RandSeed, 437:565 ] ), Braak ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 437:565 ] ), ] - 1 ) )
		
			CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
			write.table( CVModel$pred, file = paste( OutputPath, "/Braak", sprintf( "%01d", Braak*2 - 1 ), "-CV12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
			write.table( CVModel$best_iteration, file = paste( OutputPath, "/Braak", sprintf( "%01d", Braak*2 - 1 ), "-BestIteration12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
			TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
			
			Prediction <- predict( TrainModel, TestData )
			write.table( Prediction, file = paste( OutputPath, "/Braak", sprintf( "%01d", Braak*2 - 1 ), "-Prediction12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		}
	
		if( !file.exists( paste( OutputPath, "/Braak", sprintf( "%01d", Braak*2 - 1 ), "-Prediction02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ) ) )
		{
			TrainData <- xgb.DMatrix( as.matrix( TauBraak[ unlist( SampleTrainTest[ RandSeed, c( 1:100, 201:300 ) ] ), Braak ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, c( 1:100, 201:300 ) ] ), ]/2 ) )
			TestData <- xgb.DMatrix( as.matrix( TauBraak[ unlist( SampleTrainTest[ RandSeed, c( 301:436, 541:565 ) ] ), Braak ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, c( 301:436, 541:565 ) ] ), ]/2 ) )
		
			CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
			write.table( CVModel$pred, file = paste( OutputPath, "/Braak", sprintf( "%01d", Braak*2 - 1 ), "-CV02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
			write.table( CVModel$best_iteration, file = paste( OutputPath, "/Braak", sprintf( "%01d", Braak*2 - 1 ), "-BestIteration02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
			TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
			
			Prediction <- predict( TrainModel, TestData )
			write.table( Prediction, file = paste( OutputPath, "/Braak", sprintf( "%01d", Braak*2 - 1 ), "-Prediction02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		}
	}
	
	for( DDS in 1:5 )
	{
		if( !file.exists( paste( OutputPath, "/DDS", sprintf( "%01d", DDS ), "-Prediction01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ) ) )
		{
			TrainData <- xgb.DMatrix( as.matrix( TauDDS[ unlist( SampleTrainTest[ RandSeed, 1:200 ] ), DDS ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 1:200 ] ), ] ) )
			TestData <- xgb.DMatrix( as.matrix( TauDDS[ unlist( SampleTrainTest[ RandSeed, 301:540 ] ), DDS ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 301:540 ] ), ] ) )
		
			CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
			write.table( CVModel$pred, file = paste( OutputPath, "/DDS", sprintf( "%01d", DDS ), "-CV01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
			write.table( CVModel$best_iteration, file = paste( OutputPath, "/DDS", sprintf( "%01d", DDS ), "-BestIteration01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
			TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
			
			Prediction <- predict( TrainModel, TestData )
			write.table( Prediction, file = paste( OutputPath, "/DDS", sprintf( "%01d", DDS ), "-Prediction01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		}
	
		if( !file.exists( paste( OutputPath, "/DDS", sprintf( "%01d", DDS ), "-Prediction12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ) ) )
		{
			TrainData <- xgb.DMatrix( as.matrix( TauDDS[ unlist( SampleTrainTest[ RandSeed, 101:300 ] ), DDS ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 101:300 ] ), ] - 1 ) )
			TestData <- xgb.DMatrix( as.matrix( TauDDS[ unlist( SampleTrainTest[ RandSeed, 437:565 ] ), DDS ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 437:565 ] ), ] - 1 ) )
		
			CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
			write.table( CVModel$pred, file = paste( OutputPath, "/DDS", sprintf( "%01d", DDS ), "-CV12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
			write.table( CVModel$best_iteration, file = paste( OutputPath, "/DDS", sprintf( "%01d", DDS ), "-BestIteration12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
			TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
			
			Prediction <- predict( TrainModel, TestData )
			write.table( Prediction, file = paste( OutputPath, "/DDS", sprintf( "%01d", DDS ), "-Prediction12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		}
	
		if( !file.exists( paste( OutputPath, "/DDS", sprintf( "%01d", DDS ), "-Prediction02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ) ) )
		{
			TrainData <- xgb.DMatrix( as.matrix( TauDDS[ unlist( SampleTrainTest[ RandSeed, c( 1:100, 201:300 ) ] ), DDS ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, c( 1:100, 201:300 ) ] ), ]/2 ) )
			TestData <- xgb.DMatrix( as.matrix( TauDDS[ unlist( SampleTrainTest[ RandSeed, c( 301:436, 541:565 ) ] ), DDS ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, c( 301:436, 541:565 ) ] ), ]/2 ) )
		
			CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
			write.table( CVModel$pred, file = paste( OutputPath, "/DDS", sprintf( "%01d", DDS ), "-CV02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
			write.table( CVModel$best_iteration, file = paste( OutputPath, "/DDS", sprintf( "%01d", DDS ), "-BestIteration02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
			TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
			
			Prediction <- predict( TrainModel, TestData )
			write.table( Prediction, file = paste( OutputPath, "/DDS", sprintf( "%01d", DDS ), "-Prediction02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		}	
	}
	
	if( !file.exists( paste( OutputPath, "/Alteration-Prediction01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ) ) )
	{
		TrainData <- xgb.DMatrix( as.matrix( TauAlteration[ unlist( SampleTrainTest[ RandSeed, 1:200 ] ), ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 1:200 ] ), ] ) )
		TestData <- xgb.DMatrix( as.matrix( TauAlteration[ unlist( SampleTrainTest[ RandSeed, 301:540 ] ), ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 301:540 ] ), ] ) )
	
		CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
		write.table( CVModel$pred, file = paste( OutputPath, "/Alteration-CV01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		write.table( CVModel$best_iteration, file = paste( OutputPath, "/Alteration-BestIteration01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
		TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
		
		Prediction <- predict( TrainModel, TestData )
		write.table( Prediction, file = paste( OutputPath, "/Alteration-Prediction01-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	}
	
	if( !file.exists( paste( OutputPath, "/Alteration-Prediction12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ) ) )
	{
		TrainData <- xgb.DMatrix( as.matrix( TauAlteration[ unlist( SampleTrainTest[ RandSeed, 101:300 ] ), ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 101:300 ] ), ] - 1 ) )
		TestData <- xgb.DMatrix( as.matrix( TauAlteration[ unlist( SampleTrainTest[ RandSeed, 437:565 ] ), ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, 437:565 ] ), ] - 1 ) )
	
		CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
		write.table( CVModel$pred, file = paste( OutputPath, "/Alteration-CV12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		write.table( CVModel$best_iteration, file = paste( OutputPath, "/Alteration-BestIteration12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
		TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
		
		Prediction <- predict( TrainModel, TestData )
		write.table( Prediction, file = paste( OutputPath, "/Alteration-Prediction12-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	}
	
	if( !file.exists( paste( OutputPath, "/Alteration-Prediction02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ) ) )
	{
		TrainData <- xgb.DMatrix( as.matrix( TauAlteration[ unlist( SampleTrainTest[ RandSeed, c( 1:100, 201:300 ) ] ), ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, c( 1:100, 201:300 ) ] ), ]/2 ) )
		TestData <- xgb.DMatrix( as.matrix( TauAlteration[ unlist( SampleTrainTest[ RandSeed, c( 301:436, 541:565 ) ] ), ] ), label = as.matrix( GroupIndex[ unlist( SampleTrainTest[ RandSeed, c( 301:436, 541:565 ) ] ), ]/2 ) )
	
		CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
		write.table( CVModel$pred, file = paste( OutputPath, "/Alteration-CV02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		write.table( CVModel$best_iteration, file = paste( OutputPath, "/Alteration-BestIteration02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
		TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "binary:logistic", eval_metric = 'auc', nthread = CPU )
		
		Prediction <- predict( TrainModel, TestData )
		write.table( Prediction, file = paste( OutputPath, "/Alteration-Prediction02-", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	}
}