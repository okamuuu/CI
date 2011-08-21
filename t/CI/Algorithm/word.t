#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use Path::Class ();

use_ok('CI::Algorithm::Word');

subtest 'I want to know bag-of-words.' => sub {

    my $words =
        '昨日ラーメン食べに行ったら、先輩に会った。'
      . ' 先輩は塩ラーメンを食べてた。俺は味噌ラーメンを食べた。';

    my $bag_of_words = CI::Algorithm::Word->get_words_counts($words);

    is $bag_of_words->{'ラーメン'}, 3;
    is $bag_of_words->{'先輩'}, 2;
};

done_testing();

