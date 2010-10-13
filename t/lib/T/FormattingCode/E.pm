#===============================================================================
#
#  DESCRIPTION:  Entities code
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::FormattingCode::E;
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
Text  E<lt>
T
    $t->is_deeply_xml( $x,
q#<para pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'>Text <E pod:type='code'>lt</E></para>#
    );
}

sub t01_as_xhtml : Test {
    my $t= shift;
    my $x = $t->parse_to_xhtml( <<T);
=para
Text  E<lt> E<gt> E<nbsp> E<laquo> 
T
    ok $x =~ /&laquo;/;
#    $t->is_deeply_xml( $x,
# q#<xhtml xmlns='http://www.w3.org/1999/xhtml'><p>Text  &lt; &gt; &nbsp; &laquo; </p></xhtml># );
}
1;

