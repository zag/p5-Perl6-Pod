#===============================================================================
#
#  DESCRIPTION:  test pod block
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$

package  T::Block::pod;
use strict;
use warnings;
use Test::More;
use base 'TBase';

sub p01_ordinary_para : Test {
    my $t = shift;
    my $x = $t->parse_to_xml(<<T);
=begin pod
ara tra

ererer

=end pod
T
    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'>ara tra
</para><para pod:type='block'>ererer
</para></pod>#
    );
}

sub p02_verbatim_para : Test {
    my $t = shift;
    my $x = $t->parse_to_xml(<<T);
=begin pod
 vermabim
    verbatim
=end pod
T

    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><code pod:type='block'><![CDATA[ vermabim
     verbatim
 ]]></code></pod>#
    );
}

sub p03_mixed_verbatim_ordinary_para : Test {
    my $t = shift;
    my $x = $t->parse_to_xml(<<T);
=begin pod
 vermabim
    verbatim

code code

 asdasd
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><code pod:type='block'><![CDATA[ vermabim
     verbatim
 ]]></code><para pod:type='block'>code code
 </para><code pod:type='block'><![CDATA[ asdasd
 ]]></code></pod>#
    );
}

1;

