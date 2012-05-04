package Perl6::Pod::To::DocBook;

=head1 NAME

Perl6::Pod::To::DocBook - DocBook formater 

=head1 SYNOPSIS

    my $p = new Perl6::Pod::To::DocBook:: 
                header => 0, doctype => 'chapter';


=head1 DESCRIPTION

Process pod to docbook

Sample:

        =begin pod
        =NAME Test chapter
        =para This is a test para
        =end pod

Run converter:

        pod6docbook test.pod > test.xml

Result xml:

        <?xml version="1.0"?>
        <chapter>
          <title>Test chapter
        </title>
          <para>This is a test para
        </para>
        </chapter>


=cut

use strict;
use warnings;
use Perl6::Pod::To;
use base 'Perl6::Pod::To';
use Perl6::Pod::Utl;

sub block_NAME {
    my $self = shift;
    my $el   = shift;
    my $w  = $self->w;
    $w->raw('<title>');
    $self->visit_childs($el->childs->[0]);
    $w->raw('</title>');
}

sub block_head {
    my $self  =shift;
    my $el = shift;
    my $w  = $self->w;
    my $content = $el->childs->[0];
    $w->raw('<title>')
          ->print ($content)
      ->raw('</title>');
}


sub start_write {
    my $self = shift;
    my $w    = $self->writer;
    if ( $self->{header} ) {
        $w->say(
q@<!DOCTYPE chapter PUBLIC '-//OASIS//DTD DocBook V4.2//EN' 'http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd' >@);
    }
    $self->w->raw_print( '<' . ( $self->{doctype} || 'chapter' ) . '>' );
}


sub end_write {
    my $self = shift;
    $self->w->raw_print( '</' . ( $self->{doctype} || 'chapter' ) . '>' );
}



1;
__END__


=head1 SEE ALSO

L<http://perlcabal.org/syn/S26.html>

=head1 AUTHOR

Zahatski Aliaksandr, <zag@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2012 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

