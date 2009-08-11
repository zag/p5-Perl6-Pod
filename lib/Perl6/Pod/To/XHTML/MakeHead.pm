package Perl6::Pod::To::XHTML::MakeHead;

#$Id$

=pod

=head1 NAME

Perl6::Pod::To::XHTML::MakeHead - convert heads to sections

=head1 SYNOPSIS

    use Perl6::Pod::To::XHTML::MakeHead;
    $self->{out_put} =
    create_pipe( 'Perl6::Pod::To::XHTML::MakeHead', $self->{out_put});


=head1 DESCRIPTION

Perl6::Pod::To::XHTML::MakeHead - fill head part of document

=cut

use warnings;
use strict;
use XML::ExtOn;
use base 'XML::ExtOn';

sub on_start_element {
    my ( $self, $el ) = @_;
    return $el unless $self->{SKIP_ROOT}++;
    return $el if $self->{OK}++;
    my @out = ($el);
    unless ( $el->local_name eq 'head') {
        unshift (@out, $self->mk_element('head'))
    }
    return \@out
}

sub on_end_element {
    my ( $self, $el) = @_;
    return $el unless $el->local_name eq 'head';
    my @res= ($el);
    my $headers = $self->{head};
    while ( my ( $tag, $attr ) = splice @$headers, 0, 2 ) {
        my $element = $self->mk_element($tag);
        %{ $element->attrs_by_name} = %$attr;
        unshift @res, $element;
    }
    return \@res;
}
1;
