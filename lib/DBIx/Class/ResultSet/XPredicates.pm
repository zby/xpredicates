package DBIx::Class::ResultSet::XPredicates;

use version; $VERSION = qv('0.0.1');

use warnings;
use strict;
use Carp;

use base qw(DBIx::Class::ResultSet);


sub xsearch {
    my ( $self, $params, $attrs ) = @_;
    my $columns = {};
    for my $column ( keys %$params ){
        if( my $search = $self->can( "search_for_$column" ) ){
            $self = $self->$search( $params );
            next; 
        }
        if( $self->result_source->has_relationship( $column ) && ref $params->{$column} ){
            my ( $join, $predicates ) = _translate( $self->result_source, $column, $params->{$column} );
            $self = $self->search({}, { join => $join });
            $columns->{$_} = $predicates->{$_} for keys %$predicates;
        }
        else{ 
            my ( $full_name, $relation ) = $self->_parse_column( $column );
            $self = $self->search({}, { join => $relation });
            $columns->{$full_name} = $params->{$column};
        }
    }
    return $self->search( $columns, $attrs );
}

sub _translate {
    my ( $source, $column, $value ) = @_;
    if( ref $value && $source->has_relationship( $column ) ){
        my @sub_joins;
        my %predicates;
        my $rel_source = $source->related_source( $column );
        for my $sub_col ( keys %$value ){
            my( $sub_join, $sub_predicates ) = _translate( $rel_source, $sub_col, $value->{$sub_col} );
            if( ref $sub_join eq 'ARRAY' ){ 
                push @sub_joins, @$sub_join;
            }
            elsif( $sub_join ){
                push @sub_joins, $sub_join;
            }
            for my $key ( keys %$sub_predicates ){
                if( $key =~ /\./ ){
                    $predicates{$key} = $sub_predicates->{$key};
                }
                else{
                    $predicates{ $column . '.' . $key } = $sub_predicates->{$key};
                }
            }
        }
        my $joins;
        if( scalar @sub_joins > 1 ){
            $joins->{$column} = \@sub_joins;
        }
        elsif( scalar @sub_joins == 1 ){
            $joins->{$column} = $sub_joins[0];
        }
        else {
            $joins = $column
        }
        return ( $joins, \%predicates );
    }
    else {
        return ( undef, { $column => $value } );
    }
}


sub _parse_column {
    my ( $self, $full_col ) = @_;
    my ($col, $join, @rest) = reverse split /\./, $full_col;
    return $col unless $join;

    my $full_name = "${join}.${col}";
    $join = { $_ => $join } for @rest;
    return ($full_name, $join);
}

# Module implementation here


1; # Magic true value required at end of module
__END__

=head1 NAME

DBIx::Class::ResultSet::XPredicates - an expandable search interpreter 


=head1 VERSION

This document describes DBIx::Class::ResultSet::XPredicates version 0.0.1


=head1 SYNOPSIS

   __PACKAGE__->load_namespaces( default_resultset_class => '+DBIx::Class::ResultSet::XPredicates' );

in the Schema file (see t/lib/DBSchema.pm).  Or appriopriate 'use base' in the ResultSet classes. 

Then:

=for author to fill in:

    my @records = $schema->ResultSet( 'MyTable' )->xsearch( 
        {
            column1 => 'value1',
            column2 => 'value2', 
            some_relation.column => 'value3',
            some_other_relation.some_third_relation.column => 'value4', 
        },
        { page => 1, rows => 5 }
    );
 
=head1 DESCRIPTION

=for author to fill in:

This simple module lets you to easily support web 'advanced' search forms with many
predicates combined with ANDs. It lets you easily add new predicates, even
complex ones, in a modular way.  To add a new predicate on a column you need to
write a method with name search_for_column_name like this one that does a 'like'
search by a column from a related table:

    sub search_for_owner_name {
        my ( $self, $params ) = @_;
        my $search_params = { 'owner.name' => { 'like' => '%' . $params->{owner_name} . '%' } };
        $self = $self->search( $search_params, { join => 'owner' } );
        return $self;
    }

In that method you get the ResultSet object and all the parameters - you can
write your search in isolation from other predicates and at the call time it
will be correctly combined with the other predicates using 'AND'.

=head1 INTERFACE 

=for author to fill in:

=head1 METHODS

=head2 recursive_update

The only method here.

=head1 DIAGNOSTICS


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
 
DBIx::Class::ResultSet::AdvanceSearch


=head1 DEPENDENCIES

=for author to fill in:

    DBIx::Class

None.


=head1 INCOMPATIBILITIES

=for author to fill in:

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-dbix-class-recursiveput@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Zbigniew Lukasiak  C<< <zby@cpan.org> >>
Influenced by code by Pedro Melo.

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Zbigniew Lukasiak C<< <zby@cpan.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
