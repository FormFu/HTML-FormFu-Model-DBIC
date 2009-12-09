use strict;
use warnings;
use Test::More tests => 3;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_schema';
use MySchema;

my $form = HTML::FormFu->new;

$form->load_config_file('t/deprecated-defaults_from_model/belongs_to_lookup_table.yml');

my $schema = new_schema();

my $rs = $schema->resultset('Master');

# Fake submitted form
$form->process( {
        "id"       => 3,
        "text_col" => 'a',
        'type_id'  => '1',
        'type2_id' => '1',
    } );

# filler rows
{
    # insert some entries we'll ignore, so our rels don't have same ids
    $rs->create( { id => 1 } );
    $rs->create( { id => 2 } );
}

{
    # master 3
    my $master = $rs->create( { text_col => 'b', type_id => 2, type2_id => 2 } );

    {
        my $warnings;
        local $SIG{ __WARN__ } = sub { $warnings++ };

        $form->save_to_model($master);
        ok( $warnings, 'warning thrown' );
    }
}

{
    my $row = $rs->find(3);

    is( $row->type->id, '1' );
    is( $row->type2->id, '1' );

}

