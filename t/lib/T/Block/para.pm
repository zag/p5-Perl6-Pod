#===============================================================================
#
#  DESCRIPTION:  test =para block
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::Block::para;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use Perl6::Pod::To::XHTML;
use XML::ExtOn('create_pipe');
use base 'TBase';

sub p01_simple_para_block : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T);
=begin pod
=para
test
=begin para
test
=end para
=end pod
T
 $t->is_deeply_xml ( $x,
 q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'>test
 </para><para pod:type='block'>test
 </para></pod># )
}

sub p02_ordinared_para_in_pod : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T);
=begin pod
test
test

wewewe

test

=end pod
T

$t->is_deeply_xml ( $x, q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'>test
 test
</para><para pod:type='block'>wewewe
 </para><para pod:type='block'>test
 </para></pod># )

}

sub p03_foramting_codes :Test {
    my $t = shift;
    my $x = $t->parse_to_xml(<<T);
=begin pod
=para
  B<test> and I<test>

  Simple para I<test>
=end pod
T
 $t->is_deeply_xml( $x, q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <para pod:type="block"><B pod:type="code">test</B> and <I pod:type="code">test</I>
</para>
  <code pod:type="block"><![CDATA[  Simple para I<test>
]]></code>
</pod>
#)
}

sub p04_implicit_code_blocks :Test {
    my $t = shift;
    my $x = $t->parse_to_xml(<<T);
=begin pod
=begin para
  B<test> and I<test>
erer

 Simple para I<test>

sdsdsdsd
=end para
=end pod
T
 $t->is_deeply_xml( $x, q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <_PARA_CONTAINER_ pod:type="block">
    <para pod:type="block"><B pod:type="code">test</B> and <I pod:type="code">test</I>
erer</para>
    <para pod:type="block"> Simple para <I pod:type="code">test</I></para>
    <para pod:type="block">sdsdsdsd
</para>
  </_PARA_CONTAINER_>
</pod>
#)
}

sub p03_multi_para_xhtml :Test {
    my $t = shift;
    my $x = $t->parse_to_xhtml(<<T);
=begin pod
=begin para
    B<test> and I<test>

    Simple para I<test>
=end para
=end pod
T

$t->is_deeply_xml ( $x, q#<xhtml xmlns='http://www.w3.org/1999/xhtml'><p>    <strong>test</strong> and <em>test</em></p><p>    Simple para <em>test</em>
 </p></xhtml>#
 )

}

sub p03_multi_para_docbook :Test {
    my $t = shift;
    my $x = $t->parse_to_docbook(<<T);
=begin pod
=begin para
B<test> and I<test>

Simple para I<test>
=end para
=end pod
T

$t->is_deeply_xml ( $x, q#<?xml version="1.0"?>
<chapter>
  <para><emphasis role="bold">test</emphasis> and <emphasis role="italic">test</emphasis></para>
  <para>    Simple para <emphasis role="italic">test</emphasis>
</para>
</chapter>
#
 )

}

sub p04_to_xhml : Test {
    my $t= shift;
    my $x = '';
    my $to_xhtml = new Perl6::Pod::To::XHTML:: out_put => \$x;
    my $p = create_pipe('Perl6::Pod::Parser', $to_xhtml);
    $p->parse(\<<TT);
=begin pod
=para
    test code
=end pod
TT
$t->is_deeply_xml( $x,q#<html xmlns='http://www.w3.org/1999/xhtml'><p>    test code
 </p></html>#)
}

1;


