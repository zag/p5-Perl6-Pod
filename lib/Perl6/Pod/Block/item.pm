#===============================================================================
#
#  DESCRIPTION: ordered and unordered lists
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Perl6::Pod::Block::item;

=pod

=head1 NAME

Perl6::Pod::Block::item - lists

=head1 SYNOPSIS

     =item  Happy
     =item  Dopey
     =item  Sleepy

     =item1  Animal
     =item2     Vertebrate
     =item2     Invertebrate

=head1 DESCRIPTION

Lists in Pod are specified as a series of contiguous C<=item> blocks. No
special "container" directives or other delimiters are required to
enclose the entire list. For example:

     The seven suspects are:

     =item  Happy
     =item  Dopey
     =item  Sleepy
     =item  Bashful
     =item  Sneezy
     =item  Grumpy
     =item  Keyser Soze

List items have one implicit level of nesting:

Lists may be multi-level, with items at each level specified using the
C<=item1>, C<=item2>, C<=item3>, etc. blocks. Note that C<=item> is just
an abbreviation for C<=item1>. For example:

     =item1  Animal
     =item2     Vertebrate
     =item2     Invertebrate

     =item1  Phase
     =item2     Solid
     =item2     Liquid
     =item2     Gas
     =item2     Chocolate

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

=head2 Ordered lists

An item is part of an ordered list if the item has a C<:numbered>
configuration option:

     =for item1 :numbered
     Visito
    
     =for item2 :numbered
     Veni
   
     =for item2 :numbered
     Vidi
  
     =for item2 :numbered
     Vici

Alternatively, if the first word of the item consists of a single C<#>
character, the item is treated as having a C<:numbered> option:

     =item1  # Visito
     =item2     # Veni
     =item2     # Vidi
     =item2     # Vici


To specify an I<unnumbered> list item that starts with a literal C<#>, either
make the octothorpe verbatim:


    =item V<#> introduces a comment

or explicitly mark the item itself as being unnumbered:

    =for item :!numbered
    # introduces a comment

=head2 Unordered lists

List items that are not C<:numbered> are treated as defining unordered
lists. Typically, such lists are rendered with bullets. For example:

    =item1 Reading
    =item2 Writing
    =item3 'Rithmetic

=head2 Multi-paragraph list items

Use the delimited form of the C<=item> block to specify items that
contain multiple paragraphs. For example:

     Let's consider two common proverbs:
  
     =begin item :numbered
     I<The rain in Spain falls mainly on the plain.>
  
     This is a common myth and an unconscionable slur on the Spanish
     people, the majority of whom are extremely attractive.
     =end item
  
     =begin item :numbered
     I<The early bird gets the worm.>
 
     In deciding whether to become an early riser, it is worth
     considering whether you would actually enjoy annelids
     for breakfast.
     =end item

     As you can see, folk wisdom is often of dubious value.

=head2 Definition lists

    =defn  MAD
    Affected with a high degree of intellectual independence.

    =defn  MEEKNESS
    Uncommon patience in planning a revenge that is worth while.

    =defn
    MORAL
    Conforming to a local and mutable standard of right.
    Having the quality of general expediency.

=head1 METHODS

=cut

use strict;
use warnings;
use Data::Dumper;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';

# set type of item
sub start {
    my ( $self, $parser, $attr ) = @_;
    if ( my $txt = $self->context->custom->{_FIRST_PARA_LINE_} ) {
        if ( $txt =~ m/^\s*#\s+/ ) {
            $self->attrs_by_name->{numbered} = 1;

        }
    }
    return $self;
}

sub item_type {
    my $self = shift;

    #determine item type
    my $pod_attr = $self->get_attr;

    #for defn block name
    return 'definition'
      if $self->local_name eq 'defn'
          or exists $pod_attr->{term};

    my $type = 'unordered';
    if ( $self->is_numbered ) {

  #    if ( exists $pod_attr->{numbered} || $self->attrs_by_name->{numbered} ) {
        $type = 'ordered';
    }
    $type;
}

sub is_numbered {
    my $self     = shift;
    my $pod_attr = $self->get_attr;
    return $pod_attr->{numbered} if exists $pod_attr->{numbered};
    $self->attrs_by_name->{numbered} || 0;
}

sub item_level {
    my $self = shift;
    $self->attrs_by_name->{level} || 1;    #default 1 level for items
}

sub on_para {
    my $self   = shift;
    my $parser = shift;
    my $txt    = shift;

    #clean #
    if ( $txt =~ s/^\s*#\s+// ) {
        $self->attrs_by_name->{numbered} = 1;

    }
    my $line_num = $self->context->custom->{_line_num_};

    if ( $self->item_type eq 'definition' ) {

        #process definitions
        #The first non-blank line of content
        #is treated as a term being defined,
        #get term:
        #
        my $term;

        #try first get TERM from attribute
        if ( exists( $self->get_attr->{term} ) ) {
            $term = $self->get_attr->{term};
            ($term) =
              ref($term)
              ? @{$term}
              : ($term);

        }
        else {
            if ( $txt =~ s/[\s\n]*([^\s\n]+)(?:\Z|\n)// ) {
                $term = $1;
            }
        }
        if ( defined($term) ) {

            #$self->attrs_by_name->{term} = $1;
            #use special BLOCK
            $parser->start_block( '_DEFN_TERM_', '', $line_num );
            $parser->para($term);
            $parser->end_block( '_DEFN_TERM_', '', $line_num );
        }
    }

    #support multi paragrapth contents
    if ( ( my @paras = split( /[\n\r]\s*[\n\r]/, $txt ) ) > 1 ) {

        my $item_entry = $self->mk_block('_ITEM_ENTRY_');
        $item_entry->attrs_by_name->{is_multi_para} = 1;
        $item_entry->attrs_by_name->{listtype}      = $self->item_type;
        $parser->start_block($item_entry);

        # convert paragrapths to para
        for (@paras) {

       # check if block code
       #detect type of para
       #from S26
       #A code block may be implicitly specified as one or more lines of text,
       #each of which starts with a whitespace character at the block's virtual
       #left margin. The implicit code block is then terminated by a blank line.
            my $lines                 = scalar @{ [m/^/mg] };
            my $lines_with_whitespace = scalar @{ [m/^(\s+)\S+/mg] };
            my $block_type =
              ( $lines == $lines_with_whitespace ) ? 'code' : 'para';
            $parser->start_block( $block_type, '', $line_num );
            $parser->para($_);
            $parser->end_block( $block_type, '', $line_num );
        }
        $parser->end_block($item_entry);
        undef $txt;
        return;
    }
    my $item_entry = $self->mk_block('_ITEM_ENTRY_');
    $item_entry->attrs_by_name->{listtype} = $self->item_type;
    $parser->start_block($item_entry);
    $parser->run_para( $self->SUPER::on_para( $parser, $txt ) );
    $parser->end_block($item_entry);
    return undef;
}

=head2 to_xhtml

=over 1

=item Unordered lists

  =item Milk
  =item Toilet Paper
  =item Cereal
  =item Bread

  # <ul> - unordered list; bullets
  <ul>
   <li>Milk</li>
   <li>Toilet Paper</li>
   <li>Cereal</li>
   <li>Bread</li>
  </ul>

=item Ordered
    
    =for item :numbered
    Find a Job
    =item # Get Money
    =item # Move Out

  # <ol> - ordered list; numbers (<ol start="4" > for :continued)
    <ol>
     <li>Find a Job</li>
     <li>Get Money</li>
     <li>Move Out</li>
    </ol>

=item  definition list; dictionary

     =defn Fromage
     French word for cheese.
     =defn Voiture
     French word for car.

    * <dl> - defines the start of the list
    * <dt> - definition term
    * <dd> - defining definition

    <dl>
     <dt><strong>Fromage</strong></dt>
     <dd>French word for cheese.</dd>
     <dt><strong>Voiture</strong></dt>
     <dd>French word for car.</dd>
    </dt>

L<http://www.tizag.com/htmlT/lists.php>

=back
   
=cut

sub to_xhtml {
    my $self = shift;
    my ( $parser, @p ) = @_;

    #skip item element tagname
    return [ $parser->_make_events(@p) ];
}

sub to_docbook {
    my $self = shift;
    my ( $parser, @p ) = @_;
    if ( $self->item_type eq 'definition' ) {
        return $parser->mk_element('varlistentry')
          ->add_content( $parser->_make_events(@p) );
    }

    #setup type of _LIST_ITEM_
    if ( my $_LIST_ITEM_ = $parser->current_root_element ) {
        my $rattr = $_LIST_ITEM_->attrs_by_name;
        my $attr  = $self->attrs_by_name;

        #setup first number for ordered lists
        # 'continuation' docbook attribute
        # http://www.docbook.org/tdg/en/html/orderedlist.html
        if ( exists $attr->{number_value} ) {
            unless ( exists $rattr->{number_start} ) {
                $rattr->{number_start} = $attr->{number_value};
            }
        }
    }

    #skip item element tagname
    return [ $parser->_make_events(@p) ];
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

