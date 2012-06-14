package Rapid::LazySchema;

use Moose;
use namespace::autoclean;

has '_schema' => (
    is => 'ro',
    isa => 'DBIx::Class::Schema',
    lazy_build => 1,
    handles => [qw/ resultset /],
);

has 'config_obj' => (
    is => 'ro',
    required => 1,
);

sub _build__schema {
    my ($self) = @_;
    
    #my $connect_info =
    #    $self->use_test_db ?
    #        $_config->test_db_connect_info :
    #        $_config->db_connect_info;

    my $_config = $self->config_obj;
    my $connect_info = $_config->db_connect_info;

    my $schema_class = $_config->schema_class;
    Class::MOP::load_class($schema_class);

    my $schema = $schema_class->connect(@$connect_info);

    #if ($self->use_test_db) {
    #    # initialize db
    #    $self->log->debug("Deploying schema to test DB");
    #    $schema->deploy;
    #}

    return $schema;
}

__PACKAGE__->meta->make_immutable;

