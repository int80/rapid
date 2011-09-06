#!/usr/bin/perl

use Moose;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Rapid::Container;
use DBIx::Class::Schema::Loader qw/ make_schema_at /;

my $c = Rapid::Container->new(
    app_root => "$FindBin::Bin/..",
);

my $connection_info = $c->config_instance->db_connect_info;

make_schema_at (
    'Rapid::Schema::RDB', {
        result_base_class => 'Rapid::Schema::BaseResult',
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
