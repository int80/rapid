package Rapid::Container;

use Moose;
use Bread::Board;
use Class::MOP;
use Data::Dumper;
use Template;
use namespace::autoclean;
use Carp qw/croak confess/;

extends 'Catalyst::Plugin::Bread::Board::Container';

has '+name' => ( default => 'Rapid', required => 1 );

has 'use_test_db' => ( is => 'rw', isa => 'Bool' );

has 'log' => (
    is => 'rw',
    isa => 'Rapid::Logger',
    lazy_build => 1,
);        

has 'schema' => (
    is => 'rw',
    isa => 'Rapid::Schema::RDB',
    lazy_build => 1,
    handles => [qw/ resultset /],
);        

has 'config' => (
    is => 'rw',
    isa => 'HashRef',
    lazy_build => 1,
);        

has 'config_instance' => (
    is => 'rw',
    isa => 'Rapid::Config',
    lazy_build => 1,
);        

our $VERSION = v0.01;

sub BUILD {
    my $self = shift;

    return $self->build_container;
}

# logger class
sub _build_log    { shift->resolve(service => 'Logger') }
 
# RDB DBIC schema
sub _build_schema { shift->fetch('Model/RDB')->resolve(service => 'schema') }

# config loaded from $app_root/$app_name(_local)?\.*
sub _build_config { shift->resolve(service => '/Config/loader') }

# config object
sub _build_config_instance { shift->resolve(service => '/Config/instance') }

# keep track of our global application container
my $_global_c;
sub global_context { $_global_c }

sub config_service {
    my ($self, $config_key, $default_value) = @_;

    return (
        block => sub {
            my ($s) = @_;
            
            # load from config file
            my $config = $s->param('config')->get;

            # parse config key (split on '/')
            my @config_key_paths = split(qr!/!, $config_key);
            my $leaf_key = pop @config_key_paths;

            # traverse config hashes
            foreach my $key (@config_key_paths) {
                $config = $config->{$key};
            }
            my $ret = $config->{$leaf_key};

            # default
            $ret = $default_value if not defined $ret;
            return $ret;
        },
        dependencies => {
            config => depends_on('/Config/instance'),
        },
    );
}

sub build_container {
    my ($self) = @_;
    
    my $c = container $self => as {
        service 'app_name' => $self->name;
        
        container 'Model' => as {
            # DBIC schema
            container 'RDB' => as {
                # returns our schema object
                # requires: SchemaInfo with schema_class and connect_info
                service 'schema' => (
                    class => 'DBIx::Class::Schema',
                    lifecycle => 'Singleton',
                    block => sub {
                        my $s = shift;

                        my $connect_info =
                            $self->use_test_db ?
                                $s->param('config')->test_db_connect_info :
                                $s->param('config')->db_connect_info;

                        Class::MOP::load_class('Rapid::Schema::RDB');

                        my $schema = Rapid::Schema::RDB->connect(@$connect_info);

                        if ($self->use_test_db) {
                            # initialize db
                            $self->log->debug("Deploying schema to test DB");
                            $schema->deploy;
                        }

                        return $schema;
                    },
                    dependencies => {
                        config => depends_on('/Config/instance'),
                    },
                );
            };
        };

        # Log facility
        service 'Logger' => (
            lifecycle    => 'Singleton',
            class        => 'Rapid::Logger',
        );

        # Configuration
        container 'Config' => as {
            service 'instance' => (
                lifecycle    => 'Singleton',
                class        => 'Rapid::Config',
                dependencies => [ depends_on('/app_name'), depends_on('/app_root') ],
            );
            service 'loader' => (
                block => sub {
                    shift->parent->resolve(service => 'instance')->get;
                },
            );
        };
        
        # API
        container 'API' => as {
            service 'port' => $self->config_service('api/port', 6000);
            service 'bind_host' => $self->config_service('api/bind_host', '');
            service 'host' => $self->config_service('api/host', 'localhost');

            container 'Client' => as {
                service 'key' => '';
                            
                service 'Async' => (
                    dependencies => {
                        port => depends_on('/API/port'),
                        host => depends_on('/API/host'),
                        client_key => depends_on('/API/Client/key'),
                    },
                    class => 'Rapid::API::Client::Async',
                );
            };

            container 'Server' => as {
                service 'Async' => (
                    class => 'Rapid::API::Server::Async',
                    dependencies => {
                        port => depends_on('/API/port'),
                        bind_host => depends_on('/API/bind_host'),
                    },
                );
            };
        };

        container 'View' => as {
            # TT view
            container 'TT' => as {
                # TT config
                service 'TEMPLATE_EXTENSION' => '.tt';
                service 'INCLUDE_PATH'       => (
                    block => sub {
                        my $root = (shift)->param('app_root');
                        [ $root->subdir('root/templates')->stringify ]
                    },
                    dependencies => [ depends_on('/app_root') ]
                );

                # get a Template instance for rendering templates outside of catalyst
                service 'Instance' => (
                    class => 'Template',
                    block => sub {
                        my $s = shift;

                        # get TT config
                        my @service_list = $self->fetch('View/TT')->get_service_list;
                        # ignore this instance
                        @service_list = grep { $_ ne 'Instance' } @service_list;
                        my %tt_config = map {
                            $_ => $self->fetch('View/TT')->get_service($_)->get
                        } @service_list;
                        return Template->new(\%tt_config);
                    }
                );
            };
        };
    };

    $_global_c = $c;
    return $c;
}

1;
