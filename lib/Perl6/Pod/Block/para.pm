package Perl6::Pod::Block::para;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Block::para - handle B<=para> -ordinary paragraph

=head1 SYNOPSIS

=begin para

 =begin para
    This is an ordinary paragraph.
    Its text  will   be     squeezed     and
    short lines filled.

    This is I<still> part of the same paragraph,
    which continues until an...
 =end para


=head1 DESCRIPTION

B<=para> - Ordinary paragraph

Ordinary paragraph blocks consist of text that is to be formatted into a document at the current level of nesting, with whitespace squeezed, lines filled, and any special inline mark-up applied. 

=cut

use warnings;
use strict;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';
use Test::More;
use Data::Dumper;

sub to_xhtml { 
    my $self = shift;
    my $parser = shift;
    my $el = $parser->mk_element('p')->add_content( $parser->_make_elements( @_));
    return $el;
}


1;

__END__


=head1 SEE ALSO

L<http://perlcabal.org/syn/S26.html>

=head1 AUTHOR

Zahatski Aliaksandr, <zag@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 - 2010  by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut

