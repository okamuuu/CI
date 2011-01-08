package CI::Algorithm;
use strict;
use warnings;
use List::Util qw/sum/;
use List::MoreUtils qw/uniq/;
use Carp ();

### 真似した
### http://d.hatena.ne.jp/rin1024/20090411/1239464111
sub pearson {
    my ($class, $data1, $data2 ) = @_;

    ### local copy
    my %data1 = %{$data1};
    my %data2 = %{$data2};

    ### 互いの共通アイテムを抽出
    my %seen;
    my @items = grep { $seen{$_}++ } (keys %data1, keys %data2);
    
    die "not found..." unless scalar @items;
 
    ### 合計点を求める
    my $sum1 = sum values %data1;
    my $sum2 = sum values %data2;

    ### 平方を合計する。
    ### ** 2 を使わなかった理由は以下。未検証。
    ### http://d.hatena.ne.jp/htz/20090223/1235354119
    my $sum1Sq = sum map { $_ * $_ } values %data1;
    my $sum2Sq = sum map { $_ * $_ } values %data2;

    ### 積を合計
    my $pSum = sum map { ( $data1{$_} ) * ( $data2{$_} ) } @items;

    ### スコア計算
    my $n = @items;
    my $num = $pSum - ( $sum1 * $sum2 / $n );
    my $den =
      sqrt ( 
            ( $sum1Sq - ( $sum1 * $sum1 ) / $n ) *
            ( $sum2Sq - ( $sum2 * $sum2 ) / $n ) 
      ) or die('calc result is 0');

    my $r = $num / $den;
    return $r;

}

1;

