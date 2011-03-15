package Perl6::Pod::Parser::ListLevels;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Parser::ListLevels - multilevel helper  

=head1 SYNOPSIS

     =item1  # Visito
     =item2     # Veni
     =item2     # Vidi
     =item2     # Vici


=head1 DESCRIPTION

Note that item blocks within the same list are not physically nested.
That is, lower-level items should I<not> be specified inside
higher-level items:

    =comment WRONG...
    =begin item1          --------------
    The choices are:                    |
    =item2 Liberty        ==< Level 2   |==<  Level 1
    =item2 Death          ==< Level 2   |
    =item2 Beer           ==< Level 2   |
    =end item1            --------------

    =comment CORRECT...
    =begin item1          ---------------
    The choices are:                     |==< Level 1
    =end item1            ---------------
    =item2 Liberty        ==================< Level 2
    =item2 Death          ==================< Level 2
    =item2 Beer           ==================< Level 2


=cut

use strict;
use warnings;
use base 'Perl6::Pod::Parser';
use Test::More;
use Data::Dumper;

=pod
  =item1
  =item2
  =item1

   <_LIST_ITEM_>
   =item1
   </_LIST_ITEM_>
   <_LIST_ITEM_>
   =item2
   </_LIST_ITEM_>
   <_LIST_ITEM_>
   =item1
   </_LIST_ITEM_>

=cut

sub on_start_element {
    my ( $self, $el ) = @_;
    my $lname = $el->local_name;
    if ($lname eq '_ITEM_ENTRY_' and $el->attrs_by_name->{listtype} eq 'ordered') {
        $self->set_numbering($el);
    }
    return $el if $self->{IN_ITEM};
    return $el if $lname eq '_LIST_ITEM_';
    my @res = ($el);
    if ( $lname =~ /^item|defn/ ) {
        $self->{IN_ITEM}++;

        #item element
        unless ( $self->{IN_ITEMLIST}++ ) {

            #determine item type
            my $pod_attr = $el->get_attr;

            #diag Dumper $pod_attr;
            my $itemlist = $self->mk_block('_LIST_ITEM_');
            $itemlist->attrs_by_name->{listtype}   = $el->item_type;
            $itemlist->attrs_by_name->{item_level} = $el->item_level;
            unshift @res, $self->mk_start_element($itemlist);
        }
        else {

            #check if need switch to level
            my $current_level =
              $self->current_element->attrs_by_name->{item_level};
            my $this_level = $el->item_level;
            my $current_type =
              $self->current_element->attrs_by_name->{listtype};
            my $this_type = $el->item_type;

            #delim item lists by level and by type
            unless ($current_level == $this_level
                and $current_type eq $this_type )
            {
                $self->switch_level($current_level,$this_level );
                #warn if level change over 1
                warn "=item level diff more than 1 level near:"
                  . $el->context->custom->{_line_num_}
                  if abs( $current_level - $this_level ) > 1;
                my $itemlist = $self->mk_block('_LIST_ITEM_');
                $itemlist->attrs_by_name->{listtype}   = $el->item_type;
                $itemlist->attrs_by_name->{item_level} = $el->item_level;
                unshift @res, $self->mk_start_element($itemlist);

                #close tag
                unshift @res,
                  $self->mk_end_element( $self->mk_block('_LIST_ITEM_') );

            }
        }
    }
    else {
        if ( delete $self->{IN_ITEMLIST} ) {
            unshift @res,
              $self->mk_end_element( $self->mk_block('_LIST_ITEM_') );
        }
        #reset levels
        $self->switch_level(0,0);
    }
    \@res;
}

sub switch_level {
    my $self = shift;
    my ($from, $to ) = @_;
    #set default level
    $from ||= $self->{"LAST_LIST_LEVEL"} || 0; 
    #save last level
    $self->{"LAST_LIST_LEVEL"} = $to;
    #skip switch to lower levels
    return if $to >= $from;
    #save last number for 1 level ( for :continued)
    if ( $to == 0 ) {
        $self->{LAST_FIRST_LEVEL_NUMBER}= $self->{"LAST_NUMBER_LEVEL_1"};
    }
    #reset counters for numbers
    for ( ($to+1)..$from) {
        delete $self->{"LAST_NUMBER_LEVEL_".${_}};
    }
}

sub set_numbering {
    my ($self, $el) = @_;
    my $item = $self->current_element();
    my $is_numbered = $item->is_numbered() || return;
    my $num_key =     "LAST_NUMBER_LEVEL_".$item->item_level;
    #check :continued only for first level items
    if ($item->item_level == 1 and $item->get_attr->{continued}) {
        # try continued or restore to 0
        $self->{$num_key} = $self->{LAST_FIRST_LEVEL_NUMBER} || 0;
    }
     $item->attrs_by_name->{number_value} = $el->attrs_by_name->{number_value}  =  ++ $self->{$num_key} 
   
}

sub on_end_element {
    my ( $self, $el ) = @_;
    my $lname = $el->local_name;
    if ( $lname =~ /^item|defn/ ) {
        delete $self->{IN_ITEM};
    }
    return $el;
}

sub end_document {
    my $self = shift;

    #special handle if itemlist at end of document
    if ( delete $self->{IN_ITEMLIST} ) {
        $self->_process_comm(
            $self->mk_end_element( $self->mk_block('_LIST_ITEM_') ) );
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
    if ( exists $self->{IN_ITEMLIST} and $el->local_name eq '_LIST_ITEM_' ) {
        $self->_process_comm(
            $self->mk_end_element( $self->mk_block('_LIST_ITEM_') ) );
        delete $self->{IN_ITEMLIST};
    }
    return $self->SUPER::on_para( $el, $txt );
}

1;
__END__


=head1 SEE ALSO

L<http://zag.ru/perl6-pod/S26.html>,
Perldoc Pod to HTML converter: L<http://zag.ru/perl6-pod/>,
Perl6::Pod::Lib

=head1 AUTHOR

Zahatski Aliaksandr, <zag@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2011 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

