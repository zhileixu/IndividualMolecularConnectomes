require( xgboost )

GeneSpecificTranscriptionNetwork <- read.table( "YourPath/ConnectomeTranscriptome/GeneSpecificTranscriptionNetwork.csv", header = FALSE, sep = ',' )

InputPath <- "YourPath/ConnectomeTranscriptome"
SampleTrainTest <- read.table( paste( InputPath, "/Sample561TrainTest.csv", sep="" ), header = FALSE, sep = ',' )
Vulnerability561 <- read.table( paste( InputPath, "/Vulnerability561.csv", sep="" ), header = FALSE, sep = ',' )
	
CPU <- 32
Fold <- 10
Step <- 0.05

OutputPath <- paste( InputPath, "_FixedRef/CV", sprintf( "%02d", Fold ), "Fold", sep="" )
dir.create( OutputPath )

for( RandSeed in 1:200 )
{
	if( !file.exists( paste( OutputPath, "/Prediction", sprintf( "%04d", RandSeed ), ".txt", sep="" ) ) )
	{
		print( paste( "RandSeed:", sprintf( "%04d", RandSeed ) ) )
		
		TrainData <- xgb.DMatrix( as.matrix( GeneSpecificTranscriptionNetwork[ unlist( SampleTrainTest[ RandSeed, 1:500 ] ), ] ), label = as.matrix( Vulnerability561[ unlist( SampleTrainTest[ RandSeed, 1:500 ] ), ] ) )
		TestData <- xgb.DMatrix( as.matrix( GeneSpecificTranscriptionNetwork[ unlist( SampleTrainTest[ RandSeed, 501:561 ] ), ] ), label = as.matrix( Vulnerability561[ unlist( SampleTrainTest[ RandSeed, 501:561 ] ), ] ) )
		
		CVModel <- xgb.cv( data = TrainData, nrounds = 1500, nfold = Fold, early_stopping_rounds = 50, prediction = TRUE, eta = Step, objective = "reg:squarederror", nthread = CPU )
		write.table( CVModel$pred, file = paste( OutputPath, "/CV", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
		write.table( CVModel$best_iteration, file = paste( OutputPath, "/BestIteration", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )

		TrainModel <- xgboost( data = TrainData, nrounds = CVModel$best_iteration, eta = Step, objective = "reg:squarederror", nthread = CPU )
		Importance <- xgb.importance( model = TrainModel )
		write.table( Importance, file = paste( OutputPath, "/Importance", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )

		Prediction <- predict( TrainModel, TestData )
		write.table( Prediction, file = paste( OutputPath, "/Prediction", sprintf( "%04d", RandSeed ), ".txt", sep="" ), row.names = FALSE, col.names = FALSE, quote = FALSE )
	}
}