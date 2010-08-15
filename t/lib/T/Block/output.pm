#===============================================================================
#
#  DESCRIPTION:  test output block
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$

package  T::Block::output;
use strict;
use warnings;
use Test::More;
use base 'TBase';

sub p01_xml : Test {
    my $t = shift;
    my $x = $t->parse_to_xml(<<T);
=begin pod

=output
  1.2.3
  sdsd sd sd sd

=end pod
T
$t->is_deeply_xml(
        $x,
q# <pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><output pod:type='block'>  1.2.3
           sdsd sd sd sd
</output></pod>#
    );
}


sub p02_xhtml : Test {
    my $t = shift;
    my $x = $t->parse_to_xhtml(<<T);
=begin pod

=output
  1.2.3
  sdsd sd sd sd

=end pod
T
$t->is_deeply_xml(
        $x,
q#<xhtml xmlns='http://www.w3.org/1999/xhtml'><pre><samp>  1.2.3
   sdsd sd sd sd
 </samp></pre></xhtml>#
    );
}

sub p03_docbook : Test {
    my $t = shift;
    my $x = $t->parse_to_docbook(<<T);
=begin pod
=output
  1.2.3
  sdsd sd sd sd

=end pod
T
$t->is_deeply_xml(
        $x,
q# <chapter><screen>  1.2.3
   sdsd sd sd sd
 </screen></chapter>#
    );
}


1;

