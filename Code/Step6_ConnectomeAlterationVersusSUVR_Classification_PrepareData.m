%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Step 6: Comparing the connectome alterations extent with SUVR %%%%%%
%%%%%%%%%%%%% in discriminating different diagnostic groups %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Here, we use the TRUE Individual Tau Connectome from ADNI as an example 

clear;
clc;
close all;

OutputPath  = [ pwd, filesep, '..', filesep, 'ConnectomeAlterationClassification' ];
mkdir( OutputPath )

load( [ pwd, filesep, '..', filesep, 'IndividualTauConnectome_ADNI', filesep, 'IndividualTauConnectome_AP.mat' ] );

load( [ pwd, filesep, '..', filesep, 'NullPETData', filesep, 'Tau.mat' ] );
Tau_AP = Tau.SUVR( IncludedScan_AP, : );
Volume_AP = Tau.Volume( IncludedScan_AP, : );


BraakIndex = load(  [ pwd, filesep, '..', filesep, 'PredefinedStagingModels', filesep, 'DesikanKillianyBraakStaging.txt' ] );
BraakMask = NaN( 3, numel( BraakIndex ) );
BraakMask( 1, : ) = ( BraakIndex == 1 )|( BraakIndex == 2 );
BraakMask( 2, : ) = ( BraakIndex == 3 )|( BraakIndex == 4 );
BraakMask( 3, : ) = ( BraakIndex == 5 )|( BraakIndex == 6 );

Tau_Braak = zeros( numel( IncludedScan_AP ), 3 );
for BraakStage = 1:3
    Tau_Braak( :, BraakStage ) = sum( Tau_AP( :, BraakMask( BraakStage, : ) == 1 ).*...
        Volume_AP( :, BraakMask( BraakStage, : ) == 1 ), 2 )./sum( Volume_AP( :, BraakMask( BraakStage, : ) == 1 ), 2 );
end


DataDrivenIndex = load( [ pwd, filesep, '..', filesep, 'PredefinedStagingModels', filesep, 'DesikanKillianyRO948DDS.txt' ] );

Tau_DDS = zeros( numel( IncludedScan_AP ), 5 );
for DDS = 1:5
    Tau_DDS( :, DDS ) = sum( Tau_AP( :, DataDrivenIndex == DDS ).*...
        Volume_AP( :, DataDrivenIndex == DDS ), 2 )./sum( Volume_AP( :, DataDrivenIndex == DDS ), 2 );
end


load( [ pwd, filesep, '..', filesep, 'ConnectomeClassification', filesep, 'TauConnectomeContribution.mat' ] );

Alterations = normalize( boxcox( sum( IndividualTauConnectome_AP.^2.*Contribution( ones( numel( IncludedScan_AP ), 1 ), : ), 2 ).^0.5 ), 'range' );


csvwrite( [ OutputPath, filesep, 'TauBraak565x3.csv' ], Tau_Braak );
csvwrite( [ OutputPath, filesep, 'TauDDS565x5.csv' ], Tau_DDS );
csvwrite( [ OutputPath, filesep, 'TauAlteration565.csv' ], Alterations );