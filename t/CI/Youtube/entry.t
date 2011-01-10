#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Data::Dumper;
local $Data::Dumper::Maxdepth = 3;

BEGIN { use_ok 'CI::Youtube::Entry' }

subtest 'search' => sub {

    my $user_id  = 'EntonyCzRu';
    my $video_id = '_Z9q7yun6A4';
 
    subtest 'Search favorite entries of user. They contain "media$group".' => sub {
        my @entries = CI::Youtube::Entry->search_favorites_of($user_id);
        warn Dumper $entries[0];
        ok $_->{'media$group'} for @entries; 
    };  

    subtest 'Search comment entries to video. They contain "author".' => sub {
        my @entries = CI::Youtube::Entry->search_comments_to($video_id);
        ok $_->{author}->[0]->{name}->{'$t'} for @entries;
    };  

};

done_testing();

