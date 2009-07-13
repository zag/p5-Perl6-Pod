package Test::Filter;
use strict;
use warnings;
use Test::More;
use XML::ExtOn('create_pipe');
use base 'XML::ExtOn';

sub on_start_element {
    my ( $self, $el ) = @_;
    if ( $el->local_name eq 'pod' ) {
        $el->delete_element;
    }
    return $el;
}
1;

package Perl6::Pod::To::DocBook;

#$Id$

=pod

=head1 NAME

Perl6::Pod::To::DocBook - DocBook formatter 

=head1 SYNOPSIS

    header => 0, doctype => 'chapter'

=head1 DESCRIPTION

DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !


=cut

use strict;
use warnings;
use Perl6::Pod::To::XML;
use XML::SAX::Writer;
use Perl6::Pod::Parser::AddHeadLevels;
use Perl6::Pod::To::DocBook::ProcessHeads;
use XML::ExtOn('create_pipe');
use base qw/Perl6::Pod::To::XML/;
use constant POD_URI => 'http://perlcabal.org/syn/S26.html';
use Data::Dumper;

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
    $self->{out_put} = create_pipe( 'Perl6::Pod::To::DocBook::ProcessHeads', $self->{out_put});
    return create_pipe( 'Perl6::Pod::Parser::AddHeadLevels','Test::Filter', $self );
}

sub start_document {
    my $self = shift;
    if ( my $out = $self->out_parser ) {
        $out->start_document;
        if ( $self->{header} ) {
            $out->start_dtd(
                {
                    Name => $self->{doctype} || 'chapter',
                    PublicId => '-//OASIS//DTD DocBook V4.2//EN',
                    SystemId =>
                      'http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd'
                }
            );
            $out->end_dtd;
        }
        my $root = $out->mk_element( $self->{doctype} || 'chapter' );
        $out->start_element($root);
        #$out->on_start_prefix_mapping( pod => POD_URI );
    }
}

sub end_document {
    if ( my $out = $_[0]->out_parser ) {
        my $root = $out->mk_element( $_[0]->{doctype} || 'chapter' );
        $out->end_element($root);
        $out->end_document;
    }
}

sub _make_xml_element {
    my $self     = shift;
    my $elem     = shift;
    my $e_type   = $elem->isa('Perl6::Pod::FormattingCode') ? 'code' : 'block';
    my $out_elem = $self->out_parser->mk_element( $elem->local_name );
    my ( $out_attr, $attr ) = ( $out_elem->attrs_by_name, $elem->get_attr );
    while ( my ( $key, $val ) = each %$attr ) {
        my $xml_str = $val;
        if ( ref($val) eq 'ARRAY' ) {
            $xml_str = join "," => @$val;
        }
        $out_attr->{$key} = $xml_str;
    }

    #%{ $out_elem->attrs_by_name } = %{ $elem->get_attr };
    #$out_elem->attrs_by_ns_uri(POD_URI)->{type} = $e_type;

    # add use="SOME::Test::Element"
    #    if ( exists $elem->current_context->use->{ $e_type } )
    return $out_elem;
}

sub process_element {
    my $self = shift;
    my $elem = shift;
    my $res;
    if ( $elem->can('to_docbook') ) {
        $res = $elem->to_docbook( $self, @_ );
        unless ( ref($res) ) {
            $res = $self->out_parser->mk_from_xml($res);
        }
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



sub export_block_NAME {
    my ($self, $el , $text) = @_;
    return $self->mk_element('title')->add_content( $self->mk_characters( $text))
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

