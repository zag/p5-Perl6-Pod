package Perl6::Pod::Parser::ListLevels;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Parser::ListLevels - group lists by level

=head1 SYNOPSIS


=head1 DESCRIPTION


DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !

=cut

use strict;
use warnings;
use base 'Perl6::Pod::Parser';
use Test::More;
use Data::Dumper;

sub on_start_element {
    my ( $self, $el ) = @_;
    my $lname = $el->local_name;
    return $el if $self->{IN_ITEM};
    my @res   = ($el);
    if ( $lname =~ /^item/ ) {
        $self->{IN_ITEM}++;
        #item element
        unless ( $self->{IN_ITEMLIST}++ ) {

            #determine item type
            my $pod_attr = $el->get_attr;

            #diag Dumper $pod_attr;
            my $itemlist = $self->mk_block('itemlist');
            my $type     = 'unordered';
            if ( exists $pod_attr->{numbered} ) {
                $type = 'ordered';
            }
            elsif ( exists $pod_attr->{term} ) {
                $type = 'definition';
            }
            $itemlist->attrs_by_name->{listtype} = $type;
            unshift @res, $self->mk_start_element($itemlist);
        }

    }
    else {
        if ( delete  $self->{IN_ITEMLIST} ) {
            unshift @res, $self->mk_end_element( $self->mk_block('itemlist') );
        }
    }
    \@res;
}

sub on_end_element {
    my ($self, $el) = @_;
    my $lname = $el->local_name;
    if ( $lname =~ /^item/ ) {
           delete $self->{IN_ITEM};
    }
    return $el;
}
sub end_document {
    my $self = shift;

    #special handle if itemlist at end of document
    if ( delete $self->{IN_ITEMLIST} ) {
        $self->_process_comm(
            $self->mk_end_element( $self->mk_block('itemlist') ) );
    }
    return $self->SUPER::end_document;
}

sub on_start_document {
    my $self = shift;
    $self->{LEVELS_STACK} = [];
    return $self->SUPER::on_start_document(@_);
}

sub on_para {
    my ( $self, $el, $txt ) = @_;

    #close itemlist by para block
    if ( exists $self->{IN_ITEMLIST} and $el->local_name eq 'itemlist' ) {
        $self->_process_comm(
            $self->mk_end_element( $self->mk_block('itemlist') ) );
        delete $self->{IN_ITEMLIST};
    }
    return $self->SUPER::on_para( $el, $txt );
}

1;

