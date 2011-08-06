# TT view
package TestApp::Controller::Root;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Rapit::Controller'; }

__PACKAGE__->config(namespace => '');

sub index :Private {
    my ($self, $c) = @_;

    $c->res->body('Hello, world');
}

sub end : ActionClass('RenderView') {}

1;
