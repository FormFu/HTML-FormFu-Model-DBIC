use strict;
use warnings;
use Test::More;

eval { require HTML::FormFu::MultiForm };
if ($@) {
    plan skip_all => 'HTML::FormFu::MultiForm required';
    die $!;
}

plan tests => 2;

my $multi = HTML::FormFu::MultiForm->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$multi->load_config_file('t/multiform/multiform.yml');

$multi->process;

my $html = <<HTML;
<form action="" id="form" method="post">
<fieldset>
<div class="text">
<input name="foo" type="text" />
</div>
<div class="submit">
<input name="submit" type="submit" />
</div>
</fieldset>
</form>
HTML

is( "$multi", $html );

my $form = $multi->current_form;

is( "$form", $html );
