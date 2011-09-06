package Rapid::Schema::RDB::Result::Contact;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'Rapid::Schema::BaseResult';

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("contact");
__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "contact_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 1 },
  "request",
  { data_type => "text", is_nullable => 1 },
  "email",
  { data_type => "text", is_nullable => 1 },
  "phone",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-09-05 20:38:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:T+m/FJNawVkHZxf6n4h8wQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
