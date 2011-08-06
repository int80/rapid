package Rapit::Common;

use Moose::Role;
use Rapit::Container;
use File::Spec::Functions qw(rel2abs);
use File::Basename qw(dirname);

# this is gonna find the location of the rapit lib, not the
# app using rapit. figure out something better.
sub get_home {
    my ($class) = @_;

    my (undef, $path) = caller();

    $path = rel2abs($path);
    our $directory = dirname($path);
    $directory =~ s!(lib.*)$!!i;

    return $directory;
}

sub container {
    my ($class) = @_;

    return Rapit::Container->new(app_root => $class->get_home, name => 'TestApp');
}

sub logger {
    my ($class) = @_;

    return $class->container->resolve(service => 'Logger');
}

sub config { {} }

sub error { shift->logger->error(@_); }
sub warn  { shift->logger->warn(@_); }
sub info  { shift->logger->info(@_); }
sub debug { shift->logger->debug(@_); }
sub trace { shift->logger->trace(@_); }

1;
