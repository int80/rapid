package Rapid::Catalyst;

use Moose;
extends 'Catalyst';

# detach, log error
sub error_detach {
    my ($self, $err) = @_;

    $self->log->error("Detaching with error: $err");
}

__PACKAGE__->meta->make_immutable;
