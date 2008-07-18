use strict;
use warnings;
use Test::More tests => 2;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/deprecated-defaults_from_model/has_many_select.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $master = $schema->resultset('Master')->create({ id => 1 });

{

    # insert some entries we'll ignore, so our rels don't have same ids
    # user 1
    my $u1 = $master->create_related( 'user', { name => 'foo' } );

    # address 1
    $u1->create_related( 'addresses' => { address => 'somewhere' } );

    # should get user id 2
    my $u2 = $master->create_related( 'user', { name => 'nick', } );

    # should get address id 2
    $u2->create_related( 'addresses', { address => 'home' } );

    # should get address id 3
    $u2->create_related( 'addresses', { address => 'office' } );
}

{
    my $row = $schema->resultset('User')->find(2);

    {
        my $warnings;
        local $SIG{ __WARN__ } = sub { $warnings++ };

        $form->defaults_from_model($row);
        ok( $warnings, 'warning thrown' );
    }

    is_deeply( $form->get_field('addresses')->default, [ 2, 3 ] );
}

