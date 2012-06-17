package Rapid::API::Server::Async;

use Moose;
use namespace::autoclean;
use Rapid::API::Server::Connection;
use AnyEvent::Handle;
use AnyEvent::Socket;
use Carp qw/croak/;

with 'Rapid::API';

has 'tcp_server' => (
    is => 'rw',
);

has 'connections' => (
    is => 'rw',
    isa => 'HashRef',
    traits => [ 'Hash' ],
    default => sub { {} },
    handles => {
        'all_connections' => 'values',
    },
);

# find client connections from a host
# there should really only be one
sub connections_for_host {
    my ($self, $host) = @_;

    croak "host required" unless $host;
    croak "connections_for_host returns a list" unless wantarray;

    my $hostid = $host->id;

    my @ret;

    foreach my $conn ($self->all_connections) {
        next unless $conn->is_logged_in;
        next unless $conn->customer_host;
        next unless $conn->customer_host->id == $hostid;

        push @ret, $conn;
    }

    return @ret;
}

sub run {
    my ($self) = @_;
    
    my $addr = $self->bind_host;
    my $port = $self->port;

    my $connect = sub {
        my ($listen_addr) = @_;
        
        my $s = tcp_server $listen_addr, $port, sub {
            my ($fh, $host, $port) = @_;
   
            my $conn = $self->handle_new_connection($fh, $host, $port);
            $self->connections->{$conn->id} = $conn;
        };
        $self->tcp_server($s);
        
        $self->register_callbacks(
            client_error => \&client_error,
        );
    
        $self->log->debug("Server listening on port $port");
    };
    
    if ($addr) {
        inet_aton $addr, sub {
            my (@addresses) = @_;
            my $listen_addr = @addresses ? format_address($addresses[0]) : undef;
            $connect->($listen_addr);
        }
    } else {
        $connect->();
    }
}

# received an error from the client
sub client_error {
    my ($self, $msg) = @_;

    $self->log->warn("Got client error: " . $msg->error_message);
}

sub handle_new_connection {
    my ($self, $fh, $host, $port) = @_;
    
    my $conn; $conn = Rapid::API::Server::Connection->new(
        host   => $host,
        port   => $port,
        fh     => $fh,
        server => $self,
        finish => sub {
            $self->log->debug("Connection finished");
            delete $self->connections->{$conn->id};
        },
    );
    
    $conn->create_handle;
    $self->new_connection($conn);
    
    return $conn;
}

sub new_connection {
    my ($self, $conn) = @_;
    
    $self->log->debug("New connection from " . $conn->host . ":" . $conn->port);
}

# send a message to all connected clients
sub broadcast {
    my ($self, $msg) = @_;

    foreach my $conn ($self->all_connections) {
        $conn->push_message($msg);
    }
}

sub DEMOLISH {
    my ($self) = @_;

    return unless $self->connections;
    delete $self->connections->{$_} for keys %{ $self->connections };
}

__PACKAGE__->meta->make_immutable;

