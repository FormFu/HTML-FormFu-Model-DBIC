package HTMLFormFu::I18N;
use strict;
use warnings;

use base 'Locale::Maketext';

*loc = \&localize;

sub localize {
    my $self = shift;

    return $self->maketext(@_);
}

1;
