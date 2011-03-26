#===============================================================================
#
#  DESCRIPTION:  test block =nested
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$

package T::Block::nested;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use Perl6::Pod::To::XHTML;
use XML::ExtOn('create_pipe');
use base 'TBase';

sub c01_nested_nested : Test {
    my $t = shift;
    my $x = $t->parse_to_xml(<<T);
=begin pod
=begin nested
=begin nested
Test B<er>
=end nested
=end nested
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <nested pod:type="block">
    <nested pod:type="block">
      <para pod:type="block">Test <B pod:type="code">er</B>
</para>
    </nested>
  </nested>
</pod>
#
    );
}

sub c02_as_docbook : Test {
    my $t = shift;
    my $x = $t->parse_to_docbook(<<T);
=begin pod
=begin nested
=begin nested
Test B<er>
=end nested
=end nested
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<?xml version="1.0"?>
<chapter>
  <blockquote>
    <blockquote>
      <para>Test <emphasis role="bold">er</emphasis>
</para>
    </blockquote>
  </blockquote>
</chapter>
#
    );
}

sub c02_as_xhml : Test {
    my $t = shift;
    my $x = $t->parse_to_xhtml(<<T);
=begin pod
=begin nested
=begin nested
Test B<er>
=end nested
=end nested
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<?xml version="1.0"?>
<xhtml xmlns="http://www.w3.org/1999/xhtml">
  <blockquote>
    <blockquote>
      <p>Test <strong>er</strong>
</p>
    </blockquote>
  </blockquote>
</xhtml>
#
    );
}


sub c03_implicit_code : Test {
    my $t = shift;
    my $x = $t->parse_to_xml(<<T);
=begin pod
=begin nested
para1

 apara1
 wawe

  para2 asd asd
asdad
=end nested
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <nested pod:type="block">
    <para pod:type="block">para1</para>
    <code pod:type="block"><![CDATA[ apara1
  wawe]]></code>
    <para pod:type="block">  para2 asd asd
 asdad
 </para>
  </nested>
</pod>
#);
}


1;
