package Rapit::Container;

use Moose;
use Bread::Board;
use Data::Dumper;
use Template;
use namespace::autoclean;
use Rapit::Schema::RDB;
use Carp qw/croak confess/;

extends 'Catalyst::Plugin::Bread::Board::Container';

has '+name' => ( default => 'RapitBase' );

has 'log' => (
    is => 'rw',
    isa => 'Rapit::Logger',
    lazy_build => 1,
);        

has 'schema' => (
    is => 'rw',
    isa => 'Rapit::Schema::RDB',
    lazy_build => 1,
    handles => [qw/ resultset /],
);        

has 'config' => (
    is => 'rw',
    isa => 'HashRef',
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

# keep track of our global application container
my $_global_c;
sub global_context { $_global_c }

sub build_container {
    my ($self) = @_;
    
    my $c = container $self => as {
        container 'Model' => as {
            # DBIC schema
            container 'RDB' => as {
                # returns our schema object
                # requires: SchemaInfo with schema_class and connect_info
                service 'schema' => (
                    class => 'DBIx::Class::Schema',
                    block => sub {
                        my $s = shift;
                        Rapit::Schema::RDB->connect(
                            @{ $s->param('config')->db_connect_info }
                        );
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
            class        => 'Rapit::Logger',
        );

        # Configuration
        container 'Config' => as {
            service 'instance' => (
                lifecycle    => 'Singleton',
                class        => 'Rapit::Config',
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
            service 'port' => '6000';
            service 'host' => 'localhost';
                
            container 'Client' => as {
                service 'key' => '';
                            
                service 'Async' => (
                    dependencies => {
                        port => depends_on('/API/port'),
                        host => depends_on('/API/host'),
                        client_key => depends_on('/API/Client/key'),
                    },
                    class => 'Rapit::API::Client::Async',
                );
            };

            container 'Server' => as {
                service 'Async' => (
                    class => 'Rapit::API::Server::Async',
                    dependencies => {
                        port => depends_on('/API/port'),
                        host => depends_on('/API/host'),
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
