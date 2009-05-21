use strict;
use warnings;
use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/constraints/dbic_new_row_pk.yml');

{
    $form->process( {
            'id'                   => 2,
            'name'                 => 'new nick',
            'count'                => 3,
            'addresses_1.id'       => 2,
            'addresses_1.address'  => 'new home',
            'addresses_1.my_label' => 'home label',
            'addresses_2.id'       => '',
            'addresses_2.address'  => 'new office',
            'addresses_2.my_label' => 'office label',
            'addresses_3.id'       => '',
            'addresses_3.address'  => 'new address',
            'addresses_3.my_label' => '',
        } );

    
    ok( !$form->submitted_and_valid );

    is_deeply(
        [
            'addresses_3.my_label',
        ],
        [ $form->has_errors ],
    );
}
