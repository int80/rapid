package Rapid::Config;

use Moose;

use Config::JFDI;
use File::Spec::Functions qw(rel2abs);
use File::Basename qw(dirname);
use File::Temp qw/tempfile/;
use namespace::autoclean;

has 'app_name' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has 'app_root' => (
    is => 'rw',
    required => 1,
#    lazy_build => 1,
);

# this is gonna find the location of the rapit lib, not the
# app using rapit. currently unused
sub _build_app_root {
    my ($class) = @_;

    my (undef, $path) = caller();

    $path = rel2abs($path);
    our $directory = dirname($path);
    $directory =~ s!(lib.*)$!!i;

    return $directory;
}

sub schema_class {
    my ($self) = @_;

    return $self->get->{schema_class} || 'Rapid::Schema::RDB';
}

our %configs = (); # cache
sub get {
    my ($self) = @_;

    my $name = $self->app_name;

    return $configs{$name} if exists $configs{$name};

    my $home = $self->app_root;
    my %config_opts = (
        name => $name,
        path => $home . '',
    );

    my $config = Config::JFDI->new(%config_opts);
    $configs{$name} = $config->get;
    
    die "Failed to load config for $name. Using '$home' as application home"
        unless keys %{$configs{$name}};

    return $configs{$name};
}

sub db_connect_info {
    my ($class) = @_;

    my $config_hash = $class->get;

    my $connect_info = $config_hash->{'Model::RDB'}->{connect_info}
        or die "No connect_info found for Model::RDB";

    return $connect_info;
}

sub test_db_connect_info {
    my ($self) = @_;

    # create temp db file and set our config to use it
    my ($fh, $db) = tempfile();

    return [ 'dbi:SQLite:' . $db ];
}

__PACKAGE__->meta->make_immutable;
