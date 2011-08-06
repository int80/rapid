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

has 'next_session_id' => (
    is => 'rw',
    isa => 'Int',
    default => 1,
);

has 'connections' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
);

sub get_next_session_id {
    my ($self) = @_;
    my $id = $self->next_session_id;
    $self->next_session_id($id + 1);
    return $id;
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
    
        $self->debug("Server listening on port $port");
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

    $self->warn("Got client error: " . $msg->error_message);
}

sub handle_new_connection {
    my ($self, $fh, $host, $port) = @_;
    
    my $conn; $conn = Rapit::API::Server::Connection->new(
        host   => $host,
        port   => $port,
        fh     => $fh,
        id     => $self->get_next_session_id,
        server => $self,
        finish => sub {
            $self->debug("Connection finished");
            delete $self->connections->{$conn->id};
        },
    );
    
    $conn->create_handle;
    $self->new_connection($conn);
    
    return $conn;
}

sub new_connection {
    my ($self, $conn) = @_;
    
    $self->debug("New connection from " . $conn->host . ":" . $conn->port);
}

sub DEMOLISH {
    my ($self) = @_;

    delete $self->connections->{$_} for keys %{ $self->connections };
}

__PACKAGE__->meta->make_immutable;

