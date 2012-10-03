use strict;
use warnings;
use Test::More tests => 3;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_schema';
use MySchema;

my $schema = new_schema();

my $rs = $schema->resultset('User');

# Pre-existing rows
$rs->create( {
    name       => 'a',
    title      => 'b',
} );

$rs->create( {
    name       => 'e',
    title      => 'f',
} );


#
my $form = HTML::FormFu->new;

$form->load_config_file('t/constraints/dbic_unique_repeatable_id_field.yml');

$form->stash->{'schema'} = $schema;

# not uniq id - not uniq name => ok (no changes)
$form->process( {
        'user_1.id'    => '1',
        'user_1.name'  => 'a',
        'user_1.title' => 'title',
    } );

ok( !$form->submitted_and_valid );

ok( $form->has_errors('user_1.name') );

like( $form->get_field({ nested_name => 'user_1.name' }), qr/error_constraint_dbic_unique/ );
