# -*- perl -*-

use lib 't/lib';
use DBSchema;
use Test::More;
plan tests => 7;

my $schema = DBSchema::get_test_schema();
my $dvd_rs = $schema->resultset( 'Dvd' );

my $new_rs = $dvd_rs->xsearch( { 'owner.username' => 'jgda' } );
is( $new_rs->count, 2, 'Searching by related' );
$new_rs = $dvd_rs->xsearch( { owner => { username => 'jgda' } } );
is( $new_rs->count, 2, 'Searching by related' );

$new_rs = $dvd_rs->xsearch( { 'name' => 'hanging' } );
is( $new_rs->count, 1, 'Like searching' );
$new_rs = $dvd_rs->xsearch( { 'owner_name' => 'Jonas' } );
is( $new_rs->count, 2, 'Related like searching' );
$new_rs = $dvd_rs->xsearch( { tags => [ 'australian', 'dramat' ] } );
is( $new_rs->count, 1, 'Searching by tags' );

my $user_rs = $schema->resultset('User');
$new_rs = $user_rs->xsearch({ 'owned_dvds.dvdtags.tag.name' => 'comedy' });
is( $new_rs->count, 2, 'Deep join' );
$new_rs = $user_rs->xsearch({ owned_dvds => { dvdtags => { tag => { name => 'comedy' } } } });
is( $new_rs->count, 2, 'Deep join' );


