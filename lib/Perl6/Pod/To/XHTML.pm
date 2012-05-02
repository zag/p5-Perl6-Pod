package Test::Filter;
use strict;
use Test::More;
use XML::ExtOn('create_pipe');
use base 'XML::ExtOn';

sub on_start_element {
    my ( $self, $el ) = @_;
    if ( $el->local_name eq 'pod' ) {
        $el->delete_element;
    }
    return $el;
}
1;

package Perl6::Pod::To::XHTML;

#$Id$

=pod

=head1 NAME

 Perl6::Pod::To::XHTML - XHTML formater 

=head1 SYNOPSIS

    my $p = new Perl6::Pod::To::XHTML:: 
                header => 0, doctype => 'html';
fill html head
    my $p = new Perl6::Pod::To::XHTML:: 
                header => 1, doctype => 'html',
                head=>[ 
                    link=>
                        {
                            rel=>"stylesheet",
                            href=>"/styles/main.1232622176.css"
                        } 
                    ],
               body=>1 #add <body> tag. Default: 0;
    

=head1 DESCRIPTION

Process pod to xhtml

Sample:

        =begin pod
        =NAME Test chapter
        =para This is a test para
        =end pod

Run converter:

        pod6xhtml test.pod > test.xhtml

Result xml:

        <html xmlns='http://www.w3.org/1999/xhtml'>
          <head>
            <title>Test chapter</title>
          </head>
          <para>This is a test para</para>
        </html>

=cut

use strict;
use warnings;
use Perl6::Pod::To;
use base 'Perl6::Pod::To';
use Perl6::Pod::Utl;

use constant POD_URI => 'http://perlcabal.org/syn/S26.html';
use Data::Dumper;

sub start_write {
    my $self = shift;
    my $w    = $self->writer;
    if ( $self->{header} ) {
        $w->say(
q@<!DOCTYPE chapter PUBLIC '-//OASIS//DTD DocBook V4.2//EN' 'http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd' >@);
    }
    $self->w->raw_print( '<' . ( $self->{doctype} || 'html' ) . ' xmlns="http://www.w3.org/1999/xhtml">' );
}


sub end_write {
    my $self = shift;
    $self->w->raw_print( '</' . ( $self->{doctype} || 'html' ) . '>' );
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


