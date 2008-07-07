use strict;
use warnings;
use Test::More tests => 2;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/default_values/multi_label.yml');

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

    my $multi = $form->get_element({ type => 'Multi' });

    is( $multi->render_data->{label}, 'mr' );

    my $name = $multi->get_field('name')->render_data;
    
    is( $name->{value}, 'billy bob' );
}

