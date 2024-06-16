require( xgboost )

InputPath <- "YourPath/ConnectomeAlterationPrediction"

ASED <- read.table( paste( InputPath, "/ASED565x4.csv", sep="" ), header = FALSE, sep = ',' )
TauBraak <- read.table( paste( InputPath, "/ASEDBraak565x7.csv", sep="" ), header = FALSE, sep = ',' )
TauDDS <- read.table( paste( InputPath, "/ASEDDDS565x9.csv", sep="" ), header = FALSE, sep = ',' )
TauAlteration <- read.table( paste( InputPath, "/ASEDTauAlteration565x5.csv", sep="" ), header = FALSE, sep = ',' )
Cognition <- read.table( paste( InputPath, "/Cognition565x5.csv", sep="" ), header = FALSE, sep = ',' )

CPU <- 32
Fold <- 10
Step <- 0.05

OutputPath <- paste( InputPath, "/CV", sprintf( "%02d", Fold ), "Fold", sep="" )
dir.create( OutputPath )

OutputPathASED <- paste( OutputPath, "/ASED", sep="" )
OutputPathBraak <- paste( OutputPath, "/Braak", sep="" )
OutputPathBraak1 <- paste( OutputPath, "/Braak1", sep="" )
OutputPathBraak3 <- paste( OutputPath, "/Braak3", sep="" )
OutputPathBraak5 <- paste( OutputPath, "/Braak5", sep="" )
OutputPathDDS <- paste( OutputPath, "/DDS", sep="" )
OutputPathDDS1 <- paste( OutputPath, "/DDS1", sep="" )
OutputPathDDS2 <- paste( OutputPath, "/DDS2", sep="" )
OutputPathDDS3 <- paste( OutputPath, "/DDS3", sep="" )
OutputPathDDS4 <- paste( OutputPath, "/DDS4", sep="" )
OutputPathDDS5 <- paste( OutputPath, "/DDS5", sep="" )
OutputPathAlteration <- paste( OutputPath, "/Alteration", sep="" )
dir.create( OutputPathASED )
dir.create( OutputPathBraak1 )
dir.create( OutputPathBraak3 )
dir.create( OutputPathBraak5 )
dir.create( OutputPathDDS1 )
dir.create( OutputPathDDS2 )
dir.create( OutputPathDDS3 )
dir.create( OutputPathDDS4 )
dir.create( OutputPathDDS5 )
dir.create( OutputPathAlteration )

	
for( CognitionIndex in 1:5 )
{
	SampleTrain <- read.table( paste( InputPath, "/Sample/SampleTrain_", sprintf( "%02d", CognitionIndex ), ".csv", sep="" ), header = FALSE, sep = ',' )
	SampleTest <- read.table( paste( InputPath, "/Sample/SampleTest_", sprintf( "%02d", CognitionIndex ), ".csv", sep="" ), header = FALSE, sep = ',' )
	
	if( !file.exists( paste( OutputPathASED, "/Prediction", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ) ) )
	{
		TrainData <- xgb.DMatrix( as.matrix( ASED[ unlist( SampleTrain ), ] ), label = as.matrix( Cognition[ unlist( SampleTrain ), CognitionIndex ] ) )
	
		CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "reg:squarederror", nthread = CPU )
		write.table( CVModel$pred, file = paste( OutputPathASED, "/CV", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		write.table( CVModel$best_iteration, file = paste( OutputPathASED, "/BestIteration", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
		TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "reg:squarederror", nthread = CPU )
		Importance <- xgb.importance( model = TrainModel )
		write.table( Importance, file = paste( OutputPathASED, "/Importance", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
		TestData <- xgb.DMatrix( as.matrix( ASED[ unlist( SampleTest ), ] ), label = as.matrix( Cognition[ unlist( SampleTest ), CognitionIndex ] ) )
		Prediction <- predict( TrainModel, TestData )
		write.table( Prediction, file = paste( OutputPathASED, "/Prediction", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	}
	
	for( Braak in 1:3 )
	{
		if( !file.exists( paste( OutputPathBraak, sprintf( "%01d", Braak*2 - 1 ), "/Prediction", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ) ) )
		{
			TrainData <- xgb.DMatrix( as.matrix( TauBraak[ unlist( SampleTrain ), unlist( 1:4, 4 + Braak ) ] ), label = as.matrix( Cognition[ unlist( SampleTrain ), CognitionIndex ] ) )
	
			CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "reg:squarederror", nthread = CPU )
			write.table( CVModel$pred, file = paste( OutputPathBraak, sprintf( "%01d", Braak*2 - 1 ), "/CV", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
			write.table( CVModel$best_iteration, file = paste( OutputPathBraak, sprintf( "%01d", Braak*2 - 1 ), "/BestIteration", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
			TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "reg:squarederror", nthread = CPU )
			Importance <- xgb.importance( model = TrainModel )
			write.table( Importance, file = paste( OutputPathBraak, sprintf( "%01d", Braak*2 - 1 ), "/Importance", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
			TestData <- xgb.DMatrix( as.matrix( TauBraak[ unlist( SampleTest ), unlist( 1:4, 4 + Braak ) ] ), label = as.matrix( Cognition[ unlist( SampleTest ), CognitionIndex ] ) )
			Prediction <- predict( TrainModel, TestData )
			write.table( Prediction, file = paste( OutputPathBraak, sprintf( "%01d", Braak*2 - 1 ), "/Prediction", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		}
	}
		
	for( DDS in 1:5 )
	{
		if( !file.exists( paste( OutputPathDDS, sprintf( "%01d", DDS ), "/Prediction", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ) ) )
		{
			TrainData <- xgb.DMatrix( as.matrix( TauDDS[ unlist( SampleTrain ), unlist( 1:4, 4 + DDS ) ] ), label = as.matrix( Cognition[ unlist( SampleTrain ), CognitionIndex ] ) )
	
			CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "reg:squarederror", nthread = CPU )
			write.table( CVModel$pred, file = paste( OutputPathDDS, sprintf( "%01d", DDS ), "/CV", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
			write.table( CVModel$best_iteration, file = paste( OutputPathDDS, sprintf( "%01d", DDS ), "/BestIteration", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
			TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "reg:squarederror", nthread = CPU )
			Importance <- xgb.importance( model = TrainModel )
			write.table( Importance, file = paste( OutputPathDDS, sprintf( "%01d", DDS ), "/Importance", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
			TestData <- xgb.DMatrix( as.matrix( TauDDS[ unlist( SampleTest ), unlist( 1:4, 4 + DDS ) ] ), label = as.matrix( Cognition[ unlist( SampleTest ), CognitionIndex ] ) )
			Prediction <- predict( TrainModel, TestData )
			write.table( Prediction, file = paste( OutputPathDDS, sprintf( "%01d", DDS ), "/Prediction", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		}
	}
	
	if( !file.exists( paste( OutputPathAlteration, "/Prediction", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ) ) )
	{
		TrainData <- xgb.DMatrix( as.matrix( TauAlteration[ unlist( SampleTrain ),] ), label = as.matrix( Cognition[ unlist( SampleTrain ), CognitionIndex ] ) )
		
		CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "reg:squarederror", nthread = CPU )
		write.table( CVModel$pred, file = paste( OutputPathAlteration, "/CV", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		write.table( CVModel$best_iteration, file = paste( OutputPathAlteration, "/BestIteration", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
		TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "reg:squarederror", nthread = CPU )
		Importance <- xgb.importance( model = TrainModel )
		write.table( Importance, file = paste( OutputPathAlteration, "/Importance", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	
		TestData <- xgb.DMatrix( as.matrix( TauAlteration[ unlist( SampleTest ),] ), label = as.matrix( Cognition[ unlist( SampleTest ), CognitionIndex ] ) )
		Prediction <- predict( TrainModel, TestData )
		write.table( Prediction, file = paste( OutputPathAlteration, "/Prediction", sprintf( "%02d", CognitionIndex ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	}
}