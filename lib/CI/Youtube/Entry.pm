package CI::Youtube::Entry;
use strict;
use warnings;
use Sub::Retry;
use Cache::FileCache;
use WebService::Simple;
use URI;
use JSON ();

use Data::Dumper;
local $Data::Dumper::Maxdepth = 3;

sub lookup_video {
    my ( $class, $video_id ) = @_;
    my $uri = URI->new("http://gdata.youtube.com/feeds/api/videos/$video_id");
    $class->_lookup_entry($uri);
}

sub search_favorites_of {
    my ( $class, $user_id ) = @_;
    my $uri =
      URI->new("http://gdata.youtube.com/feeds/api/users/$user_id/favorites");
    $class->_search_entries($uri);
}

sub search_comments_to {
    my ( $class, $video_id ) = @_;
    my $uri =
      URI->new("http://gdata.youtube.com/feeds/api/videos/$video_id/comments");
    $class->_search_entries($uri);
}

sub _lookup_entry {
    my ( $class, $uri ) = @_;
    $uri->query_form( v => 2, alt => 'json' );
    
    my $data = $class->_get_data_from($uri) or return;
    $data->{entry};
}

sub _search_entries {
    my ( $class, $uri ) = @_;

    my $start_index =  1;
    my $max_results = 25;

    $uri->query_form(
        v             => 2,
        alt           => 'json',
        'start-index' => $start_index,
        'max-results' => $max_results,
    );

    ### 1ページ目
    my $data    = $class->_get_data_from($uri);
    my $total   = $data->{feed}->{'openSearch$totalResults'}->{'$t'} || 0;
    $total = $total > 500 ? 500 : $total; 
    
    return unless $total;
   
    my $entry   = $data->{feed}->{entry} or die;
    my @entries = _to_array($entry);

    ### 2ページ目以降
    while ( $start_index < $total ) {

        $uri->query_form(
            v             => 2,
            alt           => 'json',
            'start-index' => $start_index,
            'max-results' => $max_results,
        );

        my $data    = $class->_get_data_from($uri);
        my $entry   = $data->{feed}->{entry} or die;
        push @entries, _to_array( $entry );
        $start_index += $max_results;
    }

    return @entries;
}

sub _get_data_from {
    my ( $class, $uri ) = @_;

    my $cache = Cache::FileCache->new(
        {
            namespace          => 'MyNamespace',
            default_expires_in => 24 * 60 * 60,
        }
    );

    ### キャッシュ機能使いたい
    my $ws = WebService::Simple->new(
        base_url        => $uri,
        cache           => $cache,
# こうじゃなかったっけ？動かないのでParseは自分でしておく
#        response_parser => 'JSON',
    );

#    my $response = eval { $ws->get };
    my $response = retry 3, 1, sub { $ws->get };
    
    if ( $@ ) {
        warn $@;
        return;
    }
        
    my $content = $response->decoded_content;
  
    return JSON::decode_json($content);
}

sub _to_array { ref $_[0] eq 'ARRAY' ? @{$_[0]} : $_[0]; }

sub _to_arrayref { ref $_[0] eq 'ARRAY' ? $_[0] : [$_[0]]; }

sub _match_comment_id { $_[0] =~ m/comment:(\w+)$/ ? $1 : undef; }

sub _match_video_id { $_[0] =~ m/video:(\w+)$/ ? $1 : undef; }

1;


