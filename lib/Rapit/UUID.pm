package Rapit::UUID;

use Moose;
use namespace::autoclean;
use Data::UUID;

our $ug;

sub create {
    my ($class) = @_;

    $ug = Data::UUID->new unless $ug;
    return $ug->create_from_name_str(NameSpace_URL, 'http://github.com/int80/Rapit');
}

__PACKAGE__->meta->make_immutable;
