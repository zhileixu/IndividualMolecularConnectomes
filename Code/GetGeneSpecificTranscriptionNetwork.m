% Please download the ROIxGene_aparcaseg_RNAseq.mat file from https://doi.org/10.6084/m9.figshare.6852911

load( [ pwd, filesep, '..', filesep, 'AHBAprocessed', filesep, 'ROIxGene_aparcaseg_RNAseq.mat' ], 'parcelExpression' );

parcelExpression = parcelExpression( :, 2:end );

IndividualTranscriptionNetwork = NaN( 561, numel( parcelExpression( 1, : ) ) );
for Gene = 1:numel( parcelExpression( 1, : ) )
    ReferenceTranscription = parcelExpression;
    ReferenceTranscription( :, Gene ) = [];
    ReferenceTranscriptionNetwork = corr( ReferenceTranscription' );
    PerturbedTranscriptionNetwork = corr( parcelExpression' );
    IndividualTranscriptionNetwork( :, Gene ) = squareform( PerturbedTranscriptionNetwork - ReferenceTranscriptionNetwork )./...
        squareform( 1 - ReferenceTranscriptionNetwork.^2 )*( numel( ReferenceTranscription( 1, : ) ) - 1 );
end

csvwrite( [ pwd, filesep, 'IndividualTranscriptionNetwork.csv' ], IndividualTranscriptionNetwork );