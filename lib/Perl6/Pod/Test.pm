package Perl6::Pod::Test;
#$Id$

=pod

=head1 NAME

Perl6::Pod::Test - test lib

=head1 SYNOPSIS


=head1 DESCRIPTION

=cut
use strict;
use warnings;

use Test::More;
use Perl6::Pod::To::Mem;
use Perl6::Pod::To::XML;
use Perl6::Pod::To::DocBook;
use Perl6::Pod::To::XHTML;
use XML::Flow;
use XML::ExtOn ('create_pipe');

sub new {
    my $class = shift;
    $class = ref $class if ref $class;
    my $self = bless( {@_}, $class );
    return $self;
}

=head2 parse_mem \$pod_str, ['filter1']

return out_put from To::Mem formatter

=cut

sub parse_mem {
    my $test = shift;
    my ( $text, @filters ) = @_;
    my $out = [];
    my $to_mem = new Perl6::Pod::To::Mem:: out_put => $out;
    my ( $p, $f ) = $test->make_parser( @filters, $to_mem );
    $p->parse( \$text );
    return wantarray ? ( $p, $f, $out ) : $out;

}

=head2 parse_mem \$pod_str, ['filter1']

return out_put from To::Mem formatter

=cut

sub parse_to_xml {
    my $test = shift;
    my ( $text, @filters ) = @_;
    my $out = '';
    my $to_mem = new Perl6::Pod::To::XML:: out_put => \$out;
    my ( $p, $f ) = $test->make_parser( @filters, $to_mem );
    $p->parse( \$text );
    return wantarray ? ( $p, $f, $out ) : $out;
}

sub make_xhtml_parser {
    my $t          = shift;
    my $out        = shift;
    my $xml_writer = new XML::SAX::Writer:: Output => $out;
    my $out_filters =
      create_pipe( create_pipe( @_ ? @_ : 'XML::ExtOn', $xml_writer ) );
    my ( $p, $f ) = Perl6::Pod::To::to_abstract(
        'Perl6::Pod::To::XHTML', $out,
        doctype => 'xhtml',
        headers => 0
    );
    return wantarray ? ( $p, $f ) : $p;
}

sub parse_to_xhtml {
    my $test = shift;
    my ( $text, @filters ) = @_;
    my $out    = '';
    my $to_mem = new Perl6::Pod::To::XHTML::
      out_put => \$out,
      doctype => 'xhtml',
      headers => 0;
    my ( $p, $f ) = $test->make_parser( @filters, $to_mem );
    $p->parse( \$text );
    return wantarray ? ( $p, $f, $out ) : $out;
}

sub parse_to_docbook {
    my $test = shift;
    my ( $text, @filters ) = @_;
    my $out    = '';
    my $to_mem = new Perl6::Pod::To::DocBook::
      out_put => \$out,
      doctype => 'chapter',
      headers => 0;
    my ( $p, $f ) = $test->make_parser( @filters, $to_mem );
    $p->parse( \$text );
    return wantarray ? ( $p, $f, $out ) : $out;
}

sub make_parser {
    my $test = shift;
    unless (@_) {
        my $class = $test->testing_class;
        my @args  = $test->new_args;
        my $obj   = $class->new(@args);
        push @_, $obj;
    }
    my $out_formatter = $_[-1];
    my $p = create_pipe( 'Perl6::Pod::Parser', @_ );
    return wantarray ? ( $p, $out_formatter ) : $p;

}

=head2 is_deeply_xml <got_xml>,<expected_xml>,"text"

Check xml without attribute values and character data

=cut

sub _xml_to_ref {

    #    my $self = shift;
    my $xml = shift;
    my %tags;

    #collect tags names;
    map { $tags{$_}++ } $xml =~ m/<(\w+)/gis;

    #make handlers
    our $res;
    for ( keys %tags ) {
        my $name = $_;
        $tags{$_} = sub {
            my $attr = shift || {};
            return $res = {
                name    => $name,
                attr    => [ keys %$attr ],
                content => [ grep { ref $_ } @_ ]
            };
          }
    }
    my $rd = new XML::Flow:: \$xml;
    $rd->read( \%tags );
    $res;
}

sub xml_ref {
    my $self = shift;
    my $xml  = shift;
    my %tags;

    #collect tags names;
    map { $tags{$_}++ } $xml =~ m/<(\w+)/gis;

    #make handlers
    our $res;
    for ( keys %tags ) {
        my $name = $_;
        $tags{$_} = sub {
            my $attr = shift || {};
            return $res = {
                name    => $name,
                attr    => $attr,
                content => [ grep { ref $_ } @_ ]
            };
          }
    }
    my $rd = new XML::Flow:: \$xml;
    $rd->read( \%tags );
    $res;

}

sub is_deeply_xml {
    my $test = shift;
    my ( $got, $exp, @params ) = @_;
    unless ( is_deeply $test->xml_ref($got), $test->xml_ref($exp), @params ) {
        diag "got:", "<" x 40;
        diag $got;
        diag "expected:", ">" x 40;
        diag $exp;

    }
}

1;
