package Perl6::Pod::FormattingCode::L;

#$Id$

=pod

=head1 NAME

Perl6::Pod::FormattingCode::L - handle "L" formatting code

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
use Data::Dumper;
use Perl6::Pod::FormattingCode;
use Perl6::Pod::Parser::Utils qw(parse_URI );
use base 'Perl6::Pod::FormattingCode';

sub on_para {
    my ( $self, $parser, $txt ) = @_;

    #extract linkname and content
    my ( $lname, $lcontent ) = ( '', defined $txt ? $txt : '' );
    my $attr = $self->attrs_by_name;
#=pod
    if ( $lcontent =~ /\|/ ) {
        my @all;
        ( $lname, @all ) = split( /\s*\|\s*/, $lcontent );
        $lcontent = join "", @all;
    }
    #clean whitespaces
    $lname =~ s/^\s+//;
    $lname =~ s/\s+$//;
    $attr->{name} = $lname;
    my ( $scheme, $address, $section ) =
      $lcontent =~ /\s*(\w+)\s*\:([^\#]*)(?:\#(.*))?/;
    $attr->{scheme} = $scheme||'';
    $address = '' unless defined $address;
    $attr->{is_external} = $address =~ s/^\/\/// || $scheme && $scheme !~ /^file/;

    #clean whitespaces
    $address =~ s/^\s+//;
    $address =~ s/\s+$//;
    $attr->{address} = $address;

    #fix L<doc:#Special Features>
    $attr->{section} = defined $section ? $section : '';
    #fix L<#id>
    if (!defined($scheme) and $lcontent ) {
        if ($lcontent =~ /^\s*(?:\#(.*))/) {
            $attr->{section} = $1
        }
    }
# =cut
#    %{$attr} = %{parse_URI($txt)};
    #parse nested formattings, i.e. L<B<name>|http://example.com>
    $self->SUPER::on_para($parser,$lname)
}

sub to_xhtml {
    my ( $self, $parser, @in ) = @_;
    my $attr = $self->attrs_by_name();
    for ( $attr->{scheme} ) {
        ( /^https?|.*$/ || $attr->{section} ) && do {
            my $a   = $parser->mk_element('a');
            my $url = $attr->{address};
            $url .= "#" . $attr->{section} if $attr->{section};
            $url = $_ . ":". (/^https?/ ? '//' : '') . $url if $attr->{is_external};
            my $name = $attr->{name} || $url;
            $a->attrs_by_name()->{href} = $url;
             $a->add_content( $parser->_make_events( scalar(@in) ? @in : $name ) );
            return $a;
          }
          || do { 
            return [ $parser->_make_events(@in) ];
            }
    }
}

sub to_docbook {
    my ( $self, $parser, @in ) = @_;
    my $attr = $self->attrs_by_name();
    for ( $attr->{scheme} ) {
        /^https?/  && do {
            my $ulink = $parser->mk_element('ulink');
            my $url   = $attr->{address};
            $url .= "#" . $attr->{section} if $attr->{section};
            $url = $_ . "://" . $url if $attr->{is_external};
            $ulink->attrs_by_name->{url} = $url;
            my $name = $attr->{name};
            $ulink->add_content( $name
                ? $parser->mk_characters($name)
                : $parser->_make_events(@in) );

            #        $ulink->add_content( $parser->mk_characters( $name ) );
            return $ulink;
          }
          || do { return $parser->mk_characters( $in[0] ) }
    }

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

