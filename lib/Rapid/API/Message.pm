package Rapid::API::Message;

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

# return ourselves as a plain, unblessed hashref
sub flatten {
    my ($self) = @_;

    # sorta cheating. copy ourself as a hashref
    return { %{ $self } };
}

__PACKAGE__->meta->make_immutable;
