use strict;
use warnings;
use Test::More tests => 2;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/default_values/nested_base_accessor.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs = $schema->resultset('User');

{
    my $row = $rs->create( {
        name => 'mr. foo',
    } );

    $row->create_related( 'hasmanys', { key => 'bar', value => 'a' } );
    $row->create_related( 'hasmanys', { key => 'foo', value => 'b' } );
}

# Fake submitted form
$form->process( {
        'name'      => 'Mr. Foo',
        'foo.value' => 'c',
    } );

{
    my $row = $rs->find(1);

    $form->model->update($row);
}

{
    my $row = $rs->find(1);

    is ( $row->name, 'Mr. Foo' );
    is ( $row->foo->value, 'c' );
}

