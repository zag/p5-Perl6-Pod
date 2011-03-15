#===============================================================================
#
#  DESCRIPTION:  test for lists
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::Parser::ListLevels;
use strict;
use warnings;
use base 'TBase';
use Test::More;
use Data::Dumper;

sub t1_test_groping : Test(1) {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, 'Perl6::Pod::Parser::ListLevels' );
=begin pod
=item i1
=item i2
=end pod
T1
    $t->is_deeply_xml(
        $x,
q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <_LIST_ITEM_ pod:type="block" pod:listtype="unordered" pod:item_level="1">
    <item pod:type="block">
      <_ITEM_ENTRY_ pod:type="block" pod:listtype="unordered">i1
</_ITEM_ENTRY_>
    </item>
    <item pod:type="block">
      <_ITEM_ENTRY_ pod:type="block" pod:listtype="unordered">i2
</_ITEM_ENTRY_>
    </item>
  </_LIST_ITEM_>
</pod>
#, 'group list'
    );
}

sub t2_two_interrupted_items_blocks : Test {

my $t = shift;
    my $x = $t->parse_to_xml( <<T1, 'Perl6::Pod::Parser::ListLevels' );
=begin pod
=item i1
=item i2
=head1 test
=item a1
=item a2
=end pod
T1
$t->is_deeply_xml ($x,
q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <_LIST_ITEM_ pod:type="block" pod:listtype="unordered" pod:item_level="1">
    <item pod:type="block">
      <_ITEM_ENTRY_ pod:type="block" pod:listtype="unordered">i1
</_ITEM_ENTRY_>
    </item>
    <item pod:type="block">
      <_ITEM_ENTRY_ pod:type="block" pod:listtype="unordered">i2
</_ITEM_ENTRY_>
    </item>
  </_LIST_ITEM_>
  <head1 pod:type="block">test
</head1>
  <_LIST_ITEM_ pod:type="block" pod:listtype="unordered" pod:item_level="1">
    <item pod:type="block">
      <_ITEM_ENTRY_ pod:type="block" pod:listtype="unordered">a1
</_ITEM_ENTRY_>
    </item>
    <item pod:type="block">
      <_ITEM_ENTRY_ pod:type="block" pod:listtype="unordered">a2
</_ITEM_ENTRY_>
    </item>
  </_LIST_ITEM_>
</pod>
#)

}

sub t3_list_type_ordered : Test(1) {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, 'Perl6::Pod::Parser::ListLevels' );
=begin pod
=for item :numbered
entry1
=for item :numbered
entry2
=end pod
T1
    $t->is_deeply_xml(
        $x,
        q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <_LIST_ITEM_ pod:type="block" pod:listtype="ordered" pod:item_level="1">
    <item pod:type="block" pod:number_value="1" numbered="1">
      <_ITEM_ENTRY_ pod:type="block" pod:number_value="1" pod:listtype="ordered">entry1
</_ITEM_ENTRY_>
    </item>
    <item pod:type="block" pod:number_value="2" numbered="1">
      <_ITEM_ENTRY_ pod:type="block" pod:number_value="2" pod:listtype="ordered">entry2
</_ITEM_ENTRY_>
    </item>
  </_LIST_ITEM_>
</pod>
#    );
}

sub t5_change_type_of_lists : Test(1) {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, 'Perl6::Pod::Parser::ListLevels' );
=begin pod
=for item 
entry1
=for defn
entry2
=end pod
T1
    $t->is_deeply_xml(
        $x,
        q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <_LIST_ITEM_ pod:type="block" pod:listtype="unordered" pod:item_level="1">
    <item pod:type="block">
      <_ITEM_ENTRY_ pod:type="block" pod:listtype="unordered">entry1
</_ITEM_ENTRY_>
    </item>
  </_LIST_ITEM_>
  <_LIST_ITEM_ pod:type="block" pod:listtype="definition" pod:item_level="1">
    <defn pod:type="block">
      <_DEFN_TERM_ pod:type="block">entry2</_DEFN_TERM_>
      <_ITEM_ENTRY_ pod:type="block" pod:listtype="definition">
</_ITEM_ENTRY_>
    </defn>
  </_LIST_ITEM_>
</pod>
#
    );
}


sub t06_old_style_defenitions_list : Test {

    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, 'Perl6::Pod::Parser::ListLevels' );
=begin pod
=for item :term('TE')
sds
=for item :term('TT')
* sd sds
=head1 sd
=end pod
T1
    $t->is_deeply_xml(
        $x,
q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <_LIST_ITEM_ pod:type="block" pod:listtype="definition" pod:item_level="1">
    <item pod:type="block" term="TE">
      <_DEFN_TERM_ pod:type="block">TE</_DEFN_TERM_>
      <_ITEM_ENTRY_ pod:type="block" pod:listtype="definition">sds
</_ITEM_ENTRY_>
    </item>
    <item pod:type="block" term="TT">
      <_DEFN_TERM_ pod:type="block">TT</_DEFN_TERM_>
      <_ITEM_ENTRY_ pod:type="block" pod:listtype="definition">* sd sds
</_ITEM_ENTRY_>
    </item>
  </_LIST_ITEM_>
  <head1 pod:type="block">sd
</head1>
</pod>
#);
}

sub t6_unordered_lists : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1,'Perl6::Pod::Parser::ListLevels');
=begin pod
=item1 aaitem
dsdsd
=item2 bbb
sd

=begin item1
aaa
=end item1

=end pod
T1
    $t->is_deeply_xml(
        $x,
q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <_LIST_ITEM_ pod:type="block" pod:listtype="unordered" pod:item_level="1">
    <item pod:type="block" pod:level="1">
      <_ITEM_ENTRY_ pod:type="block" pod:listtype="unordered">aaitem
dsdsd
</_ITEM_ENTRY_>
    </item>
  </_LIST_ITEM_>
  <_LIST_ITEM_ pod:type="block" pod:listtype="unordered" pod:item_level="2">
    <item pod:type="block" pod:level="2">
      <_ITEM_ENTRY_ pod:type="block" pod:listtype="unordered">bbb
sd
</_ITEM_ENTRY_>
    </item>
  </_LIST_ITEM_>
  <_LIST_ITEM_ pod:type="block" pod:listtype="unordered" pod:item_level="1">
    <item pod:type="block" pod:level="1">
      <_ITEM_ENTRY_ pod:type="block" pod:listtype="unordered">aaa
</_ITEM_ENTRY_>
    </item>
  </_LIST_ITEM_>
</pod>
#)
}

sub t7_ordered_lists : Test {

    my $t = shift;
    my $x = $t->parse_to_xml( <<T1,'Perl6::Pod::Parser::ListLevels');
=begin pod
=item1 # aaitem
=item1 # aaitem
=item2 # bbb
=item2 # cc
=para
asdasd
=for item1 :continuedd
# bbitem
=end pod
T1
    $t->is_deeply_xml(
        $x,q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <_LIST_ITEM_ pod:type="block" pod:listtype="ordered" pod:item_level="1">
    <item pod:type="block" pod:number_value="1" pod:numbered="1" pod:level="1">
      <_ITEM_ENTRY_ pod:type="block" pod:number_value="1" pod:listtype="ordered">aaitem
</_ITEM_ENTRY_>
    </item>
    <item pod:type="block" pod:number_value="2" pod:numbered="1" pod:level="1">
      <_ITEM_ENTRY_ pod:type="block" pod:number_value="2" pod:listtype="ordered">aaitem
</_ITEM_ENTRY_>
    </item>
  </_LIST_ITEM_>
  <_LIST_ITEM_ pod:type="block" pod:listtype="ordered" pod:item_level="2">
    <item pod:type="block" pod:number_value="1" pod:numbered="1" pod:level="2">
      <_ITEM_ENTRY_ pod:type="block" pod:number_value="1" pod:listtype="ordered">bbb
</_ITEM_ENTRY_>
    </item>
    <item pod:type="block" pod:number_value="2" pod:numbered="1" pod:level="2">
      <_ITEM_ENTRY_ pod:type="block" pod:number_value="2" pod:listtype="ordered">cc
</_ITEM_ENTRY_>
    </item>
  </_LIST_ITEM_>
  <para pod:type="block">asdasd
</para>
  <_LIST_ITEM_ pod:type="block" pod:listtype="ordered" pod:item_level="1">
    <item continuedd="1" pod:type="block" pod:number_value="1" pod:numbered="1" pod:level="1">
      <_ITEM_ENTRY_ pod:type="block" pod:number_value="1" pod:listtype="ordered">bbitem
</_ITEM_ENTRY_>
    </item>
  </_LIST_ITEM_>
</pod>
#)
}

1;

