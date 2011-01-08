#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use CI::Search;
use CI::Algorithm;
use List::Util qw/shuffle/;
use List::MoreUtils qw/uniq/;
use Data::Dumper;
local $Data::Dumper::Maxdepth = 4;

my %score_of = (
    suzuki => {
        japanese => 50,
        math => 70,
        english => 80,
    },
    sato => {
        japanese => 55,
        math => 75,
        english => 100,
    },
    yamada => {
        japanese => 100,
        math => 80,
        english => 80,
    },
    tanaka => {
        japanese => 50,
        math => 40,
        english => 40,
    }, 
);  

my $result; 
print $result = CI::Algorithm->pearson($score_of{suzuki},$score_of{sato});
print "\n\n";
print $result = CI::Algorithm->pearson($score_of{suzuki},$score_of{yamada});
print "\n\n";
print $result = CI::Algorithm->pearson($score_of{yamada},$score_of{tanaka});



