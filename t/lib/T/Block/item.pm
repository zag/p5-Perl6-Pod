#===============================================================================
#
#  DESCRIPTION:  test lists
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::Block::item;
use strict;
use warnings;
use base 'TBase';
use Test::More;
use Data::Dumper;
use Perl6::Pod::Parser::ListLevels;

sub t1_test_multi_para : Test(1) {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, );
=begin pod
=item1 i1
=begin item1
parar1

para2
=end item1
=end pod
T1
    $t->is_deeply_xml(
        $x,
q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <item pod:type="block" pod:level="1">
    <_ITEM_ENTRY_ pod:type="block" pod:listtype="unordered">i1
</_ITEM_ENTRY_>
  </item>
  <item pod:type="block" pod:level="1">
    <_ITEM_ENTRY_ pod:type="block" pod:listtype="unordered" pod:is_multi_para='1' >
      <para pod:type="block">parar1</para>
      <para pod:type="block">para2
</para>
    </_ITEM_ENTRY_>
  </item>
</pod>#
    );
}

sub t2_numbering_symbol : Test(1) {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, );
=begin pod
=item # i1
i2
=item # i2
=end pod
T1
    $t->is_deeply_xml(
        $x,
q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <item pod:type="block" pod:numbered="1">
    <_ITEM_ENTRY_ pod:type="block" pod:listtype="ordered">i1
 i2
 </_ITEM_ENTRY_>
  </item>
  <item pod:type="block" pod:numbered="1">
    <_ITEM_ENTRY_ pod:type="block" pod:listtype="ordered">i2
 </_ITEM_ENTRY_>
  </item>
</pod>#
    );
}

sub t1_multi_line_and_numbered : Test(1) {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, );
=begin pod
=defn  # i1
i2
=defn item1
=end pod
T1
    $t->is_deeply_xml(
        $x,
q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <defn pod:type="block" pod:numbered="1">
    <_DEFN_TERM_ pod:type="block">i1</_DEFN_TERM_>
    <_ITEM_ENTRY_ pod:type="block" pod:listtype="definition">i2
</_ITEM_ENTRY_>
  </defn>
  <defn pod:type="block">
    <_DEFN_TERM_ pod:type="block">item1</_DEFN_TERM_>
    <_ITEM_ENTRY_ pod:type="block" pod:listtype="definition">
</_ITEM_ENTRY_>
  </defn>
</pod>#

    );
}

sub t2_multi_para : Test(1) {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, );
=begin pod
=begin defn
i1
i2

i3
=end defn
=defn item1
=end pod
T1
    $t->is_deeply_xml(
        $x,
q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <defn pod:type="block">
    <_DEFN_TERM_ pod:type="block">i1</_DEFN_TERM_>
    <_ITEM_ENTRY_ pod:is_multi_para='1' pod:type="block" pod:listtype="definition">
      <para pod:type="block">i2</para>
      <para pod:type="block">i3
</para>
    </_ITEM_ENTRY_>
  </defn>
  <defn pod:type="block">
    <_DEFN_TERM_ pod:type="block">item1</_DEFN_TERM_>
    <_ITEM_ENTRY_ pod:type="block" pod:listtype="definition">
 </_ITEM_ENTRY_>
  </defn>
</pod>
#
    );
}


sub t3_unnumbered_opt : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1,);
=begin pod
=item1 # aaitem
=for item1 :!numbered
# aaitem
=end pod
T1
    $t->is_deeply_xml(
        $x,q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <item pod:type="block" pod:numbered="1" pod:level="1">
    <_ITEM_ENTRY_ pod:type="block" pod:listtype="ordered">aaitem
</_ITEM_ENTRY_>
  </item>
  <item pod:type="block" numbered="0" pod:numbered="1" pod:level="1">
    <_ITEM_ENTRY_ pod:type="block" pod:listtype="unordered">aaitem
</_ITEM_ENTRY_>
  </item>
</pod>
#)
}

sub t4_implicit_code_blocks : Test(1) {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, );
=begin pod
=begin defn
i1

text

  code data
  data text

=end defn
=begin item
test

 code
 code


=end item
=end pod
T1
    $t->is_deeply_xml(
        $x,
q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <defn pod:type="block">
    <_DEFN_TERM_ pod:type="block">i1</_DEFN_TERM_>
    <_ITEM_ENTRY_ pod:is_multi_para="1" pod:type="block" pod:listtype="definition">
      <para pod:type="block">
text</para>
      <code pod:type="block"><![CDATA[  code data
  data text]]></code>
    </_ITEM_ENTRY_>
  </defn>
  <item pod:type="block">
    <_ITEM_ENTRY_ pod:is_multi_para="1" pod:type="block" pod:listtype="unordered">
      <para pod:type="block">test</para>
      <code pod:type="block"><![CDATA[ code
 code]]></code>
    </_ITEM_ENTRY_>
  </item>
</pod>
#
    );
}

1;
