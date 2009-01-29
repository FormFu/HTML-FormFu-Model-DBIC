use strict;
use warnings;
use Test::More tests => 3;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;
new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/options_from_model/belongs_to_localize_label.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

$form->stash->{schema} = $schema;

my $type_rs  = $schema->resultset('Type');

{

    # types
    $type_rs->delete;
    $type_rs->create( { type => 'label_foo' } );
    $type_rs->create( { type => 'label_bar' } );
}

$form->process;

{
    my $option = $form->get_field('type')->options;
    
    ok( @$option == 2 );
    
    is( $option->[0]->{label}, 'Foo' );
    is( $option->[1]->{label}, 'Bar' );
}
