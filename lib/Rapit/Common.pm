# This is a simple role that gives quick access to common
# Rapit components

package Rapit::Common;

use Moose::Role;
use Rapit::Container;
use Rapit::Config;
use Bread::Board;
use Data::Dumper;

our $_container;
sub c {
    my ($class) = @_;

    return $_container if $_container;
    
    $_container = Rapit::Container->new(app_root => Rapit::Config->get_home, name => 'TestApp');

    return $_container;
}

sub shutdown {
    undef $_container;
}

# logging facility
sub logger {
    my ($class) = @_;

    return $class->c->resolve(service => 'Logger');
}
 
# RDB DBIC schema
sub schema {
    my ($class) = @_;

    my $rdb_container = $class->c->fetch('Model/RDB')->resolve(service => 'schema');
}

sub config {
    my ($class) = @_;

    return $class->c->resolve(service => 'Config');
}

sub error { shift->logger->error(@_); }
sub warn  { shift->logger->warn(@_); }
sub info  { shift->logger->info(@_); }
sub debug { shift->logger->debug(@_); }
sub trace { shift->logger->trace(@_); }

1;
