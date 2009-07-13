package Perl6::Pod;

#$Id$

=pod

=head1 NAME

Perl6::Pod - use Perl6's pod in perl5 programms

=head1 SYNOPSIS


=head1 DESCRIPTION

Perl6::Pod - in general, a set of classes, scripts and modules for maintance Perl6's pod documentation using perl5.

The suite contain the following classes:

=over

=item * L<Perl6::Pod::Parser> - base class for perl6's pod parsers

=item * L<Perl6::Pod::Block> - base class for Perldoc blocks

=item * L<Perl6::Pod::FormattingCode> - base class for formatting code

=item * L<Perl6::Pod::To> - base class for output formatters

=back

DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !

=cut

$Perl6::Pod::VERSION = '0.02_01';

use warnings;
use strict;


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

