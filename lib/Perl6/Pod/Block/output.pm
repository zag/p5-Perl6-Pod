#===============================================================================
#
#  DESCRIPTION:
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================

package Perl6::Pod::Block::output;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Block::output - handle =output block

=head1 SYNOPSIS

 =begin output
    Name:    Baracus, B.A.
    Rank:    Sgt
    Serial:  1PTDF007

    Do you want additional personnel details? K<y>

    Height:  180cm/5'11"
    Weight:  104kg/230lb
    Age:     49

    Print? K<n>
 =end output

=head1 DESCRIPTION

The =output block is used to specify pre-formatted terminal or file output which should also be rendered without rejustification or whitespace-squeezing. 

Export:

* to docbook as B<screen> element (http://www.docbook.org/tdg/en/html/screen.html)
* to html(http://www.w3.org/TR/html401/struct/text.html#edef-SAMP):
        <pre><samp>
        </samp></pre>

=cut

use warnings;
use strict;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';

sub to_xhtml {
    my $self   = shift;
    my $parser = shift;
    my $el =
      $parser->mk_element('samp')->add_content( $parser->_make_elements(@_) )
      ->insert_to( $parser->mk_element('pre') );
    return $el;
}

sub to_docbook {
    my $self   = shift;
    my $parser = shift;
    my $el =
      $parser->mk_element('screen')->add_content( $parser->_make_elements(@_) );
    return $el;
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

