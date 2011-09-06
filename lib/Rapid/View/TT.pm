# Base Template::Toolkit-based Rapid view

# Based on Catalyst::View::TT, adds support for:
#  - static resource dependencies
#  - URI construction
#  - useful filters
#  - debugging

package Rapid::View::TT;

use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
