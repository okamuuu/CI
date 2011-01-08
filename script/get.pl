#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use CI::Search;
use CI::Algorithm;
use List::Util qw/shuffle/;
use List::MoreUtils qw/uniq/;
use Data::Dumper;
local $Data::Dumper::Maxdepth = 4;

### お気に入りの動画を３つほど選択
my @videos = qw/_Z9q7yun6A4 Kzw8RcNEs_E 2RnwbLmWMgc/;

### コメントしているユーザーを取得。
### Youtubeを積極的に利用し、動画に関心を示した人たち
my @commented_users = map { CI::Search->commented_users_to($_) } @videos;

### お気に入り動画を多数登録しているユーザーを探す
my %count_of =
  map { $_ => CI::Search->favorite_video_count_of($_) } @commented_users;


__END__

### 彼らのお気に入り動画一覧を取得
### 配列ではなくハッシュで保持
my %favorites_of;
for my $user ( @commented_users ) {
    my @favorites = CI::Search->favorite_videos_of($user);
    
    # お気に入りの数が少ないユーザーは除外
    next if @favorites < 20;
    
    warn $user;
    warn scalar @favorites;

    $favorites_of{$user} = { map { $_ => 1 } CI::Search->favorite_videos_of($user) };
}

#warn scalar keys %favorites_of;
#warn Dumper {%favorites_of};

### すべてのユーザーのお気に入りの動画を取得
### 重複分は除いておく
#my @favorites = uniq map { keys %{$_} } values %favorites_of;

### 比較するユーザーを2名選出
my ( $user1, $user2 ) = shuffle keys %favorites_of;

### 比較するユーザーに対して、他の動画に関する情報を追加
### この場合はお気に入りにしていない動画なので評価は0
=pod
for my $video ( @favorites ) {

    if ( not $favorites_of{$user1}->{$video} ) {
        $favorites_of{$user1}->{$video} = 0;
    }

    if ( not $favorites_of{$user2}->{$video} ) {
        $favorites_of{$user2}->{$video} = 0;
    }
}
=cut

my $result = CI::Algorithm->pearson($favorites_of{$user1}, $favorites_of{$user2});

print "user1: $user1\n";
print "user2: $user2\n";
print "similar: $result\n";


