#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use CI::Algorithm::Pearson;
use List::Util qw/shuffle/;
use List::MoreUtils qw/uniq/;
use Perl6::Say;

use Data::Dumper;
local $Data::Dumper::Maxdepth = 3;

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
        science => 50,
        japanese => 50,
        math => 40,
        english => 40,
    }, 
);  

my $result; 

say "suzuki & sato";
say $result = CI::Algorithm::Pearson->calc($score_of{suzuki},$score_of{sato});
say;
say "suzuki & yamada"; 
say $result = CI::Algorithm::Pearson->calc($score_of{suzuki},$score_of{yamada});
say;
say "yamada & tanaka";
say $result = CI::Algorithm::Pearson->calc($score_of{yamada},$score_of{tanaka});



