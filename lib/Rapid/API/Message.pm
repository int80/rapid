package Rapid::API::Message;

use Moose;
use namespace::autoclean;

# provides serialization
use MooseX::Storage;

with 'Rapid::Event';
with Storage();

__PACKAGE__->meta->make_immutable;
