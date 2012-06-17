package Rapid::Storage;

use Moose::Role;
use namespace::autoclean;
with 'MooseX::Storage::DBIC';

use Rapid qw/$schema/;
sub schema { $schema }

1;
