#===============================================================================
#  DESCRIPTION:  Base class for tests
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================
package TBase;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Perl6::Pod::To::Mem;
use Perl6::Pod::To::XML;
use XML::Flow;
use XML::ExtOn ('create_pipe');

sub testing_class {
    my $test = shift;
    ( my $class = ref $test ) =~ s/^T[^:]*::/Perl6::Pod::/;
    return $class;
}

sub new_args { () }

sub _use : Test(startup=>1) {
    my $test = shift;
    use_ok $test->testing_class;
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
    unless (  is_deeply $test->xml_ref($got), $test->xml_ref($exp), @params ) {
        diag "got:", "<" x40;
        diag $got;
        diag "expected:", ">" x40;
        diag $exp;

    };
}

sub startup : Test(startup) {

    #    ok (1,'s1')
}

1;

