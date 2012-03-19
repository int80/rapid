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
requires 'namespace::autoclean' => '0.13';
requires 'Config::JFDI';
requires 'MooseX::Traits::Pluggable';
requires 'HTML::FormHandler::Moose';
requires 'HTML::FormHandler::Model::DBIC';
requires 'DBD::Pg' => '2.19.2';
requires 'DBIx::Class' => '0.08196';

requires 'Catalyst' => '5.90011';
requires 'CatalystX::Component::Traits' => '0.16';
requires 'Catalyst::Authentication::Store::DBIx::Class' => '0.1503';
requires 'Catalyst::Plugin::Session::Store::DBIC' => '0.12';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authentication::Credential::Password';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Authorization::ACL';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Bread::Board';
requires 'Catalyst::View::TT';
requires 'Catalyst::Model::DBIC::Schema' => '0.59';


test_requires  'Test::More';
test_requires  'Catalyst::Test';

WriteAll;
