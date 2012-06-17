# overrides for MooseX::Storage::Engine

# this adds the ability to serialize fields in an object that do not
# have attribute accessors, as well as basic handling of DBIC column
# accessors and relationships

package Rapid::Storage::Traits::Default;

use Moose::Role;
use namespace::autoclean;
use Scalar::Util qw/reftype blessed/;
use feature 'switch';
#use Data::Dump qw/ddx/;

override collapse_attribute_value => sub {
    my ($self, $attr, $options) = @_;

    # fast path: hashref field on instance
    # instance this attribute is attached to
    my $obj = $self->object;
    my $name = $attr->name;

    my $value;
    $value = $obj->{$name} if $obj && ref($obj) && reftype($obj) eq 'HASH' &&
        exists $obj->{$name};
    warn "got hashref" if defined $value;
    return $value if defined $value;

    $value = $attr->get_value($obj);
    if (defined $value && $attr->has_type_constraint) {
        # simple moose attribute with accessor
        warn "got serializable moose attribute";
        return super();
    } else {
        # dbic?
        if ($obj && $obj->DOES('DBIx::Class::Core')) {
            my $src = $obj->result_source;

            # relationship?
            if ($src->has_relationship($name)) {
                # get relations
                my $rel_rs = $obj->related_resultset($name);
                die "expected related rs for $name on $obj"
                    unless $rel_rs;

                # are we expecting a scalar or array?
                my $info = $obj->relationship_info($name);
                if ($info->{attrs}{accessor} eq 'multi') {
                    # have many possible related rows
                    my @rows = $rel_rs->all;

                    $value = \@rows;
                } else {
                    # expecting single rel. hope that's right
                    $value = $rel_rs->single;
                }
            } else {
                # column accessor?
                if (exists $src->columns_info->{$name}) {
                    $value = $obj->get_column($name);
                }
            }
        }

        unless (defined $value) {
            # try to call method of $name
            $value = $obj->$name if blessed($obj) && $obj->can($name);
        }

        # temp warning
        warn "got $name which does not have an attribute accessor or DBIC column accessor"
            unless defined $value;
    }

    return unless defined $value;

    # recursively serialize a value, if possible
    my $serialize_obj = sub {
        my $v = shift;
        return unless defined $v;

        if (blessed($v) && $v->isa('Moose::Object') && $v->DOES('Rapid::Storage')) {
            return $v->pack;
        }

        return $v;
    };

    # see if what we are returning is serializable itself
    given (ref $value) {
        when ('HASH') {
            # TODO: search values for serializable
            warn "todo";
        }
        when ('ARRAY') {
            # serialize all objects in array
            my @serialized;
            foreach my $v (@$value) {
                push @serialized, $serialize_obj->($v);
            }

            $value = \@serialized;
        }
        when ('') {
            # not a reference, leave as-is
        }
        default {
            if (blessed $value) {
                # maybe it is serializable?
                $value = $serialize_obj->($value);
            } else {
                # some sort of reference we don't know how to serialize
                # (code, glob, etc)
                die "don't know how to serialize " . ref($value);
            }
        }
    }

    return $value;
};

1;
