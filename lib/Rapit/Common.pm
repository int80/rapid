# This is a simple role that gives quick access to common
# Rapit components

package Rapit::Common;

use Moose::Role;
use Rapit::Container;
use Rapit::Config;

# our container
sub container {
    my ($class) = @_;

    return Rapit::Container->new(app_root => Rapit::Config->get_home, name => 'TestApp');
}

# logging facility
sub logger {
    my ($class) = @_;

    return $class->container->resolve(service => 'Logger');
}
 
# RDB DBIC schema
sub schema {
    my ($class) = @_;

    return $class->container->resolve(service => 'Model/main_schema');
}

sub schema_connect_info {
    my ($class) = @_;

    my $config = $self->config;
    return Rapit::Config->get_db_connection_info;
}


sub config {
    my ($class) = @_;

    return $class->container->resolve(service => 'Config');
}

sub error { shift->logger->error(@_); }
sub warn  { shift->logger->warn(@_); }
sub info  { shift->logger->info(@_); }
sub debug { shift->logger->debug(@_); }
sub trace { shift->logger->trace(@_); }

1;
