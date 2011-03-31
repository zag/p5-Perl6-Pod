package Perl6::Pod::FormattingCode::U;

#$Id$

=pod

=head1 NAME

Perl6::Pod::FormattingCode::U - Unusual text

=head1 SYNOPSIS

        =para
        the contained text is U<unusual>

=head1 DESCRIPTION

The C<UE<lt>E<gt>> formatting code specifies that the contained text is
B<unusual> or distinctive; that it is of I<minor significance>. Typically
such content would be rendered in an underlined style.

=cut

use warnings;
use strict;
use Data::Dumper;
use Perl6::Pod::FormattingCode;
use base 'Perl6::Pod::FormattingCode';

=head2 to_xhtml

    U<sample>

Render xhtml:

    <em class="unusual" >sample</em>

Use css style for underline style:

     .unusual {
     font-style: normal;
     text-decoration: underline;
     }

=cut

sub to_xhtml {
 my ( $self, $parser, @in ) = @_;
 my @content = $parser->_make_events(@in);
 my $emp =  $parser->mk_element('em')->add_content(@content);
 $emp->attrs_by_name->{class} = 'unusual';
 return $emp
}

=head2 to_docbook

    U<sample>

Render to

   <emphasis role='underline'>test</emphasis> 

=cut
#http://old.nabble.com/docbook-with-style-info-td25857763.html

sub to_docbook {
 my ( $self, $parser, @in ) = @_;
 my @content = $parser->_make_events(@in);
 my $emp = $parser->mk_element('emphasis')->add_content(@content);
 $emp->attrs_by_name->{role} = 'underline';
 return $emp;
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

Copyright (C) 2009-2011 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

