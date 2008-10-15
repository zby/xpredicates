use strict;
use warnings;

package DBSchema::ResultSet::Dvd;

use base 'DBIx::Class::ResultSet::XPredicates';

sub search_for_name {
    my ( $self, $params ) = @_;
    my $search_params = { name => { 'like' => '%' . $params->{name} . '%' } };
    $self = $self->search( $search_params );
    return $self;
}

sub search_for_owner_name {
    my ( $self, $params ) = @_;
    my $search_params = { 'owner.name' => { 'like' => '%' . $params->{owner_name} . '%' } };
    $self = $self->search( $search_params, { join => 'owner' } );
    return $self;
}

sub search_for_tags {
    my ( $self, $params ) = @_;
    my @tags = $self->result_source->schema->resultset( 'Tag' )->search( { name => $params->{tags} } );
    my @tag_ids = map { $_->id } @tags;
    my %search_params;
    my $suffix = '';
    my $i = 1;
    for my $tag_id ( @tag_ids ){
            $search_params{'dvdtags' . $suffix .  '.tag'} = $tag_id;
            $suffix = '_' . ++$i;
    }
    my @joins = ( 'dvdtags' ) x scalar( @tag_ids );
    $self = $self->search( \%search_params, { 
                join => \@joins,
            } 
    );
    return $self;
}

1;


