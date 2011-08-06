# Sample catalyst applicaion implementing Rapit
# Used for tests

package TestApp;

use Moose;
use namespace::autoclean;
use Rapit::Container;
use FindBin;

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
        container => Rapit::Container->new(
            name => 'Rapit',
            app_root => __PACKAGE__->path_to('.'),
            main_schema_name => 'RapitDB',
        ),
    },
);

__PACKAGE__->setup();

sub container {
    my ($class) = @_;

    return Rapit::Container->new(app_root => "$FindBin::Bin/..", name => 'TestApp');
}

1;

