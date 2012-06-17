package Rapid::Storage;

use Moose::Role;
use namespace::autoclean;
use Rapid::Storage::Basic;

# make some fields serializable
sub serializable {
    my ($class, @fields) = @_;

    # need to define some attributes for the storage engine to pick up
#     foreach my $f (@fields) {
#         $class->meta->add_attribute($f => ( is => 'bare' ));
#     }

    # init our version of MooseX::Storage
    my @storage_roles = qw/Rapid::Storage::Basic/;
    $_->meta->apply($class->meta) for @storage_roles;
}

1;
