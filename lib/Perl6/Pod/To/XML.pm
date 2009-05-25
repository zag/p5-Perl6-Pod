package Perl6::Pod::To::XML;

#$Id$

=pod

=head1 NAME

Perl6::Pod::To::XML - XML formatter 

=head1 SYNOPSIS


=head1 DESCRIPTION

DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !


=cut

use strict;
use warnings;
use Perl6::Pod::To;
use base qw/Perl6::Pod::To/;


sub export_block {
    my ( $self, $elem, $text ) = @_;
    return $elem->to_xml( $self, $text );
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

