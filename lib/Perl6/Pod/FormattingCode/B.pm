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
__END__

=head1 SEE ALSO

L<http://zag.ru/perl6-pod/S26.html>,
Perldoc Pod to HTML converter: L<http://zag.ru/perl6-pod/>,
Perl6::Pod::Lib

=head1 AUTHOR

Zahatski Aliaksandr, <zag@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2010 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

