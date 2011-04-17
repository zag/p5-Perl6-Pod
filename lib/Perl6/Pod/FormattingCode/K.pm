#===============================================================================
#
#  DESCRIPTION:  keyboard input
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Perl6::Pod::FormattingCode::K;
=pod

=head1 NAME

Perl6::Pod::FormattingCode::K - keyboard input

=head1 SYNOPSIS

        Do you want additional personnel details? K<y>

=head1 DESCRIPTION

The C<KE<lt>E<gt>> formatting code specifies that the contained text is
B<keyboard input>; that is: something that a user might type in. Such
content would typically be rendered in a fixed-width font (preferably a
different font from that used for the C<TE<lt>E<gt>> formatting code) or with
C< E<lt>kbdE<gt>...E<lt>/kbdE<gt> > tags. The contents of a C<KE<lt>E<gt>> code are always space-preserved. The C<KE<lt>E<gt>> code is the
inline equivalent of the C<=input> block.

=cut

use warnings;
use strict;
use Data::Dumper;
use Perl6::Pod::FormattingCode;
use base 'Perl6::Pod::FormattingCode';

=head2 to_xhtml

    K<test>

Render xhtml:

    <kbd>test</kbd>
    
=cut
sub to_xhtml {
 my ( $self, $parser, @in ) = @_;
 my @content = $parser->_make_events(@in);
 return $parser->mk_element('kbd')->add_content(@content);
}

=head2 to_docbook

    K<test>

Render to

   <userinput>test</userinput> 

L<http://docbook.ru/doc/dict/fromhtml.html>

=cut

sub to_docbook {
 my ( $self, $parser, @in ) = @_;
 my @content = $parser->_make_events(@in);
  $parser->mk_element('userinput')->add_content(@content);
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

