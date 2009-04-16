use strict;
use warnings;
use Test::More tests => 15;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/default_values/many_to_many-has_many.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $master = $schema->resultset('Master')->create( { id => 1 } );

# filler rows

{

    # user 1
    my $user = $master->create_related( 'user', { name => 'filler', } );

    # band 1
    $user->add_to_bands( { band => 'a', } );

    # address 1
    $user->add_to_addresses( { address => 'b' } );

    # user 2,3,4
    $master->create_related( 'user', { name => 'filler2', } );
    $master->create_related( 'user', { name => 'filler3', } );
    $master->create_related( 'user', { name => 'filler4', } );
}

# rows we're going to use

{

    # band 2
    my $band = $schema->resultset('Band')->create( { band => 'band 2' } );

    # user 5,6
    my $user1
        = $band->add_to_users( { name => 'user 5', master => $master->id } );
    my $user2
        = $band->add_to_users( { name => 'user 6', master => $master->id } );

    # address 2,3
    $user1->create_related( 'addresses', { address => 'add 2' } );
    $user1->create_related( 'addresses', { address => 'add 3' } );

    # address 4
    $user2->create_related( 'addresses', { address => 'add 4' } );
}

{
    $form->process( {
            'band'                        => 'band 2 edit',
            'count'                       => 2,
            'users.id_1'                  => 5,
            'users.name_1'                => 'user 5 edit',
            'users.count_1'               => 2,
            'users.addresses.id_1_1'      => 2,
            'users.addresses.address_1_1' => 'add 2 edit',
            'users.addresses.id_1_2'      => 3,
            'users.addresses.address_1_2' => 'add 3 edit',
            'users.id_2'                  => 6,
            'users.name_2'                => 'user 6 edit',
            'users.count_2'               => 1,
            'users.addresses.id_2_1'      => 4,
            'users.addresses.address_2_1' => 'add 4 edit',
            'submit'                      => 'Submit',
        } );

    ok( $form->submitted_and_valid );

    my $row = $schema->resultset('Band')->find(2);

    $form->model->update($row);
}

{
    my $band = $schema->resultset('Band')->find(2);

    is( $band->band, 'band 2 edit' );

    my @user = $band->users->all;

    is( scalar @user, 2 );

    # user 5
    {
        is( $user[0]->id,   5 );
        is( $user[0]->name, 'user 5 edit' );

        my @address = $user[0]->addresses->all;

        is( scalar @address, 2 );

        # address 2
        is( $address[0]->id,      2 );
        is( $address[0]->address, 'add 2 edit' );
        
        # address 3
        is( $address[1]->id,      3 );
        is( $address[1]->address, 'add 3 edit' );
    }
    
    # user 6
    {
        is( $user[1]->id,   6 );
        is( $user[1]->name, 'user 6 edit' );

        my @address = $user[1]->addresses->all;

        is( scalar @address, 1 );

        # address 3
        is( $address[0]->id,      4 );
        is( $address[0]->address, 'add 4 edit' );
    }
}

