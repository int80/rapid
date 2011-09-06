# This is a simple role that gives quick access to common
# Rapid components

package Rapid::Common;

use Moose::Role;
use Rapid::Container;

# keep track of our parent container
has 'c' => (
    is => 'rw',
    isa => 'Rapid::Container',
    lazy_build => 1,
    weak_ref => 1,
    handles => [qw/
        config log schema resultset
    /],
);

sub _build_c {
    my ($self) = @_;

    return Rapid::Container->global_context;
}

1;
