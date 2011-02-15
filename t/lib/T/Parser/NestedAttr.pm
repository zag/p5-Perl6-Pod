#===============================================================================
#
#  DESCRIPTION:  Test :nested
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::Parser::NestedAttr;
use strict;
use warnings;
use base "TBase";
use Test::More;
use Data::Dumper;
use XML::ExtOn qw(create_pipe);

sub f01_nested_attr : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T, 'Perl6::Pod::Parser::NestedAttr' );
=begin pod
=for para :nested(2)
test
=end pod
T

    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><blockquote pod:type='block'><blockquote pod:type='block'><para pod:type='block' nested='2'>test
</para></blockquote></blockquote></pod>#
      )

}

sub f03_nested_attr_xhtml : Test {
    my $t = shift;
    my $x = $t->parse_to_xhtml( <<T, );
=begin pod
=for para :nested(2)
test
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<xhtml xmlns='http://www.w3.org/1999/xhtml'><blockquote><blockquote><p>test
</p></blockquote></blockquote></xhtml>#
    );
}

sub f04_nested_attr_docbook : Test {
    my $t = shift;
    my $x = $t->parse_to_docbook( <<T, );
=begin pod
=for para :nested(2)
test
=end pod
T
    $t->is_deeply_xml(
        $x,
        q#<chapter><blockquote><blockquote><para nested='2'>test
</para></blockquote></blockquote></chapter>#
    );
}

1;

