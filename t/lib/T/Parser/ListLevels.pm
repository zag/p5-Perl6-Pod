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
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><itemlist pod:type='block' pod:listtype='unordered'><item pod:type='block'>i1
</item><item pod:type='block'>i2
</item></itemlist></pod>#, 'group list'
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
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><itemlist pod:type='block' pod:listtype='unordered'><item pod:type='block'>i1
</item><item pod:type='block'>i2
</item></itemlist><head1 pod:type='block'>test
</head1><itemlist pod:type='block' pod:listtype='unordered'><item pod:type='block'>a1
</item><item pod:type='block'>a2
</item></itemlist></pod>#)

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
        q#
<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><itemlist pod:type='block' pod:listtype='ordered'><item pod:type='block' numbered='1'>entry1
</item><item pod:type='block' numbered='1'>entry2
</item></itemlist></pod>#
    );
}

sub t4_list_type_unrdered : Test(1) {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, 'Perl6::Pod::Parser::ListLevels' );
=begin pod
=item test
=item test
=item test
=end pod
T1
    $t->is_deeply_xml(
        $x, q# 
<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><itemlist pod:type='block' pod:listtype='unordered'><item pod:type='block'>test
</item><item pod:type='block'>test
</item><item pod:type='block'>test
</item></itemlist></pod>#
      )

}

sub t5_definitions_list : Test(1) {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, 'Perl6::Pod::Parser::ListLevels' );
=begin pod
=para test
=for item :term<Term1>
=for item :term<Term2>
=for item :term<Term3>
=end pod
T1
    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'>test
</para><itemlist pod:type='block' pod:listtype='definition'><item pod:type='block' term='Term1' /><item pod:type='block' term='Term2' /><item pod:type='block' term='Term3' /></itemlist></pod>#
    );
}

sub t06_test_formatting_codes_in_lists : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, 'Perl6::Pod::Parser::ListLevels' );
=begin pod
=for item term:<TE>
sds L<dsd>
=for item term:<TT>
* sd sds
=head1 sd
=end pod
T1
    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><itemlist pod:type='block' pod:listtype='unordered'><item pod:type='block'>sds <L pod:section='' pod:type='code' pod:scheme='' pod:is_external='' pod:name='' pod:address=''>dsd</L>
</item><item pod:type='block'>* sd sds
</item></itemlist><head1 pod:type='block'>sd
</head1></pod>#);
}

sub t6_docbook : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, 'Perl6::Pod::Parser::ListLevels' );
T1

    "last";
}
1;

