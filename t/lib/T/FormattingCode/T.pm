#===============================================================================
#
#  DESCRIPTION:   test T<>
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
package T::FormattingCode::T;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use Perl6::Pod::To::XHTML;
use base 'TBase';

sub t01_as_xml : Test {
# Looks like you planned 3 tests but ran 1.
    my $t = shift;
    my $x = $t->parse_to_xml( <<T);
=para
Got C<uname> output : T<FreeBSD>
T
    $t->is_deeply_xml(
        $x,
q#<para pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'>Got <C pod:type='code'>uname</C> output : <T pod:type='code'>FreeBSD</T>
</para>

#
    );
}

sub t02_as_xhtml : Test {
    my $t = shift;
    my $x = $t->parse_to_xhtml( <<T);
=para
Got C<uname> output : T<FreeBSD>
T
    $t->is_deeply_xml(
        $x,
        q#<xhtml xmlns='http://www.w3.org/1999/xhtml'><p>Got <code>uname</code> output : <samp>FreeBSD</samp>
</p></xhtml>#
    );
}

sub t03_as_docbook : Test {
    my $t = shift;
    my $x = $t->parse_to_docbook( <<T);
=para
Got C<uname> output : T<FreeBSD>
T
    $t->is_deeply_xml(
        $x,
        q#<chapter><para>Got <code>uname</code> output : <computeroutput>FreeBSD</computeroutput>
</para></chapter>#
    );
}

1;





