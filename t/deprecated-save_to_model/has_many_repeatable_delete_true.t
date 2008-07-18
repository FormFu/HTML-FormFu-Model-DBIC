use strict;
use warnings;
use Test::More tests => 6;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/deprecated-save_to_model/has_many_repeatable_delete_true.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $master = $schema->resultset('Master')->create({ id => 1 });

# filler rows
{
    # user 1
    my $u1 = $master->create_related( 'user', { name => 'foo' } );

    # address 1
    $u1->create_related( 'addresses' => { address => 'somewhere' } );
}

{
    # user 2
    my $u2 = $master->create_related( 'user', { name => 'nick', } );

    # adresses 2,3,4
    $u2->create_related( 'addresses', { address => 'home' } );
    $u2->create_related( 'addresses', { address => 'office' } );
    $u2->create_related( 'addresses', { address => 'temp' } );
}

{
    # changing address 2 and deleting address 3+4
    $form->process( {
            'id'                  => 2,
            'name'                => 'new nick',
            'count'               => 3,
            'addresses.id_1'      => 2,   
            'addresses.address_1' => 'new home',
            'addresses.delete_1'  => 1,
            'addresses.id_2'      => 3,
            'addresses.address_2' => 'new office',
            'addresses.id_3'      => 4,
            'addresses.address_3' => 'new office',
            'addresses.delete_3'  => 1,
         } );

    ok( $form->submitted_and_valid );

    my $row = $schema->resultset('User')->find(2);

    {
        my $warnings;
        local $SIG{ __WARN__ } = sub { $warnings++ };

        $form->save_to_model($row);
        ok( $warnings, 'warning thrown' );
    }
}

{
    my $user = $schema->resultset('User')->find(2);

    is( $user->name, 'new nick' );

    my @add = $user->addresses->all;

    is( scalar @add, 1 );

    is( $add[0]->id,      3 );
    is( $add[0]->address, 'new office' );
}

