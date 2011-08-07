#!/usr/bin/env perl

package Rapit::API::Server::Async::EchoTest;

use Moose;
extends 'Rapit::API::Server::Async';

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

extends 'Rapit::Container';

sub BUILD {
    my ($self) = @_;

    $self->fetch('/API/Server')->add_service(
        service 'EchoTest' => (
            class => 'Rapit::API::Server::Async::EchoTest',
            block => sub {
                Rapit::API::Server::Async::EchoTest->new;
            },
        )
    );
};

##

package main;

use Moose;
use Test::More;
use Bread::Board;
use AnyEvent;
use Rapit::Common;
use FindBin;

my $c = EchoTestServer->new(app_root => "$FindBin::Bin/..", name => 'AsyncAPITest');
#my $c = Rapit::Container->new(app_root => "$FindBin::Bin/..", name => 'AsyncAPITest');

my $schema = Rapit::Common->schema;

#my $server = Rapit::API::Server::Async::EchoTest->new;
my $server = $c->fetch('API/Server/EchoServer')->get;
my $client = $c->fetch('API/Client/Async')->get;

$server->run;
my $cv = AE::cv;

# create a client, connect to server
expect_error(qr/No login_key/i, "Got no login key error");

# set login_key this time
$client->client_key('fakekey');
expect_error(qr/Invalid login_key/i, "Got invalid key error");

my $customer = $schema->resultset('Customer')->create({
    name => 'test customer',
    key => 'fakekey',
});

$client->clear_callback('disconnect');
$cv = AE::cv;
$client->connect;
$cv->recv;
ok($client->is_logged_in, "Logged in");

$client->disconnect;

$customer->delete;
 
undef $client;
undef $server;
$c->shutdown;

done_testing();

sub expect_error {
    my ($err, $test) = @_;
    
    $client->clear_callback('disconnect');
    $client->clear_callback('error');

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
}
