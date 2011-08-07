package Rapit::Schema::RDB::ResultSet::Customer;

use Moose;
use namespace::autoclean;
use Digest::SHA1;
use Math::Random::Secure qw(rand);

extends 'DBIx::Class::ResultSet';

around 'create' => sub {
	my ($orig, $self, @rest) = @_;
	
	my $c = $self->$orig(@rest);

    # auto-generate a key for the client
    my $key = Digest::SHA1::sha1_hex(time() . rand());
    $c->update({ 'key' => $key });
};

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
