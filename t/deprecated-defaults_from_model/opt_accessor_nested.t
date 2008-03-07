use strict;
use warnings;
use Test::More tests => 3;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/deprecated-defaults_from_model/opt_accessor_nested.yml');

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

    {
        my $warnings;
        local $SIG{ __WARN__ } = sub { $warnings++ };

        $form->defaults_from_model( $row, { nested_base => 'foo' } );
        ok( $warnings, 'warning thrown' );
    }

    is( $form->get_field( { nested_name => 'foo.id' } )->render_data->{value},
        2 );
    is( $form->get_field( { nested_name => 'foo.fullname' } )
            ->render_data->{value},
        'mr billy bob'
    );
}

