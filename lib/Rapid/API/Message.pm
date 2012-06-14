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

sub reply {
    my ($self, $reply_msg) = @_;

    # keep some params if we're replying
    my $orig_params = $self->params;
    my $reply_params = $reply_msg->params;

    # params to keep
    my @keep = qw/camera_id/;

    foreach my $p (@keep) {
        $reply_params = $orig_params->{$p}
            if exists $orig_params->{$p} && ! exists $reply_params->{$p};
    }

    $self->transport->push_message($reply_msg);
}

sub reply_error {
    my ($self, $err_str) = @_;

    $self->reply($self->transport->error($err_str));
    return;
}

sub deserialize {
    my ($class, $msg, $transport) = @_;

    croak "transport required" unless $transport;
    my $unpacked = $class->unpack($msg);
    $unpacked->transport($transport);
    return $unpacked;
}

__PACKAGE__->meta->make_immutable;
