%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Step 4: Connectome Alteration Analysis at Baseline %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Here, we use the TRUE Individual Tau Connectome from ADNI as an example  

clear;
clc;
close all;

InputPath   = [ pwd, filesep, '..', filesep, 'IndividualTauConnectome_ADNI' ];
OutputPath  = [ pwd, filesep, '..', filesep, 'ConnectomeAlteration_Baseline' ];
mkdir( OutputPath )

load( [ InputPath, filesep, 'IndividualTauConnectome_AP.mat' ] );

GroupIndex_AP               = GroupIndex_AP( ScanOrder_AP == 1 );
IncludedScan_AP             = IncludedScan_AP( ScanOrder_AP == 1 );
IndividualTauConnectome_AP  = IndividualTauConnectome_AP( ScanOrder_AP == 1, : );

load( [ pwd, filesep, '..', filesep, 'ConnectomeClassification', filesep, 'TauConnectomeContribution.mat' ] );

Alterations = normalize( boxcox( sum( IndividualTauConnectome_AP.^2.*Contribution( ones( numel( IncludedScan_AP ), 1 ), : ), 2 ).^0.5 ), 'range' );

%% Kruskal Wallis tests

[ ~, tbl, ~ ]       = kruskalwallis( Alterations, GroupIndex_AP, 'off' );
KruskalWallis_Chi2  = tbl{ 2, 5 };
KruskalWallis_DF    = tbl{ 3, 3 };

N = 10000;
KruskalWallis_Chi2Null  = NaN( N, 1 );
for Counter = 1:N
    [ ~, Index ] = sort( rand( numel( GroupIndex_AP ), 1 ) );
    [ ~, tbl, ~ ] = kruskalwallis( Alterations, GroupIndex_AP( Index ), 'off' );
    KruskalWallis_Chi2Null( Counter, 1 ) = tbl{ 2, 5 };
end

KruskalWallis_P = sum( KruskalWallis_Chi2Null( :, 1 ) > KruskalWallis_Chi2( 1 ) )/N;

save( [ OutputPath, filesep, 'KruskalWallis.mat' ], 'KruskalWallis_Chi2', 'KruskalWallis_DF', 'KruskalWallis_Chi2Null', 'KruskalWallis_P' );

%% Wilcoxon rank-sum tests

P = NaN( 1, 3 );

Alterations_CN  = Alterations( GroupIndex_AP == 0 );
Alterations_MCI = Alterations( GroupIndex_AP == 1 );
Alterations_AD  = Alterations( GroupIndex_AP == 2 );

RankSum     = RankSumPermutation( Alterations_CN, Alterations_MCI );
P( 1, 1 )   = RankSum.P;
RankSum     = RankSumPermutation( Alterations_MCI, Alterations_AD );
P( 1, 2 )   = RankSum.P;
RankSum     = RankSumPermutation( Alterations_CN, Alterations_AD );
P( 1, 3 )   = RankSum.P;

%% Plot figure panel

load( 'Red5.txt' );

for Group = 0:2
    figure( 'Position', [ 0, 100, 360, 90 ] );
    raincloud_plot( Alterations( GroupIndex_AP == Group ), 'box_on', 1, 'color', Red5( Group + 3, : )/255, 'CloudRain', [ 0, 1 ] );
    colormap( KI( 255 ) );
    axis off;
    xlim( [ 0, 1 ] );
    set( gca,'Position', [ 0, 0, 1, 1 ] );
    saveas( gcf, [ OutputPath, filesep, 'Alterations', num2str( Group ), '.svg' ] );
end