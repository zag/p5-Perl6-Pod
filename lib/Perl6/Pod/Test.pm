package Perl6::Pod::To::Test;
use strict;
use warnings;
use Perl6::Pod::To;
use base 'Perl6::Pod::To';
sub __default_method {
    my $self   = shift;
    my $n      = shift;
    unless (defined $n) {
    warn "default" . $n;
    use Data::Dumper;
    warn Dumper([caller(0)]);
    }
#    $self->SUPER::__default_method($n);
    push @{ $self->{ $n->{name} } }, $n;
}

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
use Perl6::Pod::Writer;

use Perl6::Pod::To::Mem;
use Perl6::Pod::To::XML;
use Perl6::Pod::To::DocBook;
use Perl6::Pod::To::XHTML;
use XML::ExtOn::Writer;
use XML::Flow;
use XML::ExtOn qw( create_pipe split_pipe);

sub parse_to_docbook {
    shift if ref($_[0]);
    my ( $text) = @_;
    my $out    = '';
    open( my $fd, ">", \$out );
    my $renderer = new Perl6::Pod::To::DocBook::
      writer  => new Perl6::Pod::Writer( out => $fd, escape=>'xml' ),
      out_put => \$out,
      doctype => 'chapter',
      header => 0;
    $renderer->parse( \$text, default_pod=>1 );
    return wantarray ? (  $out, $renderer  ) : $out;

}


sub parse_to_xhtml {
    shift if ref($_[0]);
    my ( $text) = @_;
    my $out    = '';
    open( my $fd, ">", \$out );
    my $renderer = new Perl6::Pod::To::XHTML::
      writer  => new Perl6::Pod::Writer( out => $fd, escape=>'xml' ),
      out_put => \$out,
      doctype => 'xhtml',
      header => 0;
    $renderer->parse( \$text, default_pod=>1 );
    return wantarray ? (  $out, $renderer  ) : $out;
}

sub parse_to_test {
    shift if ref($_[0]);
    my ( $text) = @_;
    my $out    = '';
    open( my $fd, ">", \$out );
    my $renderer = new Perl6::Pod::To::Test::
      writer  => new Perl6::Pod::Writer( out => $fd, escape=>'xml' ),
      out_put => \$out,
      doctype => 'xhtml',
      header => 0;
    $renderer->parse( \$text, default_pod=>1 );
    return  $renderer 

}
sub new {
    my $class = shift;
    $class = ref $class if ref $class;
    my $self = bless( {@_}, $class );
    return $self;
}

=head2 parse_to_xml \$pod_str, ['filter1']

return out_put from To::Mem formatter

=cut

sub parse_to_xml {
    my $test = shift;
    my ( $text, @filters ) = @_;
    my $out = '';
    my $to_mem = new Perl6::Pod::To::XML:: out_put => \$out;
#    $to_mem->parse(\$text);
#    return wantarray ? ( $to_mem, $f, $out ) : $out;
    my ( $p, $f ) = $test->make_parser( @filters, $to_mem );
    $p->parse( \$text );
    return wantarray ? ( $p, $f, $out ) : $out;
}

=head2 pod2xml \$pod_str, ['filter1']

return out_put from To::Mem formatter

=cut

sub pod6xml {
    my $test = shift;
    my ( $text, @filters ) = @_;
    my $out = '';
    my $to_mem = new Perl6::Pod::To::XML:: out_put => \$out, header=>1;
    my $p = create_pipe(@filters,$to_mem);
    $p->parse(\$text);
    return wantarray ? ( $to_mem, $out ) : $out;
}

sub make_xhtml_parser {
    my $t          = shift;
    my $out        = shift;
    my $xml_writer = new XML::ExtOn::Writer:: Output => $out;
    my $out_filters =
      create_pipe( create_pipe( @_ ? @_ : 'XML::ExtOn', $xml_writer ) );
    my ( $p, $f ) = Perl6::Pod::To::to_abstract(
        'Perl6::Pod::To::XHTML', $out,
        doctype => 'xhtml',
        headers => 0
    );
    return wantarray ? ( $p, $f ) : $p;
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
