#!/usr/bin/env perl
use Moose;
use Test::More;
use Catalyst::Test 'TestApp';

ok(request('/'), 'Root request');

done_testing();
