use strict;
use warnings;
use Test::More tests => 8;

use HTML::FormFu;
use lib qw(t/lib lib);
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/deprecated-new_empty_row_multi/update/has_many_repeatable_many_new.yml');

my $schema     = MySchema->connect('dbi:SQLite:dbname=t/test.db');
my $user_rs    = $schema->resultset('User');
my $address_rs = $schema->resultset('Address');

{
	$form->process( {
        'id'                  => '',
        'name'                => 'new nick',
        'master'              => 1,
        'count'               => 2,
        'addresses.id_1'      => '',
        'addresses.address_1' => 'new home',
        'addresses.id_2'      => '',
        'addresses.address_2' => 'new office',
    } );
    
	ok( $form->submitted_and_valid );
    
	my $row = $user_rs->new( {} );
	
    $form->model('DBIC')->update($row);
	
    my $user = $user_rs->find(1);
	
    is( $user->name, 'new nick' );
    
	my @add = $user->addresses->all;
	
    is( scalar @add,      2 );
	is( $add[0]->id,      1 );
	is( $add[0]->address, 'new home' );
	is( $add[1]->id,      2 );
	is( $add[1]->address, 'new office' );
}

{
	$form->process( {
        'id'                  => '',
        'name'                => 'new nick2',
        'master'              => 1,
        'count'               => 3,
        'addresses.id_1'      => '',
        'addresses.address_1' => 'new home',
        'addresses.id_2'      => '',
        'addresses.address_2' => 'new office',
        'addresses.id_3'      => '',
        'addresses.address_3' => 'new office2',
    } );
	
	ok( !$form->submitted_and_valid, "too many new rows" );
}
