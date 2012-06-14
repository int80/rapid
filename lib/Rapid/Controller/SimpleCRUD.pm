package Rapid::Controller::SimpleCRUD;

use Moose;
use Class::Load;
use Carp;
use namespace::autoclean;

BEGIN {
    extends 'Catalyst::Controller';
}

sub get_params {
    my ( $self, $c ) = @_;

    my $params = $c->req->params;

    # add uploads to params
    map { $params->{$_} = ref $c->req->uploads->{$_} eq 'ARRAY' ? 
              [ $c->req->upload($_) ] : # handle multiple uploads
              $c->req->upload($_) # handle single upload
    } keys %{$c->req->uploads};

    return $params;
}

sub item :Chained('base') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $item_id ) = @_;

    my $item = $c->model( $self->config->{model_class} )->find($item_id, { force_pool => 'master' })
      or return $c->error_detach("Invalid item ID");

    $c->stash( $self->config->{item_label} => $item );
}

sub create :Chained('base') PathPart('create') Args(0) {
    my ( $self, $c ) = @_;

    # set add_form to edit_form unless defined
    $self->config->{add_form} ||= $self->config->{edit_form};

    # loads the form class
    Class::Load::load_class( $self->config->{add_form} )
      or croak 'Failed to load add form class';

    my $form_opts = $self->config->{form_opts};
    my $row = $c->model( $self->config->{model_class} )->new_result( {} );

    my $form = $self->config->{add_form}->new( %$form_opts, item => $row );


    $c->stash(
        template => $self->config->{templates}->{create},
        form     => $form
    );

    if ($c->req->method eq 'POST') {
        return unless $form->process( item => $row, params => $c->req->parameters );

        $c->stash( $self->config->{item_label} => $row );
    }

}

sub edit :Chained('item') PathPart('edit') Args(0) {
    my ( $self, $c ) = @_;

    # loads the form class
    Class::Load::load_class( $self->config->{edit_form} )
      or croak 'Failed to load edit form class';

    my $form_opts = $self->config->{form_opts};

    my $form = $self->config->{edit_form}->new(
        item => $c->stash->{ $self->config->{item_label} },
        %$form_opts
    );

    $c->stash( template => $self->config->{templates}->{edit}, form => $form );

    if ( $c->req->method eq 'POST' ) {
        $form->process( params => $self->get_params($c) );
    }
    else {
        $form->params( $self->get_params($c) );
    }
}

sub list :Chained('base') PathPart('list') Args(0) {
    my ( $self, $c ) = @_;

    # items per page
    my $items_per_page = $self->config->{items_per_page} || 20;
    my $page_num = $c->req->param('page') || 1;

    # custom result class
    my $rs = $c->model( $self->config->{model_class} );
    my $result_class = $self->config->{result_class};
    $rs->result_class($result_class) if $result_class;

    # custom order_by in search
    my $order_by = $self->config->{order_by};

    my $search = {};
    my $attr = { page => $page_num, rows => $items_per_page };
    $attr->{order_by} = $order_by if $order_by;

    my $item_rs = $rs->search($search, $attr);
    my @items = $item_rs->all;

    # plural item_label for stash
    $c->stash(
        $self->config->{item_label} . 's'    => \@items,
        $self->config->{item_label} . 's_rs' => $item_rs,
        template                             => $self->config->{templates}->{list}
    );
}

sub delete :Chained('item') PathPart('delete') Args(0) {
    my ( $self, $c ) = @_;

    my $item = $c->stash->{ $self->config->{item_label} };
    $item->delete;
}

__PACKAGE__->meta->make_immutable;

# TODO: write some docs
