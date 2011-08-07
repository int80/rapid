# Base for API functionality
# Provides simple event callback functionality

package Rapit::API;

use Moose::Role;
use namespace::autoclean;

with 'Rapit::Common';

requires 'run';

has 'port' => (
    is => 'rw',
    isa => 'Int',
    required => 1,
);

has 'host' => (
    is => 'rw',
    isa => 'Str',
#    lazy => 1,
#    builder => 'default_host_builder',
);

has 'callbacks' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
    lazy => 1,
);

sub register_callbacks {
    my ($self, %cbs) = @_;
    
    foreach my $k (keys %cbs) {
        $self->callbacks->{$k} = $cbs{$k};
    }
}

sub clear_callback {
    my ($self, $cb) = @_;

    delete $self->callbacks->{$cb};
}

sub dispatch {
    my ($self, $msg, @extra) = @_;

    my $cb = $self->callbacks->{$msg->command};

    unless ($cb) {
        $self->debug("unhandled command " . $msg->command);
        $self->warn("unhandled error: " . $msg->error_message) if $msg->is_error;
        return 0;
    }

    eval {
        $self->$cb($msg, @extra);
    };

    if ($@) {
        $self->warn("Error running " . $msg->command . " handler: $@");
        return;
    }

    return 1;
}

1;
