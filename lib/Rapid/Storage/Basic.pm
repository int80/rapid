package Rapid::Storage::Basic;

# overrides for MooseX::Storage::Basic to simplify calls to pack/unpack
use Moose::Role;
with 'MooseX::Storage::Basic';

around 'pack' => sub {
    my ($orig, $self, %opts) = @_;

    my $traits = $opts{engine_traits} || [];
    my $engine = '+Rapid::Storage::Engine::Traits::Default';
    push @$traits, $engine unless grep { $_ eq $engine } @$traits;

    $opts{engine_traits} = $traits;
    return $self->$orig(%opts);
};

1;
