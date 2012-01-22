# Base for API functionality
# Provides simple event callback functionality

package Rapid::API;

use Moose::Role;
use Moose::Exporter;
use AnyEvent;
use namespace::autoclean;

with 'Rapid::Common';
with 'Rapid::EventDispatcher';

Moose::Exporter->setup_import_methods(
    as_is => [qw/
        message
    /],
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
#    default => '0.0.0.0',
#    lazy => 1,
#    builder => 'default_host_builder',
);

has 'bind_host' => (
    is => 'rw',
    isa => 'Undef|Str',
);

has '_stdin_watcher' => (
    is => 'rw',
);

sub start_interactive_console {
    my ($self) = @_;

    # read from stdin
    my $w = AnyEvent->io(
        fh => \*STDIN,
        poll => 'r',
        cb => sub {
            chomp (my $input = <STDIN>);

            return unless $input;
            
            # parse input ("command param1=a param2=b")
            my ($command, $params) = $input =~ /^\s*(\w+)\s*(.*)$/sm;
            return unless $command;

            # see if there is a handler for the command
            my $cbs = $self->callbacks->{$command};
            if (! $cbs || ! @$cbs) {
                warn "Unknown command: $command\n";
                return;
            }

            # parse params
            $params ||= '';
            my %params;
            # split on space
            my @pairs = split(/\s+/, $params);
            foreach my $kv (@pairs) {
                # split on =
                my ($k, $v) = split('=', $kv);

                if (! $k) {
                    warn "Invalid parameter format: $kv. Should be in form param=value\n";
                    next;
                }
                
                $params{$k} = $v;
            }

            $self->dispatch(message($command, \%params));
        },
    );

    $self->_stdin_watcher($w);
}

# handy message constructor
sub message {
    my ($command, $params) = @_;

    $params ||= {};
    
    return Rapid::API::Message->new(
        command => $command,
        params => $params,
    );
};

1;
