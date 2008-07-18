use strict;
use warnings;
use Test::More tests => 3;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/deprecated-defaults_from_model/belongs_to_lookup_table.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs = $schema->resultset('Master');

# filler row

$rs->create( { text_col => 'filler', } );

# row we're going to use

$rs->create( {
        text_col => 'a',
        type_id  => 3,
    } );

{
    my $row = $rs->find(2);

    {
        my $warnings;
        local $SIG{ __WARN__ } = sub { $warnings++ };

        $form->defaults_from_model($row);
        ok( $warnings, 'warning thrown' );
    }

    is( $form->get_field('id')->default, 2 );

    is( $form->get_field('type_id')->default, 3 );
}

