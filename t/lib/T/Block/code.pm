#===============================================================================
#
#  DESCRIPTION: test block =code 
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$

package T::Block::code;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use Perl6::Pod::To::XHTML;
use XML::ExtOn('create_pipe');
use base 'TBase';


sub c001_explicit_implicit{
    my $t = shift;
    my $x = $t->parse_to_xml (<<T);
=begin pod
test para.test para.test.pas
=end pod
T
diag "a:".$x;exit;
}
sub c01_explicit_implicit : Test {
    my $t = shift;
    my $x = $t->parse_to_xml (<<T);
=begin pod
test para.test para.test.pas

  code block

some para

=code
    this is a code
=end pod
T
   $t->is_deeply_xml( $x, q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'>test para.test para.test.pas
</para><code pod:type='block'><![CDATA[  code block
]]></code><para pod:type='block'>some para
</para><code pod:type='block'><![CDATA[    this is a code
]]></code></pod>#)
}


sub c02_deny_format_codes : Test {
    my $t = shift;
    my $x = $t->parse_to_xml ( <<T);
=begin pod
    test B<some>

tets B<asdasd>
=end pod
T
    $t->is_deeply_xml( $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><code pod:type='block'><![CDATA[    test B<some>
]]></code><para pod:type='block'>tets <B pod:type='code'>asdasd</B>
</para></pod>#)

}

sub c02_to_xhml : Test {
    my $t= shift;
    my $x = '';
    my $to_xhtml = new Perl6::Pod::To::XHTML:: out_put => \$x;
    my $p = create_pipe('Perl6::Pod::Parser', $to_xhtml);
    $p->parse(\<<TT);
=begin pod
=code
    test code
=end pod
TT
    $t->is_deeply_xml( $x, q# <html xmlns='http://www.w3.org/1999/xhtml'><pre><code>    test code
 </code></pre></html># )
}

1;


