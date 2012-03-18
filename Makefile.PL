use inc::Module::Install;

name           'Rapid';
all_from       'lib/Rapid/Container.pm';

requires       'Catalyst::Plugin::Bread::Board';
requires       'Catalyst::View::TT';
requires       'AnyEvent';
requires       'AnyEvent::RPC';
requires       'Any::Moose';
requires       'MooseX::Storage';
requires       'Moose::Exporter';
requires       'Math::Random::Secure';
requires       'Digest::SHA1';
requires       'Catalyst::Model::DBIC::Schema';
requires       'DBIx::Class::Cursor::Cached';
requires       'Data::UUID';
requires       'namespace::autoclean';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authentication::Credential::Password';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Authorization::ACL';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Plugin::Session::State::Cookie';


test_requires  'Test::More';
test_requires  'Catalyst::Test';

WriteAll;
