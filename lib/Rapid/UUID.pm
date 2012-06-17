package Rapid::UUID;

use Moose;
use namespace::autoclean;
use Data::UUID;

sub create {
    my ($class) = @_;

    return Data::UUID->new->create_str;
}

__PACKAGE__->meta->make_immutable;
