package Perl6::Pod::FormattingCode::L;

#$Id$

=pod

=head1 NAME

Perl6::Pod::FormattingCode::L - handle L<> formatting code

=head1 SYNOPSIS

A standard web URL. For example:

    This module needs the LAME library
    (available from L<http://www.mp3dev.org/mp3/>)


=head1 DESCRIPTION

The L<> code is used to specify all kinds of links, filenames, citations, and cross-references (both internal and external).

A link specification consists of a scheme specifier terminated by a colon, followed by an external address (in the scheme's preferred syntax), followed by an internal address (again, in the scheme's syntax). All three components are optional, though at least one must be present in any link specification.

Usually, in schemes where an internal address makes sense, it will be separated from the preceding external address by a #, unless the particular addressing scheme requires some other syntax. When new addressing schemes are created specifically for Perldoc it is strongly recommended that # be used to mark the start of internal addresses. 

=cut

use warnings;
use strict;
use Perl6::Pod::FormattingCode;
use base 'Perl6::Pod::FormattingCode';

sub on_para {
    my ($self , $parser, $txt) = @_;
    #make atts
    $txt;
}

sub to_xhtml {
    my ($self , $parser, @in) = @_;
    my $a = $parser->mk_element('a');
    $a->attrs_by_name()->{href} =  $in[0];
    $a->add_content( $parser->mk_characters( $in[0]) );
    return $a
}
1;

__END__


=head1 SEE ALSO

L<http://perlcabal.org/syn/S26.html>

=head1 AUTHOR

Zahatski Aliaksandr, <zag@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut

