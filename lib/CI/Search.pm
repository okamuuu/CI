package CI::Search;
use strict;
use warnings;
use Cache::FileCache;
use WebService::Simple;

use URI;
use LWP::UserAgent;
use JSON ();
use Time::HiRes ();

use Data::Dumper;

sub top_favorites {
    my $class = shift;
    my $uri = "http://gdata.youtube.com/feeds/api/standardfeeds/top_favorites?v=2&alt=json";
    my $data = $class->_get_data_from($uri);
}

sub favorite_videos_of {
    my ( $class, $user_id ) = @_;
    my $uri  = URI->new("http://gdata.youtube.com/feeds/api/users/$user_id/favorites?v=2&alt=json");
    my $data = $class->_get_data_from($uri);

    my $entries_ref = $data->{feed}->{entry};

    return
      map  { $_->{'media$group'}->{'yt$videoid'}->{'$t'} } @{$entries_ref};
}

sub video_info_of {
    my ( $class, $video_id ) = @_;
    
    my $uri = URI->new("http://gdata.youtube.com/feeds/api/videos/$video_id?v=2&alt=json");
    my $data = $class->_get_data_from($uri);
}

sub commented_users_to {
    my ( $class, $video_id ) = @_;

    my $uri = URI->new(
"http://gdata.youtube.com/feeds/api/videos/$video_id/comments?v=2&alt=json"
    );

    my $author =
      $class->video_info_of($video_id)->{entry}->{author}->[0]->{name}->{'$t'};

    my $data        = $class->_get_data_from($uri);
    my $entries_ref = $data->{feed}->{entry};

    my %seen;
    return
      grep { not $seen{$_}++ }
      map  { $_->{author}->[0]->{name}->{'$t'} } @{$entries_ref};
}

sub subscriptions_of {
    my ( $class, $author_id ) = @_;

    my $uri = URI->new("http://gdata.youtube.com/feeds/api/users/$author_id/subscriptions?v=2&alt=json");
    my $data = $class->_get_data_from($uri) or return;
    Time::HiRes::sleep(0.1);
    my $entries_ref = $data->{feed}->{entry} or return;
    
    return map { $_->{'yt$username'}->{'$t'} } @{ $entries_ref };   
}

sub _get_data_from {
    my ( $class, $uri ) = @_;

    my $cache = Cache::FileCache->new(
        {
            namespace          => 'MyNamespace',
            default_expires_in => 15 * 60 * 60,
        }
    );

    ### キャッシュ機能だけ使いたい
    my $ws = WebService::Simple->new(
        base_url => $uri,
        cache    => $cache,
    );

    my $response = eval { $ws->get };
    
    if ( $@ ) {
        warn $@;
        return;
    }
        
    my $content = $response->decoded_content;
    
    return JSON::decode_json($content);
}

1;


