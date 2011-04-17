#===============================================================================
#
#  DESCRIPTION:  test Z<>
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::FormattingCode::Z;
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
The Z<TWEST>
T
is $x,q#<para pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'>The 
</para>#;
}

1;



