package CI::Twitter;
use strict;
use warnings;
use CI::WebService;
use JSON;
use URI;
use Data::Dumper;

sub get_lately_tweets_of {
    my ( $class, $username ) = @_;

    my $data = $class->get_user_timeline_of($username);

    return [ map { $_->{text} } @{$data} ];
}

sub get_user_timeline_of {
    my ($class, $username) = @_;

    my $uri = URI->new("http://twitter.com/statuses/user_timeline/${username}.json");
    $uri->query_form( count => 200, page => 1 );

    my $ws = CI::WebService->new;

    my $content = $ws->get($uri) or return;
    
    my $data = JSON::decode_json($content);

    return $data;
}

1;

