#===============================================================================
#
#  DESCRIPTION:  test definition formatting code D<>
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::FormattingCode::D;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use Perl6::Pod::To::XHTML;
use base 'TBase';

sub t01_as_xml : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T);
=para
D<test>, and D<word|synonym1;synonym2>
T
    $t->is_deeply_xml(
        $x,
q#<?xml version="1.0"?>
<para xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block"><D pod:type="code" pod:synonyms="">test</D>, and <D pod:type="code" pod:synonyms="synonym1;synonym2">word</D></para>
#
    );
}

sub t02_as_xhtml : Test {
    my $t = shift;
    my $x = $t->parse_to_xhtml( <<T);
=para
D<test>, and D<word|synonym1;synonym2>
T
    $t->is_deeply_xml(
        $x,
        q#<?xml version="1.0"?>
<xhtml xmlns="http://www.w3.org/1999/xhtml">
  <p><dfn>test</dfn>, and <dfn>word</dfn></p>
</xhtml>
#
    );
}

sub t03_as_docbook : Test {
# Looks like you failed 1 test of 3.
    my $t = shift;
    my $x = $t->parse_to_docbook( <<T);
=para
D<test>, and D<word|synonym1;synonym2>
T
    $t->is_deeply_xml(
        $x,
        q#<chapter><para>test, and word
</para></chapter>
#
    );
}

1;



