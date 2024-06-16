%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Step 2: Connectome FingerPrinting %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Here, we use the TRUE Individual Tau Connectome from ADNI as an example  

clear;
clc;
close all;

load( [ pwd, filesep, '..', filesep, 'NullPETData', filesep, 'Tau.mat' ] );

InputPath = [ pwd, filesep, '..', filesep, 'IndividualTauConnectome_ADNI' ];

%% Intra normal controls with amyloid positive
load( [ InputPath, filesep, 'IndividualTauConnectome_NC_AP.mat' ] );

ID = Tau.RID( IncludedScan_NC_AP );

ScanMask1 = find( ScanOrder_NC_AP == 1 );
ScanMask2 = find( ScanOrder_NC_AP == 2 );
[ Lia, Locb ] = ismember( ID( ScanMask1 ), ID( ScanMask2 ) );

Similarity = corr( IndividualTauConnectome_NC_AP( ScanMask1( Lia ), : )', IndividualTauConnectome_NC_AP( ScanMask2, : )' );

FP_NC_AP.Subjects = numel( ScanMask2 );
[ ~, Index1 ] = max( Similarity, [], 1 );
FP_NC_AP.Accuracy1 = sum( Index1 == 1:numel( Index1 ) )/numel( Index1 );
[ ~, Index2 ] = max( Similarity, [], 2 );
FP_NC_AP.Accuracy2 = sum( Index2' == 1:numel( Index2 ) )/numel( Index2 );

%% Intra MCI with amyloid positive
load( [ InputPath, filesep, 'IndividualTauConnectome_MCI_AP.mat' ] );

ID = Tau.RID( IncludedScan_MCI_AP );

ScanMask1 = find( ScanOrder_MCI_AP == 1 );
ScanMask2 = find( ScanOrder_MCI_AP == 2 );
[ Lia, Locb ] = ismember( ID( ScanMask1 ), ID( ScanMask2 ) );

Similarity = corr( IndividualTauConnectome_MCI_AP( ScanMask1( Lia ), : )', IndividualTauConnectome_MCI_AP( ScanMask2, : )' );

FP_MCI_AP.Subjects = numel( ScanMask2 );
[ ~, Index1 ] = max( Similarity, [], 1 );
FP_MCI_AP.Accuracy1 = sum( Index1 == 1:numel( Index1 ) )/numel( Index1 );
[ ~, Index2 ] = max( Similarity, [], 2 );
FP_MCI_AP.Accuracy2 = sum( Index2' == 1:numel( Index2 ) )/numel( Index2 );

%% Intra AD with amyloid positive
load( [ InputPath, filesep, 'IndividualTauConnectome_AD_AP.mat' ] );

ID = Tau.RID( IncludedScan_AD_AP );

ScanMask1 = find( ScanOrder_AD_AP == 1 );
ScanMask2 = find( ScanOrder_AD_AP == 2 );
[ Lia, Locb ] = ismember( ID( ScanMask1 ), ID( ScanMask2 ) );

Similarity = corr( IndividualTauConnectome_AD_AP( ScanMask1( Lia ), : )', IndividualTauConnectome_AD_AP( ScanMask2, : )' );

FP_AD_AP.Subjects = numel( ScanMask2 );
[ ~, Index1 ] = max( Similarity, [], 1 );
FP_AD_AP.Accuracy1 = sum( Index1 == 1:numel( Index1 ) )/numel( Index1 );
[ ~, Index2 ] = max( Similarity, [], 2 );
FP_AD_AP.Accuracy2 = sum( Index2' == 1:numel( Index2 ) )/numel( Index2 );

%% Accuracy
load( [ InputPath, filesep, 'ReferenceTauConnectome.mat' ], 'IncludedScan_Reference' );
Subjects = [ numel( IncludedScan_Reference ), FP_NC_AP.Subjects, FP_MCI_AP.Subjects, FP_AD_AP.Subjects ];
Accuracy = [ FP_NC_AP.Accuracy1, FP_MCI_AP.Accuracy1, FP_AD_AP.Accuracy1; ...
    FP_NC_AP.Accuracy2, FP_MCI_AP.Accuracy2, FP_AD_AP.Accuracy2 ];