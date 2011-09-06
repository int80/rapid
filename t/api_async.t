#!/usr/bin/env perl

package Rapid::API::Server::Async::EchoTest;

use Moose;
extends 'Rapid::API::Server::Async';

before 'run' => sub {
    my ($self) = @_;
    
    $self->register_callbacks(
        echo => \&echo,
    );
};

sub echo {
    my ($self, $msg, $conn) = @_;

    $conn->push($msg->command, {
        %{ $msg->params },
        echo => 1,
    })
}

##

package EchoTestServer;

use Moose;
use Bread::Board;

extends 'Rapid::Container';

sub BUILD {
    my ($self) = @_;

    container $self => as {
        container 'Test' => as {
            service 'EchoTest' => (
                class        => 'Rapid::API::Server::Async::EchoTest',
                dependencies => {
                    port => depends_on('/API/port'),
                },
            );
        };
    };
}
##

package main;

use Moose;
use Test::More tests => 4;
use Bread::Board;
use AnyEvent;
use FindBin;
use Rapid::API;

my %test_customer = (
    name => '__test customer__',
    key => 'fakekey',
);

# construct server
my $c = EchoTestServer->new(
    app_root => "$FindBin::Bin/..",
    use_test_db => 1,
);

# fetch DB schema
my $schema = $c->schema;
my $customer_rs = $schema->resultset('Customer');

# make sure our test account doesn't exist yet
$customer_rs->search(\%test_customer)->delete_all;

# fetch server and client
my $server = $c->fetch('/Test/EchoTest')->get;
my $client = $c->fetch('/API/Client/Async')->get;

# run the server
$server->run;

my $cv = AE::cv;

$client->register_callback(logged_in => sub { $cv->send });

# create a client, connect to server
expect_error(qr/No login_key/i, "Got no login key error");

# set login_key this time
$client->client_key('fakekey');
expect_error(qr/Invalid login_key/i, "Got invalid key error");

# create a valid login
my $customer = $customer_rs->create(\%test_customer);

# terminate busyloop when login complete
$cv = AE::cv;

$client->connect;

$cv->recv;
ok($client->is_logged_in, "Logged in");

# send a message, we should receive it back
$cv = AE::cv;
my $params = { param => 123 };
$client->register_callback(echo => sub {
    my ($self, $msg) = @_;
    is_deeply({ %$params, echo => 1 }, $msg->params, "Got echo");
    $cv->send;
});
$client->push_message(message(echo => $params));
$cv->recv;

$client->disconnect;

$customer->delete;
 
undef $client;
undef $server;

done_testing();

sub expect_error {
    my ($err, $test) = @_;
    
    $client->clear_callbacks('disconnect');
    $client->clear_callbacks('error');

    my $err_handler = sub {
        my ($self, $msg) = @_;
        my $error_message = $msg->error_message;
        like($error_message, $err, $test);
        $cv->send;
    };
    
    $client->register_callbacks(
        error => $err_handler,
        disconnect => $err_handler,
    );
    $cv = AE::cv;
    $client->connect;
    $cv->recv;

    $client->clear_callbacks('disconnect');
    $client->clear_callbacks('error');

    # restore default handlers
    $client->_register_default_handlers;
}
