#!/usr/bin/env perl
use Moose;
use Test::More;
use FindBin;
use Rapid::Container;

# render a template
my $c = Rapid::Container->new(app_root => "$FindBin::Bin/..");
my $view = $c->fetch('/View/TT/Instance')->get;
my $out;
$view->process(\ "foo=[% foo %]", { foo => 'bar' }, \$out);
is($out, 'foo=bar', 'TT render');

done_testing();
