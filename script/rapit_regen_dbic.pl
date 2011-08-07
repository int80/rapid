#!/usr/bin/perl

use Moose;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Rapit::Config;
use DBIx::Class::Schema::Loader qw/ make_schema_at /;

my $connection_info = Rapit::Config->get_db_connection_info;

make_schema_at (
    'Rapit::Schema::RDB', {
        debug => 0,
        dump_directory => "$FindBin::Bin/../lib/",
        use_moose => 1,
        use_namespaces => 1,
        naming => 'v8',
        generate_pod => 0,
        overwrite_modifications => 0,
        moniker_map => {},
        components => [qw/ InflateColumn::DateTime /],
    },
    $connection_info,
);
