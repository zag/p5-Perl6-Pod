package Perl6::Pod::Parser::AddHeadLevels;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Parser::AddHeadLevels - group headers by level

=head1 SYNOPSIS


=head1 DESCRIPTION


DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !

=cut

use strict;
use warnings;
use base 'Perl6::Pod::Parser';
use Data::Dumper;
use Test::More;

#fix export to sax
sub __exp_element_to_sax2 {
    my ( $self, $el ) = @_;
    return $el;
}

sub _lstack {
    my $self = shift;
    return $self->{LEVELS_STACK};
}

sub on_start_document {
    my $self = shift;
    $self->{LEVELS_STACK} = [];
    return $self->SUPER::on_start_document(@_);
}

sub current_level {
    my $self = shift;
    my $current = $self->_lstack->[-1] || return 0;
    return $current->attrs_by_name->{hlevel};
}

sub switch_to_level {
    my ( $self, $to_level, $lname ) = @_;
    my $current_level = $self->current_level;
    my $hl =
      $self->mk_block( 'headlevel', qq!:level($to_level) :child<$lname>)! );
    $hl->attrs_by_name->{hlevel} = $to_level;
    if ( $current_level < $to_level ) {

        #up level
        #=head1
        #=head2
        #set current stack
        die
"found step more then 1 level near =head $to_level at line: $current_level "
          if $to_level - $current_level > 1;
        push @{ $self->_lstack }, $hl;
        return $self->mk_start_element($hl);
    }
    elsif ( $current_level == $to_level ) {
        my $end_of = pop @{ $self->_lstack };
        push @{ $self->_lstack }, $hl;
        return ( $self->mk_end_element($end_of), $self->mk_start_element($hl) );

        #set current head at stack

    }
    else {
        my @res = ();

        # $current_level > $to_level
        #=head2
        #=head3
        #=head1
        #flush levels

        for ( 0 .. $current_level - $to_level ) {
            push @res, $self->mk_end_element( pop @{ $self->_lstack } );
        }
        push @{ $self->_lstack }, $hl;
        return ( @res, $self->mk_start_element($hl) );
    }

}

sub on_start_element {
    my ( $self, $el ) = @_;
    my $lname = $el->local_name;

    #ALL SEMANTIC BLOCKS HAVE level 1
    # all sem blocks is UPPER CASE ( AND FORMATTING CODES!!!!)
    my $is_block = !$el->isa('Perl6::Pod::FormattingCode');

    #skip special BLOCKS _SPECIAL_
    my $is_semantic =
      $is_block && ( $lname eq uc($lname) ) && ( $lname !~ /^_/ );
    return $el unless ( $is_semantic or $lname =~ /^head(\d+)/ );
    my $to_level = $is_semantic ? 1 : $1;
    my @comms = $self->switch_to_level( $to_level, $lname );
    return [ @comms, $el ];
}

sub end_document {
    my $self    = shift;
    my $current = $self->current_element;
    my $stack   = $self->_objects_stack;
    for ( 1 .. scalar(@$stack) ) {
        my $in_stack = $self->_objects_stack()->[-1];
        $self->_process_comm( $self->mk_end_element($in_stack) );
    }
    return $self->SUPER::end_document;
}

1;

