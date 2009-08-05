package Perl6::Pod::Block::format;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Block::format - handle =format block

=head1 SYNOPSIS

    =for format :xml
    <root><test/></root>

    =for format :xhtml
    <div><br/></div>

    =for format :docbook
    <title>Test chapter</title>
    <para>This is a test para</para>

=head1 DESCRIPTION

B<=format> will let you have regions that are not generally interpreted as normal Pod text, but are passed directly to particular formatters. A formatter that can use that format will use the region, otherwise it will be completely ignored.

=cut

use warnings;
use strict;
use Data::Dumper;
use Test::More;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';

sub to_xhtml {
    my $self = shift;
    my $parser = shift;
    exists $self->get_attr->{xhtml} ? shift @_ : '';

}

sub to_xml {
    my $self = shift;
    my $parser = shift;
#    diag Dumper $self->get_attr;
    exists $self->get_attr->{xml} ? shift @_ : '';
}

sub to_docbook {
    my $self = shift;
    my $parser = shift;
    exists $self->get_attr->{docbook} ? shift @_ : '';
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

