package Perl6::Pod::Block::pod;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Block::pod - handle =pod block

=head1 SYNOPSIS

    =begin pod
    para
     code
    =end pod

=head1 DESCRIPTION

B<=pod> - cause the parser to remain in Pod mode

In B<=pod> block:

=over

=item * within a C<=pod> ordinary paragraphs do not require an explicit marker or delimiters, but there is also an explicit para marker

=item * implicit code blocks may only be used within =pod, =item, =nested, =END, or semantic blocks. 

=back

=cut

use warnings;
use strict;
use Data::Dumper;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';

sub start {
    my $self = shift;

    #    warn "start";
    #$self->delete_element->skip_content;
}

sub _to_xml {
    my ( $self, $parser, @out ) = @_;

#    my $res = $parser->mk_cdata( \@out);
#    "<pod>".@_."</pod>"
#    my $el = $parser->mk_element('pod')->add_content( map {ref( $_ ) ? } @out );
#    $el;
}

sub on_para {
    my $self   = shift;
    my $parser = shift;
    my $txt    = shift;
    return unless defined $txt;

    #convert ordinary para to =para
    # and verbatim text to =code
    my $rparser = $self->context->{vars}->{root};

    #split para to ordinary and verbatim blocks
    foreach my $txt ( split /^\n/m, $txt ) {
        my $block_name = ( $txt =~ /^\s+/ ) ? 'code' : 'para';
        $rparser->start_block( $block_name, '', 666 );
        $rparser->para($txt);
        $rparser->end_block( $block_name, '', 666 );
    }
    return;
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

Copyright (C) 2009-2010 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

