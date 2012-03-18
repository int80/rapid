use inc::Module::Install;

name           'Rapid';
all_from       'lib/Rapid/Container.pm';

requires       'Catalyst::Plugin::Bread::Board';
requires       'Catalyst::View::TT';
requires       'AnyEvent::RPC';
requires       'Any::Moose';
requires       'MooseX::Storage';
requires       'MooseX::NonMoose';
requires       'MooseX::MarkAsMethods';
requires       'Moose::Exporter';
requires       'Math::Random::Secure';
requires       'Digest::SHA1';
requires       'Catalyst::Plugin::DBIC';
requires       'Data::UUID';
requires       'namespace::autoclean';
requires       'Config::JFDI';

test_requires  'Test::More';
test_requires  'Catalyst::Test';

WriteAll;
