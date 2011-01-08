#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Data::Dumper;
local $Data::Dumper::Maxdepth = 5;

BEGIN { use_ok 'CI::Search' }

my $author = 'chihiroyuki';
ok $author, "target author is $author";

my $video_id = '_Z9q7yun6A4';

subtest 'favorite videos' => sub {
    warn Dumper my @video_ids = CI::Search->favorite_videos_of($author); 
    pass(); 
};

=pod
subtest 'get video info' => sub {
    warn Dumper my $data = CI::Search->video_info_of($video_id); 
    pass();
};
=cut

=pod
subtest 'get commented users' => sub {
    my @comments = CI::Search->commented_users_for($video_id); 
    ok @comments, join ', ', @comments;
};
=cut
=pod
subtest 'get top favorites' => sub {
    warn Dumper my $data = CI::Search->top_favorites();
    pass();
};

subtest 'get subscriptions' => sub {

    subtest 'private methods' => sub {
        my $uri = CI::Search->_subscriptions_url_of($author);
        is $uri, "http://gdata.youtube.com/feeds/api/users/$author/subscriptions?v=2&alt=json";

        my $data = CI::Search->_get_data_from($uri);
        is $data->{feed}->{author}->[0]->{name}->{'$t'}, $author;
    };

    my @subscriptions = CI::Search->subscriptions_of($author);
    ok @subscriptions, join ", ", @subscriptions;
};
=cut

done_testing;

