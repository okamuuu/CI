#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use CI::Search;
local $Data::Dumper::Maxdepth = 5;

my $author = 'chihiroyuki';

my @subs;

my @subscriptions;
for my $user ( CI::Search->subscriptions_of($author) ) {
    push @subscriptions, CI::Search->subscriptions_of($user);
}

warn scalar @subscriptions;
warn join ', ', @subscriptions;


