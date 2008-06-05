use strict;
use warnings;
use Test::More tests => 2;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/default_values/opt_accessor.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs = $schema->resultset('User');

# filler row

$rs->create( { name => 'foo', } );

# row we're going to use

$rs->create( {
        title => 'mr',
        name  => 'billy bob',
    } );

{
    my $row = $rs->find(2);

    $form->model->default_values($row);

    my $fs = $form->get_element;

    is( $fs->get_field('id')->render_data->{value},       2 );
    is( $fs->get_field('fullname')->render_data->{value}, 'mr billy bob' );
}

