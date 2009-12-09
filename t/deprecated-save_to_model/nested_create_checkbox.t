use strict;
use warnings;
use Test::More tests => 3;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_schema';
use MySchema;

my $form = HTML::FormFu->new;

$form->load_config_file('t/deprecated-save_to_model/nested.yml');

my $schema = new_schema();

my $rs = $schema->resultset('Master');

# Fake submitted form
$form->process( {
        "foo.id"       => 1,
        "foo.text_col" => 'a',
    } );

{
    my $row = $rs->new( {} );

    {
        my $warnings;
        local $SIG{ __WARN__ } = sub { $warnings++ };

        $form->save_to_model( $row, { nested_base => 'foo' } );
        ok( $warnings, 'warning thrown' );
    }
}

{
    my $row = $rs->find(1);

    is( $row->text_col, 'a' );

    # check default

    is( $row->checkbox_col, 0 );
}

