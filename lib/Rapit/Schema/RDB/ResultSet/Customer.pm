package Int80::Schema::IDB::ResultSet::Customer;

use Moose;
    extends 'DBIx::Class::ResultSet';

use namespace::autoclean;
use Digest::SHA1;

around 'create' => sub {
	my ($orig, $self, @rest) = @_;
	
	my $c = $self->$orig(@rest);

    # auto-generate a key for the client
    my $key = Digest::SHA1::sha1_hex(time() . "sEcRETint80SalT123914*!" . rand());
    $c->update({ '`key`' => $key });
};

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
