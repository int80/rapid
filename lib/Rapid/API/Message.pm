package Rapid::API::Message;

use Moose;
use namespace::autoclean;
use Carp qw/croak/;

# provides serialization
use MooseX::Storage;

extends 'Rapid::Event';
with Storage();

# connection this message was sent over
has 'transport' => (
    is => 'rw',
    does => 'Rapid::API::Messaging',
);

*reply_error = \&reply;
sub reply {
    my ($self, $reply_msg) = @_;

    $self->transport->push_message($reply_msg);
}

sub deserialize {
    my ($class, $msg, $transport) = @_;

    croak "transport required" unless $transport;
    my $unpacked = $class->unpack($msg);
    $unpacked->transport($transport);
    return $unpacked;
}

__PACKAGE__->meta->make_immutable;
