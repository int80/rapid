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

our $VERSION = v0.01;

sub BUILD {
    my $self = shift;

    return $self->build_container;
}

sub build_container {
    my ($self) = @_;
    
    return container $self => as {
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
                block        => sub {
                    return Rapit::Config->new;
                },
            );
            service 'config' => (
                block        => sub {
                    return shift->resolve(service => 'instance')->load
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
}

sub shutdown {
    my ($self) = @_;

    Rapit::Common->shutdown;
}

1;
