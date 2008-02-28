use strict;
use warnings;
use Test::More tests => 5;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/update/has_many_repeatable_delete_true.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $user_rs    = $schema->resultset('User');
my $address_rs = $schema->resultset('Address');
my ( $u2, $a2, $a3 );
{

    # insert some entries we'll ignore, so our rels don't have same ids
    # user 1
    my $u1 = $user_rs->create( { name => 'foo' } );

    # address 1
    my $a1 = $u1->create_related( 'addresses' => { address => 'somewhere' } );

    # should get user id 2
    $u2 = $user_rs->create( { name => 'nick', } );

    # should get address id 2
    $a2 = $u2->create_related( 'addresses', { address => 'home' } );

    # should get address id 3
    $a3 = $u2->create_related( 'addresses', { address => 'office' } );
}

{
    $form->process( {
            'id'                  => $u2->id,
            'name'                => 'new nick',
            'count'               => 2,
            'addresses.id_1'      => $a2->id,
            'addresses.address_1' => 'new home',
            'addresses.delete_1'  => 1,
            'addresses.id_2'      => $a3->id,
            'addresses.address_2' => 'new office',
        } );

    ok( $form->submitted_and_valid );

    my $row = $user_rs->find($u2->id);

    $form->model('DBIC')->update($row);

    my $user = $user_rs->find($u2->id);

    is( $user->name, 'new nick' );

    my @add = $user->addresses->all;

    is( scalar @add, 1 );

    is( $add[0]->id,      $a3->id );
    is( $add[0]->address, 'new office' );
}

