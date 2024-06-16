function [ ScanOrder, TimeLag, FirstScanAge ] = GetScanOrder( ID, ScanDate, Age )

[ C, ~, ic ] = unique( ID );

ScanOrder       = NaN( numel( ID ), 1 );
TimeLag         = NaN( numel( ID ), 3 );
FirstScanAge    = NaN( numel( ID ), 1 );

for Scan = 1:numel( C )
    ScanMask = ( ic == Scan );
    [ ScanDateSorted, ScanOrder( ScanMask ) ] = sort( ScanDate( ScanMask ) );
    TimeLag( ScanMask, 1 ) = datenum( ScanDate( ScanMask ) ) - datenum( ScanDateSorted( 1 ) );
    TimeLag( ScanMask, 2 ) = months( datestr( ScanDateSorted( 1 ) ), datestr( ScanDate( ScanMask ) ) );
    TimeLag( ScanMask, 3 ) = years( datetime( ScanDate( ScanMask ) ) - datetime( ScanDateSorted( 1 ) ) );

    FirstScanAge( ScanMask ) = min( Age( ScanMask ) );
end

end