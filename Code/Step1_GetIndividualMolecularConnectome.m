%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% Step 1: Get Individual Molecular Connectome %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Here, we use the NULL Tau-PET as an example  

clear;
clc;
close all;

OutputPath = [ pwd, filesep, '..', filesep, 'NullIndividualConnectome' ];
mkdir( OutputPath );

load( [ pwd, filesep, '..', filesep, 'NullPETData', filesep, 'Tau.mat' ] );
Tau.Tau = [ Tau.SUVR_LH, Tau.SUVR_RH ];

%% Get Included PET Scans
IncludedScan = find( ( ~isnan( Tau.AmyloidGroup ) )&( ~isnan( Tau.Group ) )&...
    ( ~isnan( Tau.Age ) )&( ~isnan( Tau.Sex ) )&( ~isnan( Tau.Education ) ) );

IncludedScan_NC_AN  = IncludedScan( ( Tau.AmyloidGroup( IncludedScan ) == 0 )&( Tau.Group( IncludedScan ) == 0 ) );
IncludedScan_NC_AP  = IncludedScan( ( Tau.AmyloidGroup( IncludedScan ) == 1 )&( Tau.Group( IncludedScan ) == 0 ) );
IncludedScan_MCI_AP = IncludedScan( ( Tau.AmyloidGroup( IncludedScan ) == 1 )&( Tau.Group( IncludedScan ) == 1 ) );
IncludedScan_AD_AP  = IncludedScan( ( Tau.AmyloidGroup( IncludedScan ) == 1 )&( Tau.Group( IncludedScan ) == 2 ) );

IncludedScan_AP = [ IncludedScan_NC_AP; IncludedScan_MCI_AP; IncludedScan_AD_AP ];
Tau_AP          = Tau.Tau( IncludedScan_AP, : );
Age_AP          = Tau.Age( IncludedScan_AP );
Sex_AP          = Tau.Sex( IncludedScan_AP );
Education_AP    = Tau.Education( IncludedScan_AP );
GroupIndex_AP   = [ zeros( numel( IncludedScan_NC_AP ), 1 ); ...
    zeros( numel( IncludedScan_MCI_AP ), 1 ) + 1; ...
    zeros( numel( IncludedScan_AD_AP ), 1 ) + 2 ];

[ ScanOrder_NC_AN, TimeLag_NC_AN, FirstScanAge_NC_AN ]      = GetScanOrder( Tau.RID( IncludedScan_NC_AN ), Tau.ScanDate( IncludedScan_NC_AN ), Tau.Age( IncludedScan_NC_AN ) );
[ ScanOrder_NC_AP, TimeLag_NC_AP, FirstScanAge_NC_AP ]      = GetScanOrder( Tau.RID( IncludedScan_NC_AP ), Tau.ScanDate( IncludedScan_NC_AP ), Tau.Age( IncludedScan_NC_AP ) );
[ ScanOrder_MCI_AP, TimeLag_MCI_AP, FirstScanAge_MCI_AP ]   = GetScanOrder( Tau.RID( IncludedScan_MCI_AP ), Tau.ScanDate( IncludedScan_MCI_AP ), Tau.Age( IncludedScan_MCI_AP ) );
[ ScanOrder_AD_AP, TimeLag_AD_AP, FirstScanAge_AD_AP ]      = GetScanOrder( Tau.RID( IncludedScan_AD_AP ), Tau.ScanDate( IncludedScan_AD_AP ), Tau.Age( IncludedScan_AD_AP ) );

ScanOrder_AP    = [ ScanOrder_NC_AP; ScanOrder_MCI_AP; ScanOrder_AD_AP ];
TimeLag_AP      = [ TimeLag_NC_AP; TimeLag_MCI_AP; TimeLag_AD_AP ];
FirstScanAge_AP = [ FirstScanAge_NC_AP; FirstScanAge_MCI_AP; FirstScanAge_AD_AP ];

%% Get Reference Tau Connectome
IncludedScan_Reference  = IncludedScan_NC_AN( ScanOrder_NC_AN == 1 );
Tau_Reference           = Tau.Tau( IncludedScan_Reference, : );
Age_Reference           = Tau.Age( IncludedScan_Reference );
Sex_Reference           = Tau.Sex( IncludedScan_Reference );
Education_Reference     = Tau.Education( IncludedScan_Reference );

ReferenceTauConnectome = partialcorr( Tau_Reference, [ Age_Reference - mean( Age_Reference ), ...
    Sex_Reference, Education_Reference - mean( Education_Reference ) ] );
DiagMask = diag( ones( numel( Tau_Reference( 1, : ) ), 1 ) );

save( [ OutputPath, filesep, 'ReferenceTauConnectome.mat' ], 'IncludedScan_Reference', 'ReferenceTauConnectome', 'DiagMask' );

%% Get Individual Tau Connectome
% These connectome matrices will be used in baseline analysis.

IndividualTauConnectome_AP = NaN( numel( IncludedScan_AP ), numel( squareform( ReferenceTauConnectome - DiagMask ) ) );
for Scan = 1:numel( IncludedScan_AP )
    PerturbedTauConnectome =  partialcorr( [ Tau_Reference; Tau_AP( Scan, : ) ], ...
        [ [ Age_Reference; Age_AP( Scan ) ] - mean( Age_Reference ), ...
        [ Sex_Reference; Sex_AP( Scan ) ], ...
        [ Education_Reference; Education_AP( Scan ) ] - mean( Education_Reference ) ] );
    IndividualTauConnectome_AP( Scan, : ) = squareform( PerturbedTauConnectome - ReferenceTauConnectome )...
        ./squareform( 1 - ReferenceTauConnectome.^2 )*( numel( IncludedScan_Reference ) - 1 );
end

IndividualTauConnectome_NC_AP   = IndividualTauConnectome_AP( GroupIndex_AP == 0, : );
IndividualTauConnectome_MCI_AP  = IndividualTauConnectome_AP( GroupIndex_AP == 1, : );
IndividualTauConnectome_AD_AP   = IndividualTauConnectome_AP( GroupIndex_AP == 2, : );

save( [ OutputPath, filesep, 'IndividualTauConnectome_AP.mat' ], 'IncludedScan_AP', 'IndividualTauConnectome_AP', 'ScanOrder_AP', 'TimeLag_AP', 'GroupIndex_AP' );
save( [ OutputPath, filesep, 'IndividualTauConnectome_NC_AP.mat' ], 'IncludedScan_NC_AP', 'IndividualTauConnectome_NC_AP', 'ScanOrder_NC_AP', 'TimeLag_NC_AP' );
save( [ OutputPath, filesep, 'IndividualTauConnectome_MCI_AP.mat' ], 'IncludedScan_MCI_AP', 'IndividualTauConnectome_MCI_AP', 'ScanOrder_MCI_AP', 'TimeLag_MCI_AP' );
save( [ OutputPath, filesep, 'IndividualTauConnectome_AD_AP.mat' ], 'IncludedScan_AD_AP', 'IndividualTauConnectome_AD_AP', 'ScanOrder_AD_AP', 'TimeLag_AD_AP' );

%% Get Individual Tau Connectome Using FirstScanAge
% These connectome matrices will be used in longitudinal analysis.

IndividualTauConnectome_AP = NaN( numel( IncludedScan_AP ), numel( squareform( ReferenceTauConnectome - DiagMask ) ) );
for Scan = 1:numel( IncludedScan_AP )
    PerturbedTauConnectome =  partialcorr( [ Tau_Reference; Tau_AP( Scan, : ) ], ...
        [ [ Age_Reference; FirstScanAge_AP( Scan ) ] - mean( Age_Reference ), ...
        [ Sex_Reference; Sex_AP( Scan ) ], ...
        [ Education_Reference; Education_AP( Scan ) ] - mean( Education_Reference ) ] );
    IndividualTauConnectome_AP( Scan, : ) = squareform( PerturbedTauConnectome - ReferenceTauConnectome )...
        ./squareform( 1 - ReferenceTauConnectome.^2 )*( numel( IncludedScan_Reference ) - 1 );
end

IndividualTauConnectome_NC_AP   = IndividualTauConnectome_AP( GroupIndex_AP == 0, : );
IndividualTauConnectome_MCI_AP  = IndividualTauConnectome_AP( GroupIndex_AP == 1, : );
IndividualTauConnectome_AD_AP   = IndividualTauConnectome_AP( GroupIndex_AP == 2, : );

save( [ OutputPath, filesep, 'IndividualTauConnectomeUsingFirstScanAge_AP.mat' ], 'IncludedScan_AP', 'IndividualTauConnectome_AP', 'ScanOrder_AP', 'TimeLag_AP', 'GroupIndex_AP' );
save( [ OutputPath, filesep, 'IndividualTauConnectomeUsingFirstScanAge_NC_AP.mat' ], 'IncludedScan_NC_AP', 'IndividualTauConnectome_NC_AP', 'ScanOrder_NC_AP', 'TimeLag_NC_AP' );
save( [ OutputPath, filesep, 'IndividualTauConnectomeUsingFirstScanAge_MCI_AP.mat' ], 'IncludedScan_MCI_AP', 'IndividualTauConnectome_MCI_AP', 'ScanOrder_MCI_AP', 'TimeLag_MCI_AP' );
save( [ OutputPath, filesep, 'IndividualTauConnectomeUsingFirstScanAge_AD_AP.mat' ], 'IncludedScan_AD_AP', 'IndividualTauConnectome_AD_AP', 'ScanOrder_AD_AP', 'TimeLag_AD_AP' );