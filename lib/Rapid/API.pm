# Base for API functionality
# Provides simple event callback functionality

package Rapid::API;

use Moose::Role;
use Moose::Exporter;
use namespace::autoclean;

with 'Rapid::Common';

Moose::Exporter->setup_import_methods(
    as_is => [qw[
                    message
            ]],
);

requires 'run';

has 'port' => (
    is => 'rw',
    isa => 'Int',
    required => 1,
);

has 'host' => (
    is => 'rw',
    isa => 'Undef|Str',
#    lazy => 1,
#    builder => 'default_host_builder',
);

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

# handy message constructor
sub message {
    my ($command, $params) = @_;

    $params ||= {};
    
    return Rapid::API::Message->new(
        command => $command,
        params => $params,
    );
};

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
        $self->log->debug("unhandled command on $self: " . $msg->command);
        $self->log->warn("unhandled error: " . $msg->error_message) if $msg->is_error;
        return 0;
    }

    # call each registered callback
    foreach my $cb (@$cbs) {
        eval {
            $self->$cb($msg, @extra);
        };

        if ($@) {
            $self->log->warn("Error running " . $msg->command . " handler $cb: $@");
            return;
        }
    }

    return 1;
}

1;
