package Rapid::Event;

use Moose;
use namespace::autoclean;

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

1;
