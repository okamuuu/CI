#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use CI::Youtube::Entry;
use CI::Algorithm::Pearson;
use List::Util qw/shuffle/;
use List::MoreUtils qw/uniq/;

use Data::Dumper;
local $Data::Dumper::Maxdepth = 2;

### お気に入りの動画
### 好きなだけどうぞ
my @video_ids = qw/_Z9q7yun6A4/; 

### コメントを書いたユーザーは、これらの動画に対して関心を示していると判断
### 無作為にこのユーザーを選出。このユーザーの類似度は高いと予想
my ( $user1_id, $user2_id ) = shuffle map { $_->{author}->[0]->{name}->{'$t'} }
  map { CI::Youtube::Entry->search_comments_to($_) } @video_ids;

### あまり関連のないユーザーを適当にピックアップ
my $user3_id = 'HektikVImpakt';

### データセットを作成
my %prefs;
for my $user_id ( $user1_id, $user2_id, $user3_id ) {

    ### お気に入りfeedに動画のキーワードがカンマ区切り
    ### で格納されているので、それを取り出してノーマライズ
    my %count_of;
    $count_of{$_}++
      for 
        map { normalize($_) }
        grep { match_valid($_) }
        map { split ', ', $_->{'media$group'}->{'media$keywords'}->{'$t'} }
        CI::Youtube::Entry->search_favorites_of($user_id);

    $prefs{$user_id} = {%count_of}; 
}

warn Dumper {%prefs};

compare($user1_id, $user2_id);
compare($user2_id, $user3_id);
compare($user3_id, $user1_id);

sub compare {
    my ( $user1, $user2 ) = @_;
    
    my $result = CI::Algorithm::Pearson->calc($prefs{$user1}, $prefs{$user2});

    warn "$user1 & $user2";
    warn "result : $result\n";
}

sub match_valid {
    $_[0] =~ m/^\d+$/ ? undef : $_[0];
}

sub normalize {
    $_[0] =~ s/[-_]//g;
    return $_[0];
}

