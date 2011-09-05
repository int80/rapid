package Rapit::API::Server::Async;

use Moose;
use namespace::autoclean;
use Rapit::API::Server::Connection;
use AnyEvent::Handle;
use AnyEvent::Socket;

with 'Rapit::API';

has 'tcp_server' => (
    is => 'rw',
);

has 'connections' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
);

*all_connections = \&all_clients;
sub all_clients {
    my ($self) = @_;

    return values %{ $self->connections };
}

sub run {
    my ($self) = @_;
    
    my $addr = $self->host;
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
    
    my $conn; $conn = Rapit::API::Server::Connection->new(
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

    foreach my $client ($self->all_clients) {
        $client->push_message($msg);
    }
}

sub DEMOLISH {
    my ($self) = @_;

    return unless $self->connections;
    delete $self->connections->{$_} for keys %{ $self->connections };
}

__PACKAGE__->meta->make_immutable;

