%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Step 8: Connectome Transcriptome Association Analysis %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;
close all;

OutputPath = [ pwd, filesep, '..', filesep, 'ConnectomeTranscriptome' ];
mkdir( OutputPath )

%% Align the DK atlas labels between the one used in transcriptome 
% data preprocess with the one used in PET data analysis

[ vertices, label, colortable ] = read_annotation( [ pwd, filesep, 'lh.aparc.annot' ] );
StructNames = colortable.struct_names( [ 2:4, 6:end ] );

DK = importdata( [ pwd, filesep, 'DesikanKilliany.txt' ] );

Reorder = zeros( numel( StructNames ), 1 );
for ROI = 1:numel( StructNames )
    Reorder( ROI ) = find( ismember( lower( DK ), StructNames( ROI ) ) );
end

%% Prepare data

load( [ pwd, filesep, '..', filesep, 'ConnectomeClassification', filesep, 'TauConnectomeContribution.mat' ] );
Susceptibility68 = squareform( mean( TauConnectomeContribution ) );
Susceptibility561 = log10( squareform( Susceptibility68( Reorder, Reorder ) ) );
csvwrite( [ OutputPath, filesep, 'Susceptibility561.csv' ], Susceptibility561' );

N = 1000;
[ ~, Sample561TrainTest ] = sort( rand( N, numel( Susceptibility561 ) ), 2 );
csvwrite( [ OutputPath, filesep, 'Sample561TrainTest.csv' ], Sample561TrainTest );

%% Get Gene-Specific Transcription Network
% Please download the ROIxGene_aparcaseg_RNAseq.mat file from https://doi.org/10.6084/m9.figshare.6852911

load( [ pwd, filesep, '..', filesep, 'AHBAprocessed', filesep, 'ROIxGene_aparcaseg_RNAseq.mat' ], 'parcelExpression' );

parcelExpression = parcelExpression( :, 2:end );
ReferenceTranscriptionNetwork = corr( parcelExpression' );

GeneSpecificTranscriptionNetwork = NaN( 561, numel( parcelExpression( 1, : ) ) );
for Gene = 1:numel( parcelExpression( 1, : ) )
    PerturbedTranscription = parcelExpression;
    PerturbedTranscription( :, Gene ) = [];
    PerturbedTranscriptionNetwork = corr( PerturbedTranscription' );
    GeneSpecificTranscriptionNetwork( :, Gene ) = squareform( ReferenceTranscriptionNetwork - PerturbedTranscriptionNetwork )./...
        squareform( 1 - ReferenceTranscriptionNetwork.^2 )*( numel( parcelExpression( 1, : ) ) - 1 );
end

csvwrite( [ OutputPath, filesep, 'GeneSpecificTranscriptionNetwork.csv' ], GeneSpecificTranscriptionNetwork );