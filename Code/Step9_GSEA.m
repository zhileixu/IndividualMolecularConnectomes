%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Step 9: Gene Set Enrichment Analysis %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
clc;
close all;

OutputPath = [ pwd, filesep, '..', filesep, 'GSEA' ];

load( [ pwd, filesep, '..', filesep, 'ConnectomeTranscriptome', filesep, 'ContributionTau.mat' ] );
load( [ pwd, filesep, '..', filesep, 'AHBAprocessed', filesep, 'ROIxGene_aparcaseg_RNAseq.mat' ], 'probeInformation');

% Please download the gmt file from http://download.baderlab.org/EM_Genesets/
fid = fopen( [ OutputPath, filesep, 'Human_GOBP_AllPathways_no_GO_iea_November_07_2023_entrezgene.gmt' ] );
GeneSet = textscan( fid, '%s', 'Delimiter', '\n' );
fclose( fid );
GeneSet = GeneSet{ 1 };

GeneSetSize = zeros( numel( GeneSet ), 1 );
GeneSetContribution = zeros( numel( GeneSet ), 1 );
for Counter = 1:numel( GeneSet )
    GeneList = strsplit( GeneSet{ Counter }, '\t' );
    [ Lia, Locb ] = ismember( probeInformation.EntrezID, cellfun( @str2num, GeneList( 3:end-1 ) ) );
    GeneSetSize( Counter ) = sum( Lia );
    GeneSetContribution( Counter ) = sum( Contribution( Lia ) );
end

FoldEnrichment = GeneSetContribution./( GeneSetSize/numel( probeInformation.GeneSymbol ) );
FoldEnrichment( isnan( FoldEnrichment ) ) = 0;

save( [ OutputPath, filesep, 'GSEA.mat' ], 'GeneSetSize', 'GeneSetContribution', 'FoldEnrichment' );
