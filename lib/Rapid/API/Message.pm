package Rapid::API::Message;

use Moose;
use namespace::autoclean;
use Carp qw/croak/;
extends 'Rapid::Event';

# provides serialization
with 'Rapid::Storage';
__PACKAGE__->serializable(qw/ command params is_error error_message /);

# connection this message was sent over
has 'transport' => (
    is => 'rw',
    does => 'Rapid::API::Messaging',
    weak_ref => 1,
);

# convenience method
# can pass either a Rapid::API::Message, or
# ($command_name, \%params, @keep_fields)
sub reply {
    my $self = shift;
    my $reply_or_command = shift;

    # might not still be connected
    return unless $self->transport;

    # params to copy from self to reply
    my @keep_fields;

    # reply can be an Event or a string
    my $reply;
    if (ref($reply_or_command) && $reply_or_command->DOES('Rapid::Event')) {
        # this is a message object
        $reply = $reply_or_command;
        @keep_fields = @_;
    } else {
        # we got ($command, $params, @keep_fields)
        my $command = $reply_or_command;
        my $params = shift(@_) || {};
        @keep_fields = @_;
        $reply = __PACKAGE__->new(
            command => $command,
            params => $params,
        );
    }

    # keep some params if we're replying
    my $orig_params = $self->params;
    my $reply_params = $reply->params;
    foreach my $p (@keep_fields) {
        $reply_params->{$p} = $orig_params->{$p}
            if exists $orig_params->{$p} && ! exists $reply_params->{$p};
    }

    $self->transport->push_message($reply);
}

sub reply_error {
    my ($self, $err_str) = @_;

    # might not still be connected
    return unless $self->transport;

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

#use Carp qw/cluck/;
#sub BUILD { warn "\n+++msg create\n" }
#sub DEMOLISH { warn "--msg demolish--\n\n\n" }

__PACKAGE__->meta->make_immutable;
