package CI::WebService;
use strict;
use warnings;
use Data::Dumper;
use Digest::MD5;
use Sub::Retry qw/retry/;
use LWP::UserAgent;
use Cache::FileCache;

sub new {
    return bless {
        _ua    => $_[0]->_create_ua(),
        _cache => $_[0]->_create_cache(),
    };
}

sub ua    { $_[0]->{_ua}    }
sub cache { $_[0]->{_cache} }

sub get {
    my ( $self, $uri ) = @_;

    my $content = $self->__cache_get( [ $uri, 'GET' ] );
    
    return $content if $content;

    my $response = retry 3, 1, sub { $self->ua->get($uri) };

    if ( $@ ) {
        warn $@;
        return;
    }

    if ($response->is_success) {
        $self->__cache_set($response->decoded_content);
        return $response->decoded_content;
    }
    else {
        warn $response->status_line;
        return;
    }

    #return JSON::decode_json($content);
}

sub __cache_get {
    my $self  = shift;
    
    my $key = $self->__cache_key(shift);
    return $self->cache->get( $key, @_ );
}

sub __cache_set {
    my $self = shift;

    my $key = $self->__cache_key(shift);
    return $self->cache->set( $key, @_ );
}

sub __cache_key {
    my $self = shift;
    local $Data::Dumper::Indent   = 1;
    local $Data::Dumper::Terse    = 1;
    local $Data::Dumper::Sortkeys = 1;
    return Digest::MD5::md5_hex( Data::Dumper::Dumper( $_[0] ) );
}

sub _create_ua {
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->env_proxy;

    return $ua;
}

sub _create_cache {
    return Cache::FileCache->new(
        {  
            namespace          => 'MyNamespace',
            default_expires_in => 24 * 60 * 60,
        }
    );
}

1;

