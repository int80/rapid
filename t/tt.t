#!/usr/bin/env perl
use Moose;
use Test::More;
use TestApp;

# render a template
my $c = TestApp->container;
my $view = $c->fetch('View/TT/Instance')->get;
my $out;
$view->process(\ "foo=[% foo %]", { foo => 'bar' }, \$out);
is($out, 'foo=bar', 'TT render');

done_testing();
