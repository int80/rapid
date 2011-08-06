package Rapit::API::Client::Async;

use Moose;    
use namespace::autoclean;
use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle;
use Data::Dumper;
use Rapit::API::Message;

with 'Rapit::API::Client';

has 'port' => (
    is => 'rw',
    isa => 'Int',
    required => 1,
);

has 'h' => (
    is => 'rw',
);

has 'is_connected' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

has 'is_logged_in' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

has 'client' => (
    is => 'rw',
    clearer => 'clear_client',
);

has 'connect_timer' => (
    is => 'rw',
);

sub run {
    my ($self) = @_;
    
    $self->register_callbacks(
        logged_in => \&logged_in,
        error     => \&server_error,
    );
    
    my $t = AnyEvent->timer(
        after => 0,
        interval => 5,
        cb => sub {
            $self->connect unless $self->is_connected;
        }
    );
    $self->connect_timer($t);
}

sub push_error {
    my ($self, $msg, $params) = @_;

    # send error back to the server
    $self->push('client_error', $params, {
        is_error => 1, error_message => $msg,
    });
}

sub push {
    my ($self, $cmd, $params, $msg_args) = @_;

    $params   ||= {};
    $msg_args ||= {};

    unless ($self->is_connected) {
        $self->warn("Trying to send $cmd message on unconnected client");
        return;
    }

    my $msg = new Rapit::API::Message(
        %$msg_args,
        command => $cmd,
        params  => $params,
    );

    return $self->h->push_write(json => $msg->pack);
}

# reset connection
sub cleanup {
    my ($self) = @_;

    $self->h->destroy if $self->h;
    $self->is_connected(0);
    $self->is_logged_in(0);
    $self->clear_client;
}

sub connect {
    my ($self) = @_;
    
    my $hoststr = $self->host . ":" . $self->port;
    $self->debug("Attempting to connect to $hoststr");
    
    my $h;
    
    my $client = tcp_connect $self->host, $self->port, sub {
        my ($fh) = @_;
        
        unless ($fh) {
            $self->error("Failed to connect to $hoststr");
            $self->cleanup;
            return;
        }
                
        $h = new AnyEvent::Handle
            fh => $fh,            
            on_error => sub {
                my (undef, $fatal, $msg) = @_;
                
                if ($fatal) {
                    $self->warn("Fatal connection error: $msg");
                } else {
                    $self->debug("Non-fatal connection error: $msg");
                }
                
                $self->cleanup;
            },
            on_eof => sub {
                $self->warn("Lost connection to $hoststr");
                $self->cleanup;
            },
            on_read => sub {
                $h->push_read(json => sub {
                    my (undef, $data) = @_;
                    $self->trace(Dumper($data));
                    $self->parse_message($data);
                });
            };

        $self->h($h);
        $self->connection_established;
    };
    
    $self->client($client);
}

sub connection_established {
    my ($self) = @_;
    
    $self->debug("Connected");
    $self->is_connected(1);
    $self->is_logged_in(0);

    # log in
    my $client_key = $self->client_key;
    $self->push(login => {
        login_key => $client_key,
        host_name => `hostname -f`, # Int80::Util->hostname,
    });
}

sub logged_in {
    my ($self, $msg) = @_;
    
    my $params = $msg->params;
    $self->is_logged_in(1);
    $self->debug("Logged in as $params->{customer_name}");
}

sub server_error {
    my ($self, $msg) = @_;
    
    $self->error("Server returned error: " . $msg->error_message);
    if ($self->is_connected && $self->h && ! $self->is_logged_in) {
        # if we are not logged in and we got an error we should disconnect and reconnect later
        $self->debug("Disconnecting");
        $self->dispatch(Rapit::API::Message->new(command => 'disconnect'));
        $self->h->push_shutdown;
        $self->cleanup;
    }
}

sub parse_message {
    my ($self, $msg_hash) = @_;
    
    my $msg = Rapit::API::Message->unpack($msg_hash)
        or return $self->error("Failed to unpack message");
        
    # call appropriate method
    my $ok = eval {
        return $self->dispatch($msg);
    };
    
    unless ($ok) {
        my $err = $@ || '(unknown error)';
        $self->error("Caught error handling " . $msg->command . " command: $err");
        return;
    }
}

__PACKAGE__->meta->make_immutable;

