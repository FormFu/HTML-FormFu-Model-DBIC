package HTML::FormFu::Constraint::DBIC::Unique;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

__PACKAGE__->mk_accessors(qw/ model schema resultset field myself/);

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    # get stash 
    my $stash = $self->form->stash;
    
    my $rs;
    if ( $stash->{context} ) {
        $rs = $stash->{context}->model($self->model);
        $rs = $rs->resultset($self->resultset) if $self->resultset;
    }
    elsif ( $stash->{schema} ) {
        $rs = $stash->{schema};
        $rs = $rs->resultset($self->resultset) if $self->resultset;
    }
    else {
        warn "need a Catalyst context or a DBIC schema in the stash\n"; 
        $self->return_error('need a Catalyst context or a DBIC schema in the stash');
        return 0;
    }
  
    my $field = $self->field || $self->parent->name;
    my $exists = eval { $rs->find({ $field => $value }) };

    if ($@) {
        warn $@;
        $self->return_error($@);
        return 0;
    }

    if ($exists && $self->myself) {
        if ($stash->{$self->myself}) {
            return 1 if $exists->id eq $stash->{$self->{myself}}->id;
        }
    }

    return !$exists;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Unique

=head1 SYNOPSIS

    $form->stash->{schema} = $dbic_schema; # DBIC schema 

    $form->element('text')
         ->name('email')
         ->constraint('DBIC::Unique')
         ->resultset('User')
         ;


    $form->stash->{context} = $c; # Catalyst context

    $form->element('text')
         ->name('email')
         ->constraint('DBIC::Unique')
         ->model('DBIC::User')
         ;

    $form->element('text')
         ->name('user')
         ->constraint('DBIC::Unique')
         ->model('DBIC')
         ->resultset('User')
         ;


    or in a config file:
    ---
    elements: 
      - type: text
        name: email
        constraints:
          - Required
          - type: DBIC::Unique
            model: DBIC::User
      - type: text
        name: user
        constraints: 
          - Required
          - type: DBIC::Unique
            model: DBIC::User
            field: username


=head1 DESCRIPTION

Checks if the input value exists in a DBIC ResultSet.

=head1 METHODS

=head2 model

Arguments: $string # a Catalyst model name like 'DBIC::User'

=head2 resultset

Arguments: $string # a DBIC resultset name like 'User'

=head2 myself

reference to a key in the form stash. if this key exists, the constraint
will check if the id matches the one of this element, so that you can 
use your own name.

=head2 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Jonas Alves C<jgda@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
