function [ Permutation ] = RankSumPermutation( Data1, Data2 )

N = 10000;

SubjectNumber1 = numel( Data1( :, 1 ) );
SubjectNumber2 = numel( Data2( :, 1 ) );
TestNumber = numel( Data1( 1, : ) );

Z = zeros( 1, TestNumber );
RankSum = zeros( 1, TestNumber );
Z_Null = zeros( N, TestNumber );
RankSum_Null = zeros( N, TestNumber );

[ ~, RandSeed ] = sort( rand( SubjectNumber1 + SubjectNumber2, N ) );
DataPool = [ Data1; Data2 ];

for Test = 1:TestNumber
    [ ~, ~, stats ] = ranksum( Data1( :, Test ), Data2( :, Test ) );
    RankSum( Test ) = stats.ranksum;
    Z( Test ) = stats.zval;
    for Permutation = 1:N
        [ ~, ~, stats ] = ranksum( DataPool( RandSeed( 1:SubjectNumber1, Permutation ), Test ), ...
            DataPool( RandSeed( SubjectNumber1 + 1:end, Permutation ), Test ) );
        RankSum_Null( Permutation, Test ) = stats.ranksum;
        Z_Null( Permutation,Test ) = stats.zval;
    end
end

Permutation = [];
Permutation.Z = Z;
Permutation.RankSum = RankSum;
Permutation.Z_Null = Z_Null;
Permutation.RankSum_Null = RankSum_Null;

Permutation.P = sum( Permutation.RankSum_Null > Permutation.RankSum( ones( N, 1 ), : ) )/N;
Permutation.P( Permutation.Z < 0 ) = 1 - Permutation.P( Permutation.Z < 0 );

end