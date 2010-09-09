package HTML::FormFu::Constraint::DBIC::Unique;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

use Carp qw( carp croak );

__PACKAGE__->mk_accessors(qw/ model resultset column self_stash_key /);

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    for (qw/ resultset column /) {
        if ( !defined $self->$_ ) {
            # warn and die, as errors are swallowed by HTML-FormFu
            carp  "'$_' is not defined";
            croak "'$_' is not defined";
        }
    }

    # get stash 
    my $stash = $self->form->stash;
    
    my $schema;

    if ( defined $stash->{schema} ) {
        $schema = $stash->{schema};
    }
    elsif ( defined $stash->{context} && defined $self->model ) {
        $schema = $stash->{context}->model( $self->model );
    }
    elsif ( defined $stash->{context} ) {
        $schema = $stash->{context}->model;
    }

    if ( !defined $schema ) {
        # warn and die, as errors are swallowed by HTML-FormFu
        carp  'could not find DBIC schema';
        croak 'could not find DBIC schema';
    }

    my $resultset = $schema->resultset( $self->resultset );

    if ( !defined $resultset ) {
        # warn and die, as errors are swallowed by HTML-FormFu
        carp  'could not find DBIC resultset';
        croak 'could not find DBIC resultset';
    }

    my $column = $self->column || $self->parent->name;

    my $existing_row = eval {
        $resultset->find( { $column => $value } );
    };

    if ( defined( my $error = $@ ) ) {
        # warn and die, as errors are swallowed by HTML-FormFu
        carp  $error;
        croak $error;
    }

    # if a row exists, first check whether it matches a known object on the
    # form stash

    if ( $existing_row && defined( my $self_stash_key = $self->self_stash_key ) ) {
        
        if ( defined( my $self_stash = $stash->{ $self_stash_key } ) ) {
            
            my ($pk) = $resultset->result_source->primary_columns;
            
            if ( $existing_row->$pk eq $self_stash->$pk ) {
                return 1;
            }
        }
    }

    return !$existing_row;
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
