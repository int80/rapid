# This is a role that allows callbacks to be set on an instance

package Rapid::EventDispatcher;

use Moose::Role;
use namespace::autoclean;

use Moose::Exporter;
use Rapid::Event;

Moose::Exporter->setup_import_methods(
    as_is => [qw/
        event
    /],
);

sub event {
    my ($event, $params) = @_;

    $params ||= {};
    
    return Rapid::Event->new(
        command => $event,
        params => $params,
    );
};

# \%event => [ \&cb1, \&cb2 ... ]
has 'callbacks' => (
    is => 'rw',
    isa => 'HashRef[ArrayRef[CodeRef]]',
    default => sub { {} },
    lazy => 1,
    
    traits  => ['Hash'],
    handles => {
        set_callbacks   => 'set',
        get_callbacks   => 'get',
        clear_callbacks => 'delete',
        has_callbacks   => 'exists',
    },
);

*register_callback = \&register_callbacks;
sub register_callbacks {
    my ($self, %cbs) = @_;
    
    foreach my $k (keys %cbs) {
        $self->callbacks->{$k} ||= [];

        # don't add the same callback twice
        next if grep { $_ == $cbs{$k} } @{ $self->callbacks->{$k} };
        
        push @{ $self->callbacks->{$k} }, $cbs{$k};
    }
}

sub dispatch {
    my ($self, $msg, @extra) = @_;

    my $cbs = $self->callbacks->{$msg->command};

    if (! $cbs || ! @$cbs) {
        $self->c->log->debug("unhandled command on $self: " . $msg->command);
        $self->c->log->warn("unhandled error: " . $msg->error_message) if $msg->is_error;
        return 0;
    }

    # call each registered callback
    foreach my $cb (@$cbs) {
        eval {
            $self->$cb($msg, @extra);
        };

        if ($@) {
            $self->c->log->warn("Error running " . $msg->command . " handler $cb: $@");
            return;
        }
    }

    return 1;
}

1;
