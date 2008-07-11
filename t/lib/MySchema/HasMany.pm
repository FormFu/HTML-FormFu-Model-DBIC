package MySchema::HasMany;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/ Core /);

__PACKAGE__->table("has_many");

__PACKAGE__->add_columns(
    user  => { data_type => "INTEGER" },
    key   => { data_type => "TEXT" },
    value => { data_type => "TEXT" },
);

__PACKAGE__->set_primary_key("user", "key");

__PACKAGE__->belongs_to( user => 'MySchema::User' );

1;

