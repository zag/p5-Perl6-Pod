#===============================================================================
#
#  DESCRIPTION:  test format block
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::Block::format;
use strict;
use warnings;
use Data::Dumper;
use Test::More;
use Perl6::Pod::Block::format;
use Perl6::Pod::To::DocBook;
use Perl6::Pod::To::XHTML;
use XML::ExtOn('create_pipe');
use base "TBase";

sub i1_check_xml_attr : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T, );
=begin pod
=use Perl6::Pod::Block::format format
=for format :xml
<asdasdasd>asdasd</asdasdasd><more>opr</more>
<br/>
=end pod
T
    $t->is_deeply_xml( $x,
q# <pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><asdasdasd>asdasd</asdasdasd><more>opr</more> <br /></pod>#
    );
}

sub i2_skip_format : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T, );
=begin pod
=use Perl6::Pod::Block::format format
=for format :xhtml
<asdasdasd>asdasd</asdasdasd><more>opr</more>
<br/>
=end pod
T
    $t->is_deeply_xml(
        $x,
q# <pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'></pod>#
    );
}

sub i3_attrs_in_chunk : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T, );
=begin pod
=use Perl6::Pod::Block::format format
=for format :xml
<div id="test_id" class="div"/>
test
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><div class='div' id='test_id' />
 test
 </pod>#
    );
}

sub i4_check_docbook :Test {
    my $t = shift;
    my $x = '';
    my $to_docbook = new Perl6::Pod::To::DocBook:: out_put => \$x;
    my $p = create_pipe('Perl6::Pod::Parser', $to_docbook);
    $p->parse(\<<TT);
=begin pod
=use Perl6::Pod::Block::format format
=para test para
=for format :docbook
<title ><para>format</para></title>
<para/>

=for format :xhtml
<hr/>
=end pod
TT
$t->is_deeply_xml ( $x, 
q#<chapter><para>test para
</para><title><para>format</para></title>
<para />
</chapter># )
}

sub i5_check_xhtml :Test {
    my $t = shift;
    my $x = '';
    my $to_docbook = new Perl6::Pod::To::XHTML:: out_put => \$x;
    my $p = create_pipe('Perl6::Pod::Parser', $to_docbook);
    $p->parse(\<<TT);
=begin pod
=use Perl6::Pod::Block::format format
=head1 test
=for format :xhtml
<div id="id1" class="class1"><p>test</p></div>
<hr/>
=for format :txt
This is a test
=end pod
TT
$t->is_deeply_xml ($x,
q# <html xmlns='http://www.w3.org/1999/xhtml'><h1>test
 </h1><div class='class1' id='id1'><p>test</p></div>
 <hr />
 </html>#)
}
1

