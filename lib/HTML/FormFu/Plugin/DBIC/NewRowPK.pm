package HTML::FormFu::Plugin::DBIC::NewRowPK;
use Moose;

extends 'HTML::FormFu::Plugin';

use List::MoreUtils qw( any );
use Carp qw( croak );

sub process {
    my ($self) = @_;

    my $pk_field = $self->parent;
    my $parent   = $pk_field->parent;
    my $block;
    
    while ( defined $parent ) {
        if ( $parent->can('is_repeatable') && $parent->is_repeatable ) {
            $block = $parent;
            last;
        }
        $parent = $parent->parent;
    }

    croak "DBIC::NewRowPK plugin must only be attached to a field within a repeatable block"
        if !defined $block;

    my $nested_name = $pk_field->nested_name;

    for my $field ( @{ $block->get_fields } ) {
        
        my @required_constraints = @{ $field->get_constraints({ type => 'Required' }) };
        
        my @when_constraints =
            grep { $_->when->{field} eq $nested_name }
            grep { defined $_->when }
                @required_constraints;
        
        # skip if there's no Required constraints with a 'when' clause pointing to us
        next if !@when_constraints;
        
        # skip if there's any Required constraints with no 'when' clause
        next if any { !defined $_->when } @required_constraints;
        
        $field->constraint('Required');
    }

    return;
}

1;

__END__

=head1 NAME

HTML::FormFu::Plugin::DBIC::NewRowPK

=head1 SYNOPSIS

    

=head1 DESCRIPTION


=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Plugin>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
