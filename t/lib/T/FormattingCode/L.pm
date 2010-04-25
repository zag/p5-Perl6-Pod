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

sub l001_syntax_Whitespace : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T);
=begin pod
test L<  http://perl.org  >
test L< haname | http:perl.html  >
=end pod
T
    $t->is_deeply_xml(
        $x,
q% <pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'>test <L pod:section='' pod:type='code' pod:scheme='http' pod:is_external='1' pod:name='' pod:address='perl.org'>  http://perl.org  </L>
test <L pod:section='' pod:type='code' pod:scheme='http' pod:is_external='' pod:name='haname' pod:address='perl.html'> haname | http:perl.html  </L>
 </para></pod>%
    );
}

sub l01_http_local_remote : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T);
=begin pod
test L<http://perl.org>
test L<http:perl.html>
=end pod
T
    $t->is_deeply_xml(
        $x,
        q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'>
 <para pod:type='block'>test 
<L pod:section='' pod:type='code' pod:scheme='http' pod:is_external='1' pod:name='' pod:address='perl.org'>http://perl.org</L>
test 
<L pod:section='' pod:type='code' pod:scheme='http' pod:is_external='' pod:name='' pod:address='perl.html'>http:perl.html</L>
</para></pod>#
    );
}

sub l02_http_link_name_and_section : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T);
=begin pod
L<somename|http://perl.org>
L<somename|http://perl.org#Some>
=end pod
T

    $t->is_deeply_xml(
        $x,
q%<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'>
<L pod:section='' pod:type='code' pod:scheme='http' pod:is_external='1' pod:name='somename' pod:address='perl.org'>somename|http://perl.org</L>
<L pod:section='Some' pod:type='code' pod:scheme='http' pod:is_external='1' pod:name='somename' pod:address='perl.org'>somename|http://perl.org#Some</L>
</para></pod>%
    );
}

sub a05_http_scheme_to_xhtml : Test {
    my $t        = shift;
    my $x        = '';
    my $to_xhtml = new Perl6::Pod::To::XHTML:: out_put => \$x;
    my $p        = create_pipe( 'Perl6::Pod::Parser', $to_xhtml );
    $p->parse( \<<TT);
=begin pod
=para
L<http://www.perl.org>
L< name |http://www.perl.org>
L< name |http://www.perl.org#Some>
=end pod
TT
    $t->is_deeply_xml(
        $x,
q%<html xmlns='http://www.w3.org/1999/xhtml'><p><a href='http://www.perl.org'>www.perl.org</a>
<a href='http://www.perl.org'>name</a>
<a href='http://www.perl.org#Some'>name</a>
 </p></html>%

    );
}

sub l06_file_scheme : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T);
=begin pod
L<file:CONFIG/.configrc>
L<file:/usr/local/lib/.configrc> 
L<file:~/.configrc>)
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'>
<L pod:section='' pod:type='code' pod:scheme='file' pod:is_external='' pod:name='' pod:address='CONFIG/.configrc'>file:CONFIG/.configrc</L>
<L pod:section='' pod:type='code' pod:scheme='file' pod:is_external='' pod:name='' pod:address='/usr/local/lib/.configrc'>file:/usr/local/lib/.configrc</L> 
<L pod:section='' pod:type='code' pod:scheme='file' pod:is_external='' pod:name='' pod:address='~/.configrc'>file:~/.configrc</L>)
 </para></pod>#
      )

}

sub l08_mailto_scheme : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<'T');
=begin pod
L<mailto:devnull@rt.cpan.org>
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'><L pod:section='' pod:type='code' pod:scheme='mailto' pod:is_external='' pod:name='' pod:address='devnull@rt.cpan.org'>mailto:devnull@rt.cpan.org</L>
</para></pod>#
    );
}

sub l09_doc_scheme : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<'T');
=begin pod
L<doc:Data::Dumper>
L<doc:perldata>
L<doc:#Special Features>
=end pod
T
    $t->is_deeply_xml(
        $x,
q%<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'>
<L pod:section='' pod:type='code' pod:scheme='doc' pod:is_external='' pod:name='' pod:address='Data::Dumper'>doc:Data::Dumper</L>
<L pod:section='' pod:type='code' pod:scheme='doc' pod:is_external='' pod:name='' pod:address='perldata'>doc:perldata</L>
<L pod:section='Special Features' pod:type='code' pod:scheme='doc' pod:is_external='' pod:name='' pod:address=''>doc:#Special Features</L>
</para></pod>%
    );
}

sub l10_defn_isbn_issn : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<'T');
=begin pod
L<defn:lexiphania>
L<issn:1087-903X>
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'><L pod:section='' pod:type='code' pod:scheme='defn' pod:is_external='' pod:name='' pod:address='lexiphania'>defn:lexiphania</L>
<L pod:section='' pod:type='code' pod:scheme='issn' pod:is_external='' pod:name='' pod:address='1087-903X'>issn:1087-903X</L>
</para></pod>#
    );

}

sub l11_man_scheme : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<'T');
=begin pod
L<man:find(1)>
L<man:bash(1)#Compound Commands>
=end pod
T
    $t->is_deeply_xml(
        $x,
q%<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'>
<L pod:section='' pod:type='code' pod:scheme='man' pod:is_external='' pod:name='' pod:address='find(1)'>man:find(1)</L>
<L pod:section='Compound Commands' pod:type='code' pod:scheme='man' pod:is_external='' pod:name='' pod:address='bash(1)'>man:bash(1)#Compound Commands</L>
 </para></pod>%
      )

}

sub l12_link_with_name_docbook : Test {
    my $t  = shift;
    my $x = $t->parse_to_docbook( <<'T');
=begin pod
=NAME  test L<name|http://test> test
=end pod
T
    $t->is_deeply_xml( $x, q# <chapter><title>test <ulink url='http://test'>name</ulink> test
</title></chapter>#);
}

sub l13_link_only_addr_docbook : Test {
    my $t  = shift;
    my $x = $t->parse_to_docbook( <<'T');
=begin pod
=NAME  test L<http://example.com> test
=end pod
T
    $t->is_deeply_xml( $x, q#<chapter><title>test <ulink url='http://example.com'>http://example.com</ulink> test
</title></chapter>#)
}

1;
