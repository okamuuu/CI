#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use CI::Search;
use CI::Algorithm;
use List::Util qw/shuffle/;
use List::MoreUtils qw/uniq/;
use Data::Dumper;
local $Data::Dumper::Maxdepth = 2;

my %LIMIT_CNT_OF = ( favorites => 100 );

### お気に入りの動画を３つほど選択
### コメントを書いたユーザーは、これらの動画に対して関心を示していると判断
my @video_ids = qw/_Z9q7yun6A4/; # Kzw8RcNEs_E 2RnwbLmWMgc/;
my ($user1_id, $user2_id) = shuffle map { CI::Search->commented_user_ids_of($_) } @video_ids;

my $user3_id = 'HektikVImpakt';

my %prefs;
for my $user_id ( $user1_id, $user2_id, $user3_id ) {

    my %count_of;
    $count_of{$_}++
      for map { CI::Search->keywords_of($_) }
      CI::Search->favorite_video_ids_of($user_id);

    $prefs{$user_id} = {%count_of}; 
}

warn Dumper {%prefs};

compare($user1_id, $user2_id);
compare($user2_id, $user3_id);
compare($user3_id, $user1_id);

sub compare {
    my ( $user1, $user2 ) = @_;
    
    my $result = CI::Algorithm->pearson($prefs{$user1}, $prefs{$user2});

    warn "$user1 & $user2";
    warn "result : $result\n";
}

__END__

my @users =
  map { CI::Search->lookup_user($_) } ($user_id);
#  map { CI::Search->lookup_user($_) } uniq map { $_->author_id } @comments;

#warn Dumper [$users[0]->favorites]->[0];

__END__

#warn Dumper @videos;

### コメントしているユーザーを取得。
### Youtubeを積極的に利用し、動画に関心を示した人たち
### 彼らがそれぞれ何件の動画をお気に入り登録しているかを求める
my %count_of =
  map { $_ => CI::Search->favorite_video_count_of($_) }
  map { CI::Search->commented_users_to($_) } @videos;

### お気に入り動画を多数登録している順番でユーザー一覧を求める
### 動画の登録件数が少ないユーザーを除外しておく
my @commented_users =
  reverse sort { $count_of{$a} <=> $count_of{$b} }
  grep         { $count_of{$_} > $LIMIT_CNT_OF{favorites} }
  keys %count_of;

### 対象者を２名選抜
### お気に入り動画のidを探す
warn my ( $user1, $user2 ) = shuffle @commented_users;

die 'oops!!' unless $user2;

my %user1_favorites = map { $_ => 1 } CI::Search->favorite_videos_of($user1); 
my %user2_favorites = map { $_ => 1 } CI::Search->favorite_videos_of($user2);

my %favorites_of = (
    $user1 => {%user1_favorites},
    $user2 => {%user2_favorites},
);

my $result = CI::Algorithm->pearson($favorites_of{$user1}, $favorites_of{$user2});

print "user1: $user1\n";
print "user2: $user2\n";
print "similar: $result\n";


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


