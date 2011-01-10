package CI::Algorithm::Pearson;
use strict;
use warnings;
use List::Util qw/sum/;
use List::MoreUtils qw/uniq/;
use Carp ();

### 真似した
### http://d.hatena.ne.jp/rin1024/20090411/1239464111
sub calc {
    my ($class, $data1, $data2 ) = @_;

    ### local copy
    my %data1 = %{$data1};
    my %data2 = %{$data2};

    ### 互いの共通アイテムを抽出
    my %seen;
    my @items = grep { $seen{$_}++ } (keys %data1, keys %data2);
    
    Carp::croak "not found common item..." unless scalar @items;
 
    ### 合計点を求める
    my $sum1 = sum map { $data1{$_} } @items;
    my $sum2 = sum map { $data2{$_} } @items;

    ### 平方を合計する。
    my $sum1Sq = sum map { $data1{$_} ** 2 } @items;
    my $sum2Sq = sum map { $data2{$_} ** 2 } @items;

    ### 積を合計
    my $pSum = sum map { ( $data1{$_} ) * ( $data2{$_} ) } @items;

    ### スコア計算
    my $n = @items;
    my $num = $pSum - ( $sum1 * $sum2 / $n );
    my $den =
      sqrt ( 
            ( $sum1Sq - ( $sum1 * $sum1 ) / $n ) *
            ( $sum2Sq - ( $sum2 * $sum2 ) / $n ) 
      );

    if ( $den == 0 ) { Carp::croak 'calc result is 0'; }

    return $num / $den; # more than -1, less than 1
}

1;

