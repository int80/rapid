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

    $self->fetch('API/Server/Async')->add_service(
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
use TestApp;
use Bread::Board;
use AnyEvent;
use Rapit::Common;

my $c = Rapit::Common->container;

#my $server = Rapit::API::Server::Async::EchoTest->new;

my $server = $c->fetch('API/Server/Async')->get;
my $client = $c->fetch('API/Client/Async')->get;

$server->run;

# create a client, connect to server
my $cv = AE::cv;
$client->register_callbacks(
    logged_in => sub {
        warn "logged in";
    },
    disconnect => sub {
        $cv->send;
    },
);
$client->run;

$cv->recv;

undef $client;
undef $server;
undef $c;

done_testing();
