use strict;
use warnings;
use Test::More tests => 2;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/update/belongs_to_select.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

$form->stash->{schema} = $schema;

my $rs = $schema->resultset('Master');

$rs->create( { id => 1 } );
$rs->create( { id => 2 } );

my $master = $rs->create( { text_col => 'b', type_id => 2, type2_id => 2 } );

$form->process( { master => 2, note => 'foo' } );

$form->model->create;

my $note = $schema->resultset("Note")->find(1);

is($note->master->id, 2);

is($note->note, 'foo');
