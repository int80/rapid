package Rapit::API::Message;

use Moose;
use namespace::autoclean;

# provides serialization
use MooseX::Storage;

with Storage();

has 'command' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has 'params' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    lazy => 1,
);

has 'is_error' => (
    is => 'rw',
    isa => 'Str',
);

has 'error_message' => (
    is => 'rw',
    isa => 'Str',
);

__PACKAGE__->meta->make_immutable;
