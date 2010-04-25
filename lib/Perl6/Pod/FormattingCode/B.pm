package Perl6::Pod::FormattingCode::B;

#$Id$

=pod

=head1 NAME

Perl6::Pod::FormattingCode::B - Basis/focus of sentence

=head1 SYNOPSIS

        =para
        formatting code B<specifies>

=head1 DESCRIPTION

The C<BE<lt>E<gt>> formatting code specifies that the contained text is the basis or focus of the surrounding text; that it is of fundamental significance. Such content would typically be rendered in a bold style or in  C<E<lt>strongE<gt>>...C<E<lt>/strongE<gt>> tags.

=cut

use warnings;
use strict;
use Data::Dumper;
use Perl6::Pod::FormattingCode;
use base 'Perl6::Pod::FormattingCode';

=head2 to_xhtml

    B<test>

Render xhtml:

    <strong>test</strong>
    
=cut
sub to_xhtml {
 my ( $self, $parser, @in ) = @_;
 my @content = $parser->_make_events(@in);
 return $parser->mk_element('strong')->add_content(@content);
}

=head2 to_docbook

    B<test>

Render to

   <emphasis role='bold'>test</emphasis> 

=cut

sub to_docbook {
 my ( $self, $parser, @in ) = @_;
 my @content = $parser->_make_events(@in);
 my $emp = $parser->mk_element('emphasis')->add_content(@content);
 $emp->attrs_by_name->{role} = 'bold';
 return $emp;
}


1;
