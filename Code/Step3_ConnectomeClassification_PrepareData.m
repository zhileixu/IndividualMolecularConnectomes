%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Step 3: Discriminating different diagnostic groups %%%%%%%%%%%%
%%%%%%%%%%%%%%%%% using individual molecular connectomes %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Here, we use the TRUE Individual Tau Connectome from ADNI as an example  

clear;
clc;
close all;


OutputPath  = [ pwd, filesep, '..', filesep, 'ConnectomeClassification' ];
mkdir( OutputPath )

load( [ pwd, filesep, '..', filesep, 'IndividualTauConnectome_ADNI', filesep, 'IndividualTauConnectome_AP.mat' ] );
csvwrite( [ OutputPath, filesep, 'IndividualTauConnectome565x2278.csv' ], IndividualTauConnectome_AP );
csvwrite( [ OutputPath, filesep, 'GroupIndex565.csv' ], GroupIndex_AP );


N = 1000;
[ ~, Sample565TrainTest0 ] = sort( rand( N, sum( GroupIndex_AP == 0 ) ), 2 );
[ ~, Sample565TrainTest1 ] = sort( rand( N, sum( GroupIndex_AP == 1 ) ), 2 );
[ ~, Sample565TrainTest2 ] = sort( rand( N, sum( GroupIndex_AP == 2 ) ), 2 );

Sample565TrainTest = [ Sample565TrainTest0( :, 1:100 ), ...
    sum( GroupIndex_AP == 0 ) + Sample565TrainTest1( :, 1:100 ), ...
    sum( GroupIndex_AP == 0 ) + sum( GroupIndex_AP == 1 ) + Sample565TrainTest2( :, 1:100 ), ...
    Sample565TrainTest0( :, 101:end ), ...
    sum( GroupIndex_AP == 0 ) + Sample565TrainTest1( :, 101:end ), ...
    sum( GroupIndex_AP == 0 ) + sum( GroupIndex_AP == 1 ) + Sample565TrainTest2( :, 101:end ) ];

csvwrite( [ OutputPath, filesep, 'Sample565TrainTest.csv' ], Sample565TrainTest );