use inc::Module::Install;

name           'Rapit';
all_from       'lib/Rapit/Container.pm';

requires       'Catalyst::Plugin::Bread::Board';
requires       'Catalyst::View::TT';

test_requires  'Test::More';
test_requires  'Catalyst::Test';

WriteAll;
