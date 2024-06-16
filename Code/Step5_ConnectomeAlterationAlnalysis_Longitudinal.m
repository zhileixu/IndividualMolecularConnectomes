%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Step 5: Connectome Alteration Analysis in Longitudinal %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Here, we use the TRUE Individual Tau Connectome from ADNI as an example 

clear;
clc;
close all;

InputPath   = [ pwd, filesep, '..', filesep, 'IndividualTauConnectome_ADNI' ];
OutputPath  = [ pwd, filesep, '..', filesep, 'ConnectomeAlteration_Longitudinal' ];
mkdir( OutputPath )

load( [ InputPath, filesep, 'IndividualTauConnectomeUsingFirstScanAge_AP.mat' ] );

load( [ pwd, filesep, '..', filesep, 'ConnectomeClassification', filesep, 'TauConnectomeContribution.mat' ] );

Alterations = normalize( boxcox( sum( IndividualTauConnectome_AP.^2.*Contribution( ones( numel( IncludedScan_AP ), 1 ), : ), 2 ).^0.5 ), 'range' );

%% Connectome Alteration Analysis in Longitudinal

load( 'Red5.txt' );
load( [ pwd, filesep, '..', filesep, 'NullPETData', filesep, 'Tau.mat' ] );

TimeLim = [ 0, 5.5; 0, 5; 0, 3.5 ];

Slope = NaN( 4, 3 );
for Group = 0:2
    LME = PlotLME( Tau.RID( IncludedScan_AP( GroupIndex_AP == Group ) ), ...
        TimeLag_AP( ( GroupIndex_AP == Group ), 3 ), Alterations( GroupIndex_AP == Group ), ...
        TimeLim( Group + 1, : ), Red5( Group + 3, : )/255, ...
        [ OutputPath, filesep, 'TauConnectomeLongitudinal', num2str( Group ), '.svg' ] );
    Slope( :, Group + 1 ) = LME( 2, [ 1, 6, 7, 5 ] );
end

P = Slope( 4, : );

LME = LME_Interaction( Tau.RID( IncludedScan_AP ), TimeLag_AP( :, 3 ), GroupIndex_AP, Alterations );

%% Plot fitted line using linear mixed-effects model
function [ LME ] = PlotLME( ID, Time, Alteration, TimeLim, Color, OutputFile )

figure( 'Position', [ 0, 100, TimeLim( 2 )*50, 360 ] );
hold on;

[ C, ~, ic ] = unique( ID );

ScanNumber = zeros( numel( ID ), 1 );
for Scan = 1:numel( C )
    ScanMask = find( ic == Scan );
    ScanNumber( ScanMask ) = numel( ScanMask );
    if numel( ScanMask ) > 1
        X = Time( ScanMask );
        Y = Alteration( ScanMask );
        line( X, Y, 'color', Color, 'LineWidth', 1.5 );
        scatter( X, Y, 15, Color, 'filled' );
    end
end

ID = ID( ScanNumber > 1.5 );
Time = Time( ScanNumber > 1.5 );
Alteration = Alteration( ScanNumber > 1.5 );

Data = table( ID, Time, Alteration, ...
    'VariableNames', { 'ID', 'Time', 'Alteration' } );
LME = fitlme( Data, 'Alteration ~ Time + ( 1|ID ) + ( Time - 1|ID )' );

fill( [ 0, 0, max( Time ), max( Time ) ], ...
    [ double( LME.Coefficients( 1, 7 ) ), double( LME.Coefficients( 1, 8 ) ), ...
    double( LME.Coefficients( 1, 8 ) ) + double( LME.Coefficients( 2, 8 ) )*max( Time ), ...
    double( LME.Coefficients( 1, 7 ) ) + double( LME.Coefficients( 2, 7 ) )*max( Time ) ], ...
    'k', 'FaceAlpha', 0.3, 'EdgeColor', 'None' )
plot( [ 0, max( Time ) ], [ double( LME.Coefficients( 1, 2 ) ), double( LME.Coefficients( 1, 2 ) ) + double( LME.Coefficients( 2, 2 ) ).*max( Time ) ], ...
    '--', 'color', Color, 'LineWidth', 5 );

axis off;
xlim( TimeLim );
ylim( [ 0, 1 ] );
set( gca,'Position', [ 0, 0, 1, 1 ] );

LME = double( LME.Coefficients( :, 2:end ) );

saveas( gcf, OutputFile )
end

%% Fit line using linear mixed-effects model with interaction effect
function [ LME ] = LME_Interaction( ID, Time, Group, Alteration )

[ C, ~, ic ] = unique( ID );

ScanNumber = zeros( numel( ID ), 1 );
for Scan = 1:numel( C )
    ScanMask = find( ic == Scan );
    ScanNumber( ScanMask ) = numel( ScanMask );
end

ID          = ID( ScanNumber > 1.5 );
Time        = Time( ScanNumber > 1.5 );
Group       = Group( ScanNumber > 1.5 );
Alteration  = Alteration( ScanNumber > 1.5 );

Data = table( ID, Time, Group, Alteration, ...
    'VariableNames', { 'ID', 'Time', 'Group', 'Alteration' } );
LME = fitlme( Data, 'Alteration ~ Time * Group + ( 1|ID ) + ( Time - 1|ID )' );

end