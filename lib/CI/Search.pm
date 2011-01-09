package CI::Search;
use strict;
use warnings;
use CI::Model::User;
use CI::Model::Video;
use CI::Model::Comment;
use List::MoreUtils qw/uniq/;
use Cache::FileCache;
use WebService::Simple;
use URI;
use JSON ();
use Time::HiRes ();
use Data::Dumper;
local $Data::Dumper::Maxdepth = 3;

sub lookup_video {
    my ( $class, $id ) = @_;

    my $uri = URI->new("http://gdata.youtube.com/feeds/api/videos/$id");
    $uri->query_form( v => 2, alt => 'json' );
    
    my $data = $class->_get_data_from($uri) or return;
    my $entry = $data->{entry} or return;

    my $title = $entry->{title}->{'$t'};
    my $keywords_ref =
      _to_arrayref( $entry->{'media$group'}->{'media$keywords'}->{'$t'} );
    my $description = $entry->{'media$group'}->{'media$description'}->{'$t'};

    return CI::Model::Video->new(
        id    => $id,
        title => $title,
        _keywords => $keywords_ref,
        description => $description,
    );
}

sub keywords_of {
    my ( $class, $video_id ) = @_;

    my $uri = URI->new("http://gdata.youtube.com/feeds/api/videos/$video_id");
    $uri->query_form( v => 2, alt => 'json' );
    
    my $data = $class->_get_data_from($uri) or return;
    my $entry = $data->{entry} or return;

    my $string = $entry->{'media$group'}->{'media$keywords'}->{'$t'} or return;

    split ', ', $string;
}

sub favorite_video_ids_of {
    my ( $class, $user_id ) = @_;

    my $uri =
      URI->new("http://gdata.youtube.com/feeds/api/users/$user_id/favorites");

    my @entries = $class->_entries($uri) or return;

    return map { $_->{'media$group'}->{'yt$videoid'}->{'$t'} } @entries;
}

sub commented_user_ids_of {
    my ( $class, $video_id ) = @_;

    my $uri =
      URI->new("http://gdata.youtube.com/feeds/api/videos/$video_id/comments");

    my @entries = $class->_entries($uri) or return;

    return uniq map { $_->{'author'}->[0]->{name}->{'$t'} } @entries;
}


sub favorite_video_count_of {
    my ( $class, $user_id ) = @_;
 
    my $uri  = URI->new("http://gdata.youtube.com/feeds/api/users/$user_id/favorites?v=2&alt=json");
    my $data = $class->_get_data_from($uri);

    return $data->{feed}->{'openSearch$totalResults'}->{'$t'} || 0;
}

sub _get_data_from {
    my ( $class, $uri ) = @_;

    my $cache = Cache::FileCache->new(
        {
            namespace          => 'MyNamespace',
            default_expires_in => 24 * 60 * 60,
        }
    );

    ### キャッシュ機能だけ使いたい
    my $ws = WebService::Simple->new(
        base_url        => $uri,
        cache           => $cache,
        debug => 1,
# こうじゃなかったっけ？動かないのでParseは自分でしておく
#        response_parser => 'JSON',
    );

    my $response = eval { $ws->get };
    
    if ( $@ ) {
        warn $@;
        return;
    }
        
    my $content = $response->decoded_content;
  
    return JSON::decode_json($content);
}

sub _entries {
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
    my $total   = $data->{feed}->{'openSearch$totalResults'}->{'$t'};

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

### entryが単数の場合は配列リファレンスではなくスカラーという記憶があるが、あれYoutubeだったかな
sub _to_array { ref $_[0] eq 'ARRAY' ? @{$_[0]} : $_[0]; }

sub _to_arrayref { ref $_[0] eq 'ARRAY' ? $_[0] : [$_[0]]; }

sub _match_comment_id { $_[0] =~ m/comment:(\w+)$/ ? $1 : undef; }

sub _match_video_id { $_[0] =~ m/video:(\w+)$/ ? $1 : undef; }

1;


