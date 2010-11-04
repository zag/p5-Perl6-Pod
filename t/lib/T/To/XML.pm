#===============================================================================
#
#  DESCRIPTION:   Test XML formatter
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Test::Tag;
use strict;
#use warnings;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';
use XML::Flow;

sub to_xml {
    my ( $self, $parser, @in ) = @_;
    return "<p>@in</p>";
}
1;

package T::To::XML;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use XML::ExtOn::Writer;
use base 'T::To';

sub x1_create : Test(3) {
    my $t = shift;

    #tests for create
    my $buf0;
    my $o0 = new XML::ExtOn::Writer:: Output => \$buf0;
    ok UNIVERSAL::isa( $o0, 'XML::Filter::BufferText' ),
      'class of instance of XML::ExtOn::Writer';
    my ( $p0, $f0 ) = Perl6::Pod::To::to_abstract( 'Perl6::Pod::To::XML', $o0 );
    isa_ok( $f0->{out_put}, 'XML::ExtOn', 'if output is writer' );
    my $o1 = new XML::ExtOn::;
    my ( $p1, $f1 ) = Perl6::Pod::To::to_abstract( 'Perl6::Pod::To::XML', $o1 );
    isa_ok( $f1->{out_put}, 'XML::ExtOn', 'if output is ExtOn' );
}

sub x2_1para {
    my $t = shift;
    my $x= $t->parse_to_xml( <<T);
=begin pod
=begin para
test1

test2
=end para
=end pod
T
#    diag "a".$x; exit;    

}
sub x2_acodes : Test {
    my $t = shift;
    my $x= $t->parse_to_xml( <<TXT);
=begin pod
=use Test::Tag test2
=config test1 :we1
=begin para
N<erC<ds>>this is a para
=end para
=for test1 :w1
test
=for test2 
Heelo
=end pod
TXT
    $t->is_deeply_xml( $x, q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'><N pod:type='code'>er<C pod:type='code'>ds</C></N>this is a para
</para><test1 pod:type='block' we1='1' w1='1'>test
</test1><p>Heelo
 </p></pod>#);

}

sub x3_test_like :Test {
    my $t= shift;
    my $x = $t->parse_to_xml(<<T);
=begin pod
=config head1 :w1
=config TT<> :like<head1>
=head1 This is a head1

format code M<TT: test mssage>
=end pod
T
   $t->is_deeply_xml( $x, 
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><head1 pod:type='block' w1='1'>This is a head1
</head1><para pod:type='block'>format code <M pod:type='code'>TT: test mssage</M>
</para></pod>#)
}
1;


