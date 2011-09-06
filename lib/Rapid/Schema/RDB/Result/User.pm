package Rapid::Schema::RDB::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("user");
__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "user_id_seq",
  },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "password",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 128,
  },
  "customer",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
  "customer",
  "Rapid::Schema::RDB::Result::Customer",
  { id => "customer" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);
__PACKAGE__->has_many(
  "user_roles",
  "Rapid::Schema::RDB::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-08-06 17:15:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rmMpCbEEn14mzca342m1hg


# You can replace this text with custom content, and it will be preserved on regeneration
1;


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
