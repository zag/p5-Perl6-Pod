#===============================================================================
#
#  DESCRIPTION:  Do :nested(1) attr
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Perl6::Pod::Parser::NestedAttr;
=pod

=head1 NAME

Perl6::Pod::Parser::NestedAttr - handle nested attribs

=head1 SYNOPSIS

    =begin para
        We are all of us in the gutter,E<NL>
        but some of us are looking at the stars!
    =end para
    =begin para :nested(2)
            -- Oscar Wilde
    =end para

=head1 DESCRIPTION
Any block can be nested by specifying a C<:nested> option on it:

    =begin para :nested
        We are all of us in the gutter,E<NL>
        but some of us are looking at the stars!
    =end para

=cut

use strict;
use warnings;
use Data::Dumper;
use Test::More;
use base 'Perl6::Pod::Parser';

sub on_start_element {
    my $self = shift;
    my $el   = shift;
    my $attr = $el->get_attr;
    my @res  = ($el);
    if ( my $nested = $attr->{nested} ) {

        #get level
        ($nested) = @{ ref($nested) ? $nested : [$nested] };

        #wrap contents to format codes
        unshift @res, $self->mk_start_element( $el->mk_block('blockquote') )
          for ( 1 .. $nested );
    }
    return \@res;
}

sub on_end_element {
    my $self = shift;
    my $el   = shift;
    my $attr = $el->get_attr;
    my @res  = ($el);
    if ( my $nested = $attr->{nested} ) {

        #get level
        ($nested) = @{ ref($nested) ? $nested : [$nested] };

        #wrap contents to format codes
        push @res, $self->mk_end_element( $el->mk_block('blockquote') )
          for ( 1 .. $nested );
    }
    return \@res;
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

