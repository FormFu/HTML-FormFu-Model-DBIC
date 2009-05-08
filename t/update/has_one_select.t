use strict;
use warnings;
use Test::More tests => 5;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/update/has_one_select.yml');

$form->stash->{schema} = $schema;

{
    $form->process( {
        "id"        => 3,
        "text_col"  => 'a',
        "user"   => 1,
    } );
    
    ok( $form->submitted_and_valid );

    my $row = $schema->resultset('Master')->find(3);
    
    $form->model->update($row);
    
    is($row->user->id, 1);
    
        $form->process( {
        "id"        => 3,
        "text_col"  => 'a',
        "user"   => 99,
    } );
    
    ok( $form->submitted_and_valid );

    my $row = $schema->resultset('Master')->find(3);

    $form->model->update($row);
    
    is($row->user->id, 1);
    
    $form = HTML::FormFu->new;
    
    $form->stash->{schema} = $schema;

    $form->load_config_file('t/update/has_one_select.yml');
    
    $form->model->default_values($row);
        
    $form->process;
    
    like($form, qr/value="1" selected=/);
}

