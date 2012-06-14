package Rapid::API::Client::Async;

use Moose;    
use namespace::autoclean;
use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle;
use Data::Dumper;
use Rapid::API::Message;

with 'Rapid::API::Client';
with 'Rapid::API::Messaging';

has 'port' => (
    is => 'rw',
    isa => 'Int',
    required => 1,
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

sub BUILD {
    my ($self) = @_;

    $self->_register_default_handlers;
}

sub _register_default_handlers {
    my ($self) = @_;
    
    $self->register_callbacks(
        logged_in => \&logged_in,
        error     => \&server_error,
    );
}

sub run {
    my ($self) = @_;
        
    my $t = AnyEvent->timer(
        after => 0,
        interval => 5,
        cb => sub {
            $self->connect unless $self->is_connected;
        }
    );
    $self->connect_timer($t);
}

before 'push_message' => sub {
    my ($self, $cmd, $params, $msg_args) = @_;

    unless ($self->is_connected) {
        $self->log->warn("Trying to send $cmd message on unconnected client");
        return;
    }
};

sub disconnect { shift->cleanup }

# reset connection
sub cleanup {
    my ($self) = @_;

    $self->is_connected(0);
    $self->is_logged_in(0);
    $self->clear_client;
    $self->h->destroy if $self->h;
}

sub connect {
    my ($self) = @_;
    
    my $hoststr = $self->host . ":" . $self->port;
    $self->log->debug("Attempting to connect to $hoststr");
    
    my $h;
    
    my $client = tcp_connect $self->host, $self->port, sub {
        my ($fh) = @_;
        
        unless ($fh) {
            $self->log->error("Failed to connect to $hoststr");
            $self->cleanup;
            return;
        }
                
        $h = new AnyEvent::Handle
            fh => $fh,            
            on_error => sub {
                my (undef, $fatal, $msg) = @_;
                
                if ($fatal) {
                    $self->log->warn("Fatal connection error: $msg");
                } else {
                    $self->log->debug("Non-fatal connection error: $msg");
                }
                
                $self->cleanup;
            },
            on_eof => sub {
                $self->log->warn("Lost connection to $hoststr");
                $self->cleanup;
            },
            on_read => sub {
                $h->push_read(json => sub {
                    my (undef, $data) = @_;
                    $self->log->trace(Dumper($data));
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
    
    $self->log->debug("Connected");
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
    $self->log->debug("Logged in as $params->{customer_name}");
}

sub server_error {
    my ($self, $msg) = @_;
    
    $self->log->error("Server returned error: " . $msg->error_message);
    if ($self->is_connected && $self->h && ! $self->is_logged_in) {
        # if we are not logged in and we got an error we should disconnect and reconnect later
        $self->log->debug("Disconnecting");
        $self->dispatch(Rapid::API::Message->new(
            command => 'disconnect',
            is_error => 1,
            error_message => $msg->error_message,
        ));
        $self->h->push_shutdown;
        $self->cleanup;
    }
}

sub parse_message {
    my ($self, $msg_hash) = @_;
    
    my $msg = Rapid::API::Message->deserialize($msg_hash, $self)
        or return $self->log->error("Failed to unpack message");
        
    # call appropriate method
    my $ok = eval {
        $self->dispatch($msg);
    };
    
    unless (defined $ok) {
        my $err = $@ || '(unknown error)';
        $self->log->error("Caught error handling " . $msg->command . " command: $err");
        return;
    }
}

__PACKAGE__->meta->make_immutable;

