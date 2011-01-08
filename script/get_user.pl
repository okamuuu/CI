#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use CI::Search;
use Data::Dumper;
local $Data::Dumper::Maxdepth = 4;

my $author = 'chihiroyuki';
my $uri = URI->new("http://gdata.youtube.com/feeds/api/users/$author?v=2&alt=json");
warn Dumper my $data = CI::Search->_get_data_from($uri);



