# This is a simple role that gives quick access to common
# Rapit components

package Rapit::Common;

use Moose::Role;
use Rapit::Container;

# keep track of our parent container
has 'c' => (
    is => 'rw',
    isa => 'Rapit::Container',
    lazy_build => 1,
    weak_ref => 1,
    handles => [qw/
        config log schema resultset
    /],
);

sub _build_c {
    my ($self) = @_;

    return Rapit::Container->global_context;
}

1;
