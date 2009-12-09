use strict;
use warnings;
use Test::More tests => 3;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_schema';
use MySchema;

my $form = HTML::FormFu->new;

$form->load_config_file('t/deprecated-defaults_from_model/opt_accessor.yml');

my $schema = new_schema();

my $master = $schema->resultset('Master')->create({ id => 1 });

# filler row

$master->create_related( 'user', { name => 'foo', } );

# row we're going to use

$master->create_related( 'user', {
        title => 'mr',
        name  => 'billy bob',
    } );

{
    my $row = $schema->resultset('User')->find(2);

    {
        my $warnings;
        local $SIG{ __WARN__ } = sub { $warnings++ };

        $form->defaults_from_model($row);
        ok( $warnings, 'warning thrown' );
    }

    my $fs = $form->get_element;

    is( $fs->get_field('id')->render_data->{value},       2 );
    is( $fs->get_field('fullname')->render_data->{value}, 'mr billy bob' );
}

