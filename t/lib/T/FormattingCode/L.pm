#===============================================================================
#
#  DESCRIPTION:  test L<> implementation
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::FormattingCode::L;

use strict;
use warnings;
use Test::More;
use Data::Dumper;
use Perl6::Pod::To::XHTML;
use XML::ExtOn('create_pipe');
use base 'TBase';

sub l02_to_xhtml : Test {
    my $t = shift;
    my $x = '';
    my $to_xhtml = new Perl6::Pod::To::XHTML:: out_put => \$x;
    my $p = create_pipe('Perl6::Pod::Parser', $to_xhtml);
    $p->parse(\<<TT);
=begin pod
=para
    L<http://www.perl.org>
=end pod
TT
$t->is_deeply_xml( $x,
q#<html xmlns='http://www.w3.org/1999/xhtml'><p>    <a href='http://www.perl.org'>http://www.perl.org</a>
</p></html>#)
}

sub l01_http : Test {
    return "skip";
    my $t = shift;
    my $x = $t->parse_to_xml( <<T);
=begin pod
test L<http://perl.org>
=end pod
T


$t->is_deeply_xml ( $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'>test <a href='http://perl.org'>http://perl.org</a>
 </para></pod>#
)
}


1;
