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

sub dispatch {
    my ($self, $msg, @extra) = @_;

    my $cb = $self->callbacks->{$msg->command}
        or die "unknown command " . $msg->command;

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
