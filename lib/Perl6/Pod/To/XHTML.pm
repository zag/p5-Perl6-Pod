package Test::Filter;
use strict;
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

package Perl6::Pod::To::XHTML;

#$Id$

=pod

=head1 NAME

 Perl6::Pod::To::XHTML - XHTML formater 

=head1 SYNOPSIS

    my $p = new Perl6::Pod::To::XHTML:: 
                header => 0, doctype => 'html';
fill html head
    my $p = new Perl6::Pod::To::XHTML:: 
                header => 1, doctype => 'html',
                head=>[ 
                    link=>
                        {
                            rel=>"stylesheet",
                            href=>"/styles/main.1232622176.css"
                        } 
                    ],
               body=>1 #add <body> tag. Default: 0;
    

=head1 DESCRIPTION

Process pod to xhtml

Sample:

        =begin pod
        =NAME Test chapter
        =para This is a test para
        =end pod

Run converter:

        pod6xhtml test.pod > test.xhtml

Result xml:

        <html xmlns='http://www.w3.org/1999/xhtml'>
          <head>
            <title>Test chapter</title>
          </head>
          <para>This is a test para</para>
        </html>

=cut

use strict;
use warnings;
use Perl6::Pod::To::XML;
use Perl6::Pod::Parser::ListLevels;
use Perl6::Pod::Parser::AddHeadLevels;
use Perl6::Pod::To::XHTML::ProcessHeadings;
use Perl6::Pod::To::XHTML::MakeHead;
use Perl6::Pod::To::XHTML::MakeBody;
use Perl6::Pod::Parser::Doformatted;
use XML::ExtOn('create_pipe');
use base qw/Perl6::Pod::To::XML/;
use constant POD_URI => 'http://perlcabal.org/syn/S26.html';
use Data::Dumper;

sub new {
    my $class = shift;
    my $self = $class->SUPER::new( body => 0, @_ );
    if ( my $heads = $self->{head} ) {

        #make head filter
        my $headfilter = new Perl6::Pod::To::XHTML::MakeHead:: head => $heads;
        $self->{out_put} = create_pipe( $headfilter, $self->{out_put} );

    }
    if ( $self->{body} ) {

        #make body
        my $add_body_filter = new Perl6::Pod::To::XHTML::MakeBody::;
        $self->{out_put} = create_pipe( $add_body_filter, $self->{out_put} );
    }
    $self->{out_put} =
      create_pipe( 'Perl6::Pod::To::XHTML::ProcessHeadings', $self->{out_put} );
    return create_pipe(
        'Perl6::Pod::Parser::Doformatted',
        'Perl6::Pod::Parser::ListLevels',
        'Perl6::Pod::Parser::AddHeadLevels',
        'Test::Filter',
        $self
    );
}

sub start_document {
    my $self = shift;
    if ( my $out = $self->out_parser ) {
        $out->start_document;
        if ( $self->{header} ) {
            $out->start_dtd(
                {
                    Name => $self->{doctype} || 'html',
                    PublicId => "-//W3C//DTD XHTML 1.1//EN",
                    SystemId => "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
                }
            );
            $out->end_dtd;
        }
        my $root = $out->mk_element( $self->{doctype} || 'html' );
        $out->on_start_prefix_mapping( '' => "http://www.w3.org/1999/xhtml" );
        $out->start_element($root);
    }
}

sub end_document {
    my $self = shift;
    if ( my $out = $self->out_parser ) {
        my $root = $out->mk_element( $self->{doctype} || 'html' );
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
    return $out_elem;
}

sub process_element {
    my $self = shift;
    my $elem = shift;
    my $res;
    if ( $elem->can('to_xhtml') ) {
        $res = $elem->to_xhtml( $self, @_ );
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
        foreach my $el (@data) {
            $el = $self->mk_characters($el) unless ref $el;
            $self->out_parser->_process_comm($el);
        }
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
    my @in   = $self->__expand_array_ref(@_);
    my @out  = ();
    foreach my $elem (@in) {
        push @out,
          ref($elem)
          ? $elem
          : $self->mk_characters( $self->_html_escape($elem) );
    }
    return @out;
}

sub export_block_item {
    my ( $self, $el, @p ) = @_;
    my $elem =
      $self->mk_element('listitem')->add_content( $self->_make_events(@p) );

    #add POD attr for use in export_block_itemlist
    #for varlistentry
    $elem->{POD} = $el->get_attr;
    return $elem;
}

sub export_block_itemlist {
    my ( $self, $el, @p ) = @_;
    my $attr = $el->attrs_by_name;
    my ( $list_name, $items_name ) = @{
        {
            ordered    => [ 'ol', 'li' ],
            unordered  => [ 'ul', 'li' ],
            definition => [ 'dl', 'dd' ]
        }->{ $attr->{listtype} }
      };
    my $list = $self->mk_element($list_name);
    foreach (@p) {
        next unless ref $_;
        my $lname = $_->local_name;
        if ( $lname eq 'listitem' ) {
            $_->local_name($items_name);

            #if variable list, then add varlistentry
            if ( $list->local_name eq 'dl' ) {
                my $term = $_->{POD}->{term};
                if ( ref($term) ) {
                    $term = join " ", @$term;
                }

                my $var_entry =
                  $self->mk_element('dt')
                  ->add_content( $self->mk_element('strong')
                      ->add_content( $self->mk_characters($term) ) );
                $var_entry->add_content($_);
                $list->add_content($var_entry);

            }
            else {
                $list->add_content($_);
            }

        }
    }

    return $list;
}

sub export_block_NAME {
    my ( $self, $el, $text ) = @_;
    my $head =
      $self->mk_element('head')
      ->add_content(
        $self->mk_element('title')->add_content( $self->mk_characters($text) )
      );

    #mark element as XHTML head
    $head->{XHTML_HEAD}++;
    return $head;
}

#process N footnote
sub export_block__NOTES_ {
    my ( $self, $el, @p ) = @_;
    my $div = $self->mk_element('div');
    $div->attrs_by_name->{class} = 'footnote';
    return $div->add_content(
        $self->mk_element('p')->add_content( $self->mk_characters("NOTES") ),
        $self->_make_events(@p) );

}

sub export_block__NOTE_ {
    my ( $self, $el, @p ) = @_;
    my $nid = $el->attrs_by_name->{note_id};
    my $a   = $self->mk_element('a');
    $a->attrs_by_name->{name} = "ftn.nid${nid}";
    $a->attrs_by_name->{href} = "#nid${nid}";
    $a->add_content(
        $self->mk_element('sup')->add_content( $self->mk_characters("$nid. ") )
    );
    return $self->mk_element('p')->add_content( $a, $self->_make_events(@p) );

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


