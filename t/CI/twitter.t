#!/usr/bin/env perl
use strict;
use warnings;
use Encode ();
use Test::More;
use Data::Dumper;
local $Data::Dumper::Maxdepth = 3;

BEGIN { use_ok 'CI::Twitter' }

subtest 'get_user_timeline_of' => sub {

    my $username  = 'okamuuu';
 
    my $data = CI::Twitter->get_user_timeline_of($username);

    ok $data->[0]->{text}, Encode::encode_utf8($data->[0]->{text} );
};

subtest 'get_lately_tweets_of' => sub {

    my $username  = 'okamuuu';
 
    my $tweets_ref = CI::Twitter->get_lately_tweets_of($username);

    ok $tweets_ref->[0], Encode::encode_utf8( $tweets_ref->[0] );
};


done_testing();

