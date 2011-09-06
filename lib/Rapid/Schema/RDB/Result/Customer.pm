package Rapid::Schema::RDB::Result::Customer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table("customer");
__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "bigint",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "customer_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 0 },
  "created",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "address",
  { data_type => "text", is_nullable => 1 },
  "phone",
  { data_type => "text", is_nullable => 1 },
  "email",
  { data_type => "text", is_nullable => 1 },
  "notes",
  { data_type => "text", is_nullable => 1 },
  "key",
  {
    data_type => "varchar",
    default_value => \"NULL::character varying",
    is_nullable => 1,
    size => 255,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "customer_hosts",
  "Rapid::Schema::RDB::Result::CustomerHost",
  { "foreign.customer" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);
__PACKAGE__->has_many(
  "users",
  "Rapid::Schema::RDB::Result::User",
  { "foreign.customer" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-08-06 19:51:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HjzELPR2QLzy2RLVkIKWxQ

before 'delete' => sub {
    my ($self) = @_;

    $self->customer_hosts->delete_all;

    # users too?
};

__PACKAGE__->meta->make_immutable;

