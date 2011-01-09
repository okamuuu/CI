#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Data::Dumper;
local $Data::Dumper::Maxdepth = 3;

BEGIN { use_ok 'CI::Search' }

subtest 'lookup' => sub {

    my $video_id = '_Z9q7yun6A4';
    
    subtest 'video' => sub {
   
        my $video = CI::Search->lookup_video($video_id);
    
        isa_ok( $video, 'CI::Model::Video' );
        ok $video->id,       $video->id;
        ok $video->title,    $video->title;
        ok $video->keywords, join ',', $video->keywords;
    };

};

subtest 'search' => sub {
        
    my $video_id = '_Z9q7yun6A4';

    subtest 'commented users to video' => sub {
        my @user_ids = CI::Search->commented_user_ids_of($video_id);
        ok @user_ids, join ', ', @user_ids;
    };

    subtest 'keywords of video' => sub {
        my @keywords = CI::Search->keywords_of($video_id);
        ok @keywords, join ', ', @keywords;
    };
};

done_testing;

__END__
#my $author = 'chihiroyuki';
#my $author = 'PechekH';
my $author = 'iOlrickx';

ok $author, "target author is $author";

my $video_id = '_Z9q7yun6A4';

subtest 'favorite video count of user' => sub {
    my $count = CI::Search->favorite_video_count_of($author); 
    ok $count, "count: $count";
    pass(); 
};

=pod
subtest 'favorite videos' => sub {
    warn Dumper my @video_ids = CI::Search->favorite_videos_of($author); 
    pass(); 
};
=cut
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

