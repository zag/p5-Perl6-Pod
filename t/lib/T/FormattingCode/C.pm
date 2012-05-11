#===============================================================================
#
#  DESCRIPTION:  test C<> implementation
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::FormattingCode::C;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use base 'TBase';



sub t04_as_docbook : Test {
    my $t = shift;
    my $x = $t->parse_to_docbook( <<T);
=para
C<< test > & >>
T
    $t->is_deeply_xml( $x,
q#<chapter><para><code>test &gt; &amp;</code>
</para></chapter>#
    );
}


sub t05_extra : Test {
    my $t = shift;

    my $x = $t->parse_to_xhtml( <<T);
=para
C<< test > & E<nbsp> >>
T
    ok $x =~ /E&lt;nbsp&gt;/;
}


sub t06_allow_for_C : Test {
    my $t = shift;
    my $x = $t->parse_to_xhtml( <<T);
=config C<> :allow<I E>
=para
sdssd C«E<nbsp>»
T
    ok $x =~ m{<code>&nbsp;</code>};
}

sub t03_as_xhtml : Test {
    my $t = shift;
    my $x = $t->parse_to_xhtml( <<T);
=para
C<< test > & >>
T
    $t->is_deeply_xml( $x,
q# <xhtml xmlns='http://www.w3.org/1999/xhtml'><p><code>test &gt; &amp;</code>
 </p></xhtml>#
    );
}

sub t08_code_to_xhtml : Test {
     my $t = shift;
    my $x = $t->parse_to_xhtml( <<T);
=para
C<as> asds B<asdasI<d>sad >
T
    $t->is_deeply_xml( $x,
q#<xhtml xmlns="http://www.w3.org/1999/xhtml"><p><code>as</code> asds <strong>asdas<em>d</em>sad </strong>
 </p></xhtml>
#
    );
}


1;

