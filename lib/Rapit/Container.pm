package Rapit::Container;

use Moose;
use Bread::Board;
use Data::Dumper;
use Template;
use namespace::autoclean;

extends 'Catalyst::Plugin::Bread::Board::Container';

our $VERSION = v0.01;

sub BUILD {
    my $self = shift;

    container $self => as {

        service 'main_schema_name' => 'Rapit::Schema::IDB';
        
        container 'Model' => as {
            # DBIC schema
            container 'DBIC' => as {
                service 'schema_class' => (
                    block => sub {
                        shift->param('main_schema_name');
                    },
                    dependencies => [ depends_on('/main_schema_name') ],
                );
                service 'connect_info' => [
                    'dbi:mysql:my_app_db',
                    'me',
                    '****'
                ];
            };
        };

        # Log facility
        service 'Logger' => (
            lifecycle    => 'Singleton',
            class        => 'Rapit::Logger',
        );
        
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
