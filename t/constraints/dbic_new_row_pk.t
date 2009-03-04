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
            'addresses.id_1'       => 2,
            'addresses.address_1'  => 'new home',
            'addresses.my_label_1' => 'home label',
            'addresses.id_2'       => '',
            'addresses.address_2'  => 'new office',
            'addresses.my_label_2' => 'office label',
            'addresses.id_3'       => '',
            'addresses.address_3'  => 'new address',
            'addresses.my_label_3' => '',
        } );

    
    ok( !$form->submitted_and_valid );
    
    is_deeply(
        [
            'addresses.my_label_3',
        ],
        [ $form->has_errors ],
    );
}
