use strict;
use warnings;
use Test::More;

eval { require HTML::FormFu::MultiForm };
if ($@) {
    plan skip_all => 'HTML::FormFu::MultiForm required';
    die $@;
}

plan tests => 2;

my $multi = HTML::FormFu::MultiForm->new;

$multi->load_config_file('t/multiform/multiform.yml');

$multi->process( {
        foo    => 'abc',
        submit => 'Submit',
    } );

my $form = $multi->current_form;

ok( $form->submitted_and_valid );

is_deeply(
    $form->params,
    {   foo    => 'abc',
        submit => 'Submit',
    } );
