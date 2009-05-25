package Perl6::Pod::To;

#$Id$

=pod

=head1 NAME

Perl6::Pod::To - base class for output formatters

=head1 SYNOPSIS


=head1 DESCRIPTION

Perl6::Pod::To - base class for output formatters

=cut

use strict;
use warnings;
use Perl6::Pod::Parser;
use Test::More;
use Data::Dumper;
use base qw/Perl6::Pod::Parser/;

sub on_start_block {
    my $self = shift;
    my $el   = shift;
    return $el unless $el->isa('Perl6::Pod::Block');
    $el->delete_element;
    return $el;
}

sub export_block {
    my ( $self, $elem, $text ) = @_;
    warn "Not overriden method"
}

sub on_para {
    my $self = shift;
    my ( $element, $text ) = @_;
    return $text unless $element->isa('Perl6::Pod::Block');

    #now process FormatCodes on para
    #
    #
    $element->{_CONTENT_} .= $text;
    return;
}

sub on_end_block {
    my $self = shift;
    my $el   = shift;
    return $el unless $el->isa('Perl6::Pod::Block');
    my $text = exists $el->{_CONTENT_} ? $el->{_CONTENT_} : undef;
    my $data = $self->export_block( $el, $text );
    my $cel = $self->current_element;
    if ($cel) {
        $cel->{_CONTENT_} .= $data;
        return;
    }
    else {

        # now prepare FormatCodes
        # now get format codes
        # use
        return $self->mk_from_xml($data);
    }
    return $el;
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


