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
use XML::ExtOn::Writer;
use XML::ExtOn('create_pipe');
use base qw/Perl6::Pod::To/;
use constant POD_URI => 'http://perlcabal.org/syn/S26.html';
use Data::Dumper;

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
    my $out   = $self->{out_put} || return $self;    #if empty out
    if ( UNIVERSAL::isa( $out, 'XML::Filter::BufferText' ) ) {
        $self->{out_put} = create_pipe( 'XML::ExtOn', $out );
    }
    elsif ( !UNIVERSAL::isa( $out, 'XML::ExtOn' ) ) {
        my $xml_writer = new XML::ExtOn::Writer:: Output => $out;
        $self->{out_put} = create_pipe( 'XML::ExtOn', $xml_writer );
    }
    return $self;
}

sub out_parser { $_[0]->{out_put} }

sub start_document {
    if ( my $out = $_[0]->out_parser ) {
        $out->start_document;
        $out->on_start_prefix_mapping( pod => POD_URI );
    }
}

sub end_document {
    if ( my $out = $_[0]->out_parser ) {
        $out->end_document;
    }
}

sub _make_xml_element {
    my $self     = shift;
    my $elem     = shift;
    my $e_type   = $elem->isa('Perl6::Pod::FormattingCode') ? 'code' : 'block';
    my $out_elem = $self->out_parser->mk_element( $elem->local_name );
    my ($out_attr, $attr) = ($out_elem->attrs_by_name, $elem->get_attr );
    while ( my ($key, $val) = each %$attr ) {
        my $xml_str = $val;
        if (ref($val) eq 'ARRAY') {
            $xml_str = join "," => @$val;
        }
        $out_attr->{$key}= $xml_str;
    }
    %{ $out_elem->attrs_by_ns_uri(POD_URI) } = %{ $elem->attrs_by_name};
    $out_elem->attrs_by_ns_uri(POD_URI)->{type} = $e_type;
    return $out_elem;
}

sub process_element {
    my $self = shift;
    my $elem = shift;
    my $res;
    if ( $elem->can('to_xml') ) {
        $res = $elem->to_xml($self, @_);
        unless ( ref( $res ) ) {
            $res = $self->out_parser->mk_from_xml( $res )
        } 
        return  $res
    }
    else {

        #make characters from unhandled texts
        my @out_content = ();
        for (@_) {
            push @out_content,
              ref($_) ? $_ : $self->out_parser->mk_characters($_);
        }
        $res = $self->_make_xml_element($elem)->add_content(@out_content);
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
    for (@_) {
        my @data = ref($_) eq 'ARRAY' ? @{$_} : $_;
        $self->out_parser->_process_comm($_) for @data;
    }
}

sub on_para {
    my $self = shift;
    my ( $element, $text ) = @_;
    push @{ $element->{_CONTENT_} }, $text;
    return;
}
sub on_start_block {
    my $self = shift;
    my $cname =''; 
    if ( my $current = $self->current_element) {
        $cname=$self->current_element->local_name;
    }
    return $self->SUPER::on_start_block(@_);
}

sub on_end_block {
    my $self = shift;
    my $el   = shift;
    return $el unless $el->isa('Perl6::Pod::Block');
    my $content = exists $el->{_CONTENT_} ? $el->{_CONTENT_} : undef;
    my $data = $self->__handle_export( $el, @$content );
    my $cel = $self->current_root_element;
    if ($cel) {
        push @{ $cel->{_CONTENT_} }, ref($data) eq 'ARRAY' ? @$data : $data;
        return;
    }
    else {
        $self->print_export($data);
    }
    return $el;
}

sub _make_events {
    my $self = shift;
    my @in = $self-> __expand_array_ref( @_);
    my @out = ();
    foreach my $elem ( @in ) {
        push @out, ref( $elem) ? $elem : $self->mk_characters($elem);
    }
    return @out
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

