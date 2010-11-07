package Perl6::Pod::FormattingCode::N;

#$Id$

=pod

=head1 NAME

Perl6::Pod::FormattingCode::N - inline note

=head1 SYNOPSIS

 =begin code :allow<B>
    Use a C<for> loop instead.B<N<The Perl 6 C<for> loop is far more
    powerful than its Perl 5 predecessor.>> Preferably with an explicit
    iterator variable.
 =end code

=head1 DESCRIPTION

Anything enclosed in an C<NE<lt>E<gt>> code is an inline B<note>.
For example:

    Use a C<for> loop instead.B<N<The Perl 6 C<for> loop is far more
    powerful than its Perl 5 predecessor.>> Preferably with an explicit
    iterator variable.

Renderers may render such annotations in a variety of ways: as
footnotes, as endnotes, as sidebars, as pop-ups, as tooltips, as
expandable tags, etc. They are never, however, rendered as unmarked
inline text. So the previous example might be rendered as:


  Use a for loop instead. [*] Preferably with an explicit iterator
 variable.

and later:

    Footnotes
    [*] The Perl 6 for loop is far more powerful than its Perl 5
predecessor.

=cut

use warnings;
use strict;
use Data::Dumper;
use Perl6::Pod::FormattingCode;
use base 'Perl6::Pod::FormattingCode';

=head2 to_xhtml

A footnote reference and footnote text are output to HTML as follows:

Footnote reference:

 <sup>[<a name="id394062" href="#ftn.id394062">1</a>]</sup>

Footnote:

 <div class="footnotes"><p>NOTES</p>
 <p><a name="ftn.id394062" href="#id394062"><sup>1</sup></a>
 Text of footnote ... </p>
 <div>

You can change the formatting of the footnote paragraph using CSS. Use the div.footnote CSS selector, and apply whatever styles you want with it, as shown in the following example.

 div.footnote {
    font-size: 8pt;
 }

    
=cut

#FOR REAL processing SEE Perl6::Pod::To::*
sub to_xhtml {
    my ( $self, $p, @in ) = @_;

    #<sup><a name="id394062" href="#ftn.id394062">[1]</a></sup>

    my $nid   = $self->attrs_by_name->{n};
    my $aelem = $p->mk_element('a')->add_content( $p->mk_characters("[$nid]") );
    $aelem->attrs_by_name->{name} = "nid${nid}";
    $aelem->attrs_by_name->{href} = "#ftn.nid${nid}";
    $p->mk_element('sup')->add_content($aelem);

}

sub on_para {
    my ( $self, $p, $t ) = @_;
    my $nid = ++$p->{CODE_N_COUNT};
    $self->attrs_by_name->{n} = $nid;
    $p->{CODE_N_HASH}->{$nid} = {
        href        => "#nid${nid}",
        name        => "ftn.nid${nid}",
        text        => $t,
        parsed_para => $self->parse_para($t)
    };
    $self->SUPER::on_para( $p, $t );
}

=head2 to_docbook

#todo

=cut

sub to_docbook {
    my ( $self, $parser, @in ) = @_;
    my @content = $parser->_make_events(@in);
    my $emp     = $parser->mk_element('emphasis')->add_content(@content);
    $emp->attrs_by_name->{role} = 'italic';
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

