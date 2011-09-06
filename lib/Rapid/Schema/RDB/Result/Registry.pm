package Rapid::Schema::RDB::Result::Registry;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'Rapid::Schema::BaseResult';
__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("registry");
__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "registry_id_seq",
  },
  "app",
  { data_type => "varchar", is_nullable => 0, size => 127 },
  "ip",
  { data_type => "varchar", is_nullable => 0, size => 63 },
  "customer_host",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "created",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "updated",
  { data_type => "timestamp", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("registry_app_customer_host_key", ["app", "customer_host"]);
__PACKAGE__->belongs_to(
  "customer_host",
  "Rapid::Schema::RDB::Result::CustomerHost",
  { id => "customer_host" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-09-06 01:07:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8U8Qvi3+mbm1o3cjCO5nZw


# You can replace this text with custom content, and it will be preserved on regeneration
1;


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
