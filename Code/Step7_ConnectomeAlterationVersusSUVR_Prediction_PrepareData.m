%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Step 7: Comparing the connectome alterations extent with SUVR %%%%%%
%%%%%%%%%%%%%% in predicting longitudinal cognitive decline %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Here, we use the TRUE Individual Tau Connectome from ADNI as an example 

clear;
clc;
close all;


OutputPath  = [ pwd, filesep, '..', filesep, 'ConnectomeAlterationPrediction' ];
mkdir( OutputPath )

load( [ pwd, filesep, '..', filesep, 'IndividualTauConnectome_ADNI', filesep, 'IndividualTauConnectome_AP.mat' ] );
load( [ pwd, filesep, '..', filesep, 'NullPETData', filesep, 'Tau.mat' ] );

Age_AP          = Tau.Age( IncludedScan_AP );
Sex_AP          = Tau.Sex( IncludedScan_AP );
Education_AP    = Tau.Education( IncludedScan_AP );
Dementia_AP     = GroupIndex_AP > 0.5;

csvwrite( [ OutputPath, filesep, 'ASED565x4.csv' ], [ Age_AP, Sex_AP, Education_AP, Dementia_AP ] );

%%
TauBraak_AP = load( [ pwd, filesep, '..', filesep, 'ConnectomeAlterationClassification', filesep, 'TauBraak565x3.csv' ] );
TauDDS_AP = load( [ pwd, filesep, '..', filesep, 'ConnectomeAlterationClassification', filesep, 'TauDDS565x5.csv' ] );
TauAlteration_AP = load( [ pwd, filesep, '..', filesep, 'ConnectomeAlterationClassification', filesep, 'TauAlteration565.csv' ] );

csvwrite( [ OutputPath, filesep, 'ASEDBraak565x7.csv' ], [ Age_AP, Sex_AP, Education_AP, Dementia_AP, TauBraak_AP ] );
csvwrite( [ OutputPath, filesep, 'ASEDDDS565x9.csv' ], [ Age_AP, Sex_AP, Education_AP, Dementia_AP, TauDDS_AP ] );
csvwrite( [ OutputPath, filesep, 'ASEDTauAlteration565x5.csv' ], [ Age_AP, Sex_AP, Education_AP, Dementia_AP, TauAlteration_AP ] );

%%
CognitionMeasurement = { 'CLOCKSCOR', 'ADASQ4', 'TRAASCOR', 'TRABSCOR', 'ADAS13' };
[ Lia, Locb ] = ismember( CognitionMeasurement, Tau.Neuropsy.Properties.VariableNames );

CognitionTable = table2array( Tau.Neuropsy( IncludedScan_AP, Locb ) );

for Measurement = 1:numel( CognitionMeasurement )
    Outlier = find( ( abs( CognitionTable( :, Measurement ) - nanmedian( CognitionTable( :, Measurement ) ) ) )/mad( CognitionTable( :, Measurement ) ) > 10 );
    CognitionTable( Outlier, Measurement ) = NaN;
end

csvwrite( [ OutputPath, filesep, 'Cognition565x5.csv' ], CognitionTable );

%%
mkdir( [ OutputPath, filesep, 'Sample' ] )

IncludedScan_Train = find( TimeLag_AP( :, 1 ) == 0 );
IncludedScan_Test = find( TimeLag_AP( :, 1 ) > 1 );

for Measurement = 1:numel( CognitionMeasurement )
    SampleTrain = find( ~isnan( CognitionTable( IncludedScan_Train, Measurement ) ) );
    SampleTest = find( ~isnan( CognitionTable( IncludedScan_Test, Measurement ) ) );
    
    csvwrite( [ OutputPath, filesep, 'Sample', filesep, 'SampleTrain_', num2str( Measurement, '%.2d' ), '.csv' ], IncludedScan_Train( SampleTrain ) );
    csvwrite( [ OutputPath, filesep, 'Sample', filesep, 'SampleTest_', num2str( Measurement, '%.2d' ), '.csv' ], IncludedScan_Test( SampleTest ) );
end