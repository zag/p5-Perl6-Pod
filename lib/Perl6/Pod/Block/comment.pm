package Perl6::Pod::Block::comment;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Block::comment - handle =comment block

=head1 SYNOPSIS

    =comment Don't nest this code block in the usual way...

=head1 DESCRIPTION

B<=comment> - Content to be ignored by all renderers

=cut

use warnings;
use strict;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';

sub start {
    my $self = shift;
    $self->delete_element->skip_content;
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

