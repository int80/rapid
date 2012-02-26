package Rapid::Script;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Rapid::Container;
use namespace::autoclean;
use Any::Moose 'Role';

# probably want to override this to return your subclassed container
has 'container' => (
    is => 'ro',
    required => 1,
    builder => 'build_container',
);
requires 'run';

1;

    
