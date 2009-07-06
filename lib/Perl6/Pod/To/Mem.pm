package Perl6::Pod::To::Mem;

#$Id$

=pod

=head1 NAME

Perl6::Pod::To::Mem - create elements tree in memory

=head1 SYNOPSIS

    my $out = [];
    my $to_mem  = new Perl6::Pod::To::Mem:: out_put=>$out;
    my ( $p, $f ) = $test->make_parser(@filters,$to_mem);
    $p->parse( \$text );


=head1 DESCRIPTION

Perl6::Pod::To::Mem - create elements tree in memory

=cut

use warnings;
use strict;
use Perl6::Pod::To;
use base 'Perl6::Pod::To';

use Test::More;
use Data::Dumper;

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
    $self->{out_put} = [] unless exists $self->{out_put};
    return $self;
}

sub out_parser { $_[0]->{out_put} }

sub _make_xml_element {
    my $self     = shift;
    my $elem     = shift;
    my $e_type   = $elem->isa('Perl6::Pod::FormattingCode') ? 'code' : 'block';
    my $out_elem = {
        name => $elem->local_name,
        attr => $elem->get_attr
    };

    return $out_elem;
}

sub process_element {
    my $self = shift;
    my $elem = shift;
    my $res;
    if ( $elem->can('to_mem') ) {
        $res = $elem->to_mem( $self, @_ );
        unless ( ref($res) ) {
            $res = $res;
        }
    }
    else {

        #make characters from unhandled texts
        my @out_content = ();
        for (@_) {
            push @out_content, ref($_) ? $_ : $_;    #characters
        }
        $res = $self->_make_xml_element($elem);
        push @{ $res->{childs} }, @out_content;
    }
    return $res;
}

sub export_block {
    my $self = shift;
    return $self->process_element(@_);
}

sub export_code {
    my $self = shift;
    return $self->process_element(@_);
}

sub print_export {
    my $self = shift;
    push @{ $self->{out_put} }, @_

}

sub on_para {
    my $self = shift;
    my ( $element, $text ) = @_;
    chomp $text;
    push @{ $element->{_CONTENT_} }, $text;
    return;
}

sub on_end_block {
    my $self = shift;
    my $el   = shift;
    return $el unless $el->isa('Perl6::Pod::Block');
    my $content = exists $el->{_CONTENT_} ? $el->{_CONTENT_} : undef;
    my $data = $self->__handle_export( $el, @$content );
    my $cel = $self->current_element;
    if ($cel) {
        push @{ $cel->{_CONTENT_} }, ref($data) eq 'ARRAY' ? @$data : $data;
        return;
    }
    else {

        $self->print_export($data);
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

