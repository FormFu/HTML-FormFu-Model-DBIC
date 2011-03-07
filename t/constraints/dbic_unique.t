use strict;
use warnings;
use Test::More tests => 14;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_schema';
use MySchema;

my $schema = new_schema();

my $rs = $schema->resultset('User');

# Pre-existing row to check against.
$rs->create( {
        name       => 'a',
        title      => 'b',
    } );
# Second row to check against for method_name with record on stash
$rs->create( {
        name       => 'e',
        title      => 'f',
    } );

# Basic form.
{
    my $form = HTML::FormFu->new;
        
    $form->load_config_file('t/constraints/dbic_unique.yml');
    
    $form->stash->{'schema'} = $schema;

    $form->process( {
            'name'                 => 'a',
            'title'                => 'c',
        } );
    
    ok( !$form->submitted_and_valid );

    is_deeply(
        [
            'name',
        ],
        [ $form->has_errors ],
    );
}

# Form where DB column differs from form field name.
{
    my $form = HTML::FormFu->new;
        
    $form->load_config_file('t/constraints/dbic_unique_column.yml');
    
    $form->stash->{'schema'} = $schema;

    $form->process( {
            'username'             => 'a',
            'title'                => 'c',
        } );
    
    ok( !$form->submitted_and_valid );

    is_deeply(
        [
            'username',
        ],
        [ $form->has_errors ],
    );
}

# Form tracking a multi-column unique key (name+title).
{
    my $form = HTML::FormFu->new;
        
    $form->load_config_file('t/constraints/dbic_unique_others.yml');
    
    $form->stash->{'schema'} = $schema;

    $form->process( {
            'name'                 => 'a',
            'title'                => 'c',
        } );
    
    ok( $form->submitted_and_valid );

    $form->process( {
            'name'                 => 'a',
            'title'                => 'b',
        } );
    
    ok( !$form->submitted_and_valid );

    is_deeply(
        [
            'name',
        ],
        [ $form->has_errors ],
    );
}

# Form using a method_name to determine uniqueness (is_name_available).
{
    my $form = HTML::FormFu->new;
        
    $form->load_config_file('t/constraints/dbic_unique_method.yml');
    
    $form->stash->{'schema'} = $schema;

    $form->process( {
            'name'                 => 'a',
            'title'                => 'c',
        } );
    
    ok( $form->submitted_and_valid );

    $form->process( {
            'name'                 => 'xxx',
            'title'                => 'b',
        } );
    
    ok( !$form->submitted_and_valid );

    is_deeply(
        [
            'name',
        ],
        [ $form->has_errors ],
    );
}

# Form using a method_name to determine uniqueness with record on stash (is_name_available).
{
    my $form = HTML::FormFu->new;
        
    $form->load_config_file('t/constraints/dbic_unique_method.yml');
    
    my $user = $schema->resultset('User')->find( {name => 'a'} );
    
    $form->stash->{'schema'} = $schema;
    $form->stash->{'user'}   = $user;

    $form->process( {
            'name'                 => 'a',
            'title'                => 'b',
        } );
    
    ok( $form->submitted_and_valid );

    $form->process( {
            'name'                 => 'c',
            'title'                => 'd',
        } );
    
    ok( $form->submitted_and_valid );

    $form->process( {
            'name'                 => 'e',
            'title'                => 'f',
        } );
    
    ok( !$form->submitted_and_valid );

    is_deeply(
        [
            'name',
        ],
        [ $form->has_errors ],
    );
}
