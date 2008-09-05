use strict;
use warnings;
use Test::More tests => 6;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;
new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/options_from_model/condition_from_stash_combobox.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

$form->stash->{schema} = $schema;

my $master_rs = $schema->resultset('Master');
my $user_rs   = $schema->resultset('User');

{
    my $m1 = $master_rs->create({ text_col => 'foo' });
    
    $m1->create_related( 'user', { name => 'a' } );
    $m1->create_related( 'user', { name => 'b' } );
    $m1->create_related( 'user', { name => 'c' } );
}

{
    my $m2 = $master_rs->create({ text_col => 'foo' });
    
    $m2->create_related( 'user', { name => 'd' } );
    $m2->create_related( 'user', { name => 'e' } );
    $m2->create_related( 'user', { name => 'f' } );
    $m2->create_related( 'user', { name => 'g' } );
    
    $form->stash->{master_id} = $m2->id;
}

$form->process;

{
    my $option = $form->get_field('user')->options;
    
    ok( @$option == 5 );
    
    is( $option->[0]->{label}, '' );
    is( $option->[1]->{label}, 'd' );
    is( $option->[2]->{label}, 'e' );
    is( $option->[3]->{label}, 'f' );
    is( $option->[4]->{label}, 'g' );
}
