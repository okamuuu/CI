use inc::Module::Install;
name 'CI';
all_from 'lib/CI.pm';

requires 'Sub::Retry';
requires 'Cache::FileCache';
requires 'WebService::Simple';
tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
