package Perl6::Pod::FormattingCode::I;

#$Id$

=pod

=head1 NAME

Perl6::Pod::FormattingCode::I - Important 

=head1 SYNOPSIS

        =para
        formatting code I<specifies>

=head1 DESCRIPTION

The C<IE<lt>E<gt>> formatting code specifies that the contained text is important; that it is of major significance. Such content would typically be rendered in italics or in C<E<lt>emE<gt>>...C<E<lt>/emE<gt>> tags.

=cut

use warnings;
use strict;
use Data::Dumper;
use Perl6::Pod::FormattingCode;
use base 'Perl6::Pod::FormattingCode';

=head2 to_xhtml

    I<test>

Render xhtml:

    <em>test</em>
    
=cut
sub to_xhtml {
 my ( $self, $parser, @in ) = @_;
 my @content = $parser->_make_events(@in);
 return $parser->mk_element('em')->add_content(@content);
}

=head2 to_docbook

    I<test>

Render to

   <emphasis role='italic'>test</emphasis> 

=cut

sub to_docbook {
 my ( $self, $parser, @in ) = @_;
 my @content = $parser->_make_events(@in);
 my $emp = $parser->mk_element('emphasis')->add_content(@content);
 $emp->attrs_by_name->{role} = 'italic';
 return $emp;
}


1;

