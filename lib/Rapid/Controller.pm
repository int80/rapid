# Base Rapid controller

# Based on Catalyst::Controller

package Rapid::Controller;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
