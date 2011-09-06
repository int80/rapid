# Role which enables the construction and sending of messages
# (common code for Client and Server::Connection)

package Rapid::API::Messaging;

use Moose::Role;
use Rapid::API::Message;
use Carp qw/croak/;
use namespace::autoclean;

has 'h' => (
    is => 'rw',
    isa => 'AnyEvent::Handle',
);

sub push {
    my ($self, $cmd, $params) = @_;

    croak "no command specified" unless $cmd;
    
    $params ||= {};
    
    my $msg = Rapid::API::Message->new(
        command => $cmd,
        params  => $params,
    );
    
    return $self->push_message($msg->pack);
}

sub push_error {
    my ($self, $err) = @_;

    $self->log->info("Returning error $err");
    
    my $err_msg = new Rapid::API::Message(
        is_error => 1,
        error_message => $err,
        command => 'error',
    );
    
    return $self->push_message($err_msg->pack);
}

sub push_message {
    my ($self, $msg) = @_;
    
    return if ! $self->h || $self->h->destroyed;

    # get flattened message if it's a R::A::Message object
    if ($msg && ref $msg ne 'HASH' && ref $msg ne 'ARRAY') {
        # some blessed nonsense, it better serialize
        croak "Tried to send a message but $msg cannot serialize itself"
            unless $msg->can('pack');
        $msg = $msg->pack;
    }

    unless ($msg->{command}) {
        $self->log->error("Tried to push message with no command");
        return;
    }

    if (lc $msg->{command} eq 'ping') {
        $self->last_ping_time(Time::HiRes::time());
    }
    
    return $self->h->push_write(json => $msg);
}

1;
