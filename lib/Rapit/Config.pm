package Rapit::Config;

use Moose;
use namespace::autoclean;
use Config::JFDI;
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

our %configs = (); # cache
sub load {
    my ($class, $name) = @_;

    $name ||= "Rapit";

    return $configs{$name} if exists $configs{$name};

    my $home = $class->get_home;
    my %config_opts = (
        name => $name,
        path => $home,
    );

    my $config = Config::JFDI->new(%config_opts);
    $configs{$name} = $config->get;
    
    die "Failed to load config. Using '$home' as application home"
        unless keys %{$configs{$name}};

    return $configs{$name};
}

sub get_db_connection_info {
    my ($class) = @_;

    my $config_hash = $class->load;

    my $connect_info = $config_hash->{'Model::RDB'}->{connect_info}
        or die "No connect_info found for Model::RDB";

    return $connect_info;
}

__PACKAGE__->meta->make_immutable;
