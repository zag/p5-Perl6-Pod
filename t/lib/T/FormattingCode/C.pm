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
use Perl6::Pod::To::XHTML;
use XML::ExtOn('create_pipe');
use base 'TBase';

sub t01_as_xml : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T);
=para
C<test>
T
    $t->is_deeply_xml( $x,
q# <para pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><C pod:type='code'>test</C></para>#
    );
}

sub t02_as_xml_delims : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T);
=para
C<< test >  >>
T
#    diag $x;exit;
    $t->is_deeply_xml( $x,
q#<para pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><C pod:type='code'>test &amp;gt;</C></para>#
    );
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
    ok $x =~ /&nbsp;/;
#    diag $x;
#    $t->is_deeply_xml( $x,
#q#<chapter><para><code>test &gt; &amp;</code>
#</para></chapter>#
#   );
}


1;

