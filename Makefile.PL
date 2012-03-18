use inc::Module::Install;

name           'Rapid';
all_from       'lib/Rapid/Container.pm';

requires 'AnyEvent';
requires 'AnyEvent::RPC';
requires 'Any::Moose';
requires 'MooseX::Storage';
requires 'MooseX::NonMoose';
requires 'MooseX::MarkAsMethods';
requires 'Moose::Exporter';
requires 'Math::Random::Secure';
requires 'Digest::SHA1';
requires 'DBIx::Class::Cursor::Cached';
requires 'Data::UUID';
requires 'namespace::autoclean';
requires 'Config::JFDI';
requires 'CatalystX::Component::Traits';
requires 'MooseX::Traits::Pluggable';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authentication::Credential::Password';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Authorization::ACL';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Bread::Board';
requires 'Catalyst::View::TT';
requires 'Catalyst::Model::DBIC::Schema';


test_requires  'Test::More';
test_requires  'Catalyst::Test';

WriteAll;
