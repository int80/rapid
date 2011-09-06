# Sample catalyst applicaion implementing Rapid
# Used for tests

package TestApp;

use Moose;
use namespace::autoclean;
use Rapid::Container;
use Catalyst::Runtime 5.80;

use Catalyst qw/
    Bread::Board
/;

extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config(
    name => 'TestApp',
    disable_component_resolution_regex_fallback => 1,
    default_view => 'TT',
    'Plugin::Bread::Board' => {
        container => Rapid::Container->new(
            name => 'Rapid',
            app_root => __PACKAGE__->path_to('.'),
            main_schema_name => 'RapidDB',
        ),
    },
);

__PACKAGE__->setup();

1;

