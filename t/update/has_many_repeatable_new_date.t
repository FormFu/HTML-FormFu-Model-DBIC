use strict;
use warnings;
use Test::More tests => 2;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/update/has_many_repeatable_new_date.yml');
#$form->process; die $form;
my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $user_rs    = $schema->resultset('User');
my $address_rs = $schema->resultset('Address');

{
    # insert some entries we'll ignore, so our rels don't have same ids
    # user 1
    my $u1 = $user_rs->new_result( { name => 'foo' } );
    $u1->insert;
}

{
    $form->process( {
            'id'                  => 1,
            'name'                => 'new nick',
            'count'               => 1,
            'addresses.address_1_day' => 11,
            'addresses.address_1_month' => 11,
            'addresses.address_1_year' => 1985,
        } );

    ok( $form->submitted_and_valid );

#       for ( @{ $form->get_errors } ) {
#                       print Data::Dumper::Dumper({ id => $_->name, msg => $_->message }).$/;
#               }
              
    $form->process( {
            'id'                  => 1,
            'name'                => 'new nick',
            'count'               => 1,
            'addresses.address_1' => "12.12.1985"
        } );

    ok( $form->submitted_and_valid );

#       for ( @{ $form->get_errors } ) {
#                       print Data::Dumper::Dumper({ id => $_->name, msg => $_->message }).$/;
#               }
}

