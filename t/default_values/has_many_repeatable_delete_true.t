use strict;
use warnings;
use Test::More tests => 16;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/default_values/has_many_repeatable_delete_true.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $master = $schema->resultset('Master')->create({ id => 1 });

# row we're going to use

$master->create_related( 'user', {
        name      => 'nick',
        addresses => [ { address => 'home', }, { address => 'office', } ] } );

{
    my $row = $schema->resultset('User')->find(1);

    $form->model->default_values($row);

    is( $form->get_field('id')->default,    '1' );
    is( $form->get_field('name')->default,  'nick' );
    is( $form->get_field('count')->default, '4' );

    my $block = $form->get_all_element( { nested_name => 'addresses' } );

    my @reps = @{ $block->get_elements };

    is( scalar @reps, 4 );

    is( $reps[0]->get_field('id_1')->default,      '1' );
    is( $reps[0]->get_field('address_1')->default, 'home' );

    ok( $reps[0]->get_field({ type => 'Checkbox' }) );

    is( $reps[1]->get_field('id_2')->default,      '2' );
    is( $reps[1]->get_field('address_2')->default, 'office' );

    ok( $reps[1]->get_field({ type => 'Checkbox' }) );

    # empty rows

    is( $reps[2]->get_field('id_3')->default,      undef );
    is( $reps[2]->get_field('address_3')->default, undef );

    # checkbox has been removed
    ok( !$reps[2]->get_field({ type => 'Checkbox' }) );

    is( $reps[3]->get_field('id_4')->default,      undef );
    is( $reps[3]->get_field('address_4')->default, undef );

    # checkbox has been removed
    ok( !$reps[3]->get_field({ type => 'Checkbox' }) );
}

