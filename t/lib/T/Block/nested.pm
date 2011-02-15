#===============================================================================
#
#  DESCRIPTION:  test block =nested
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$

package T::Block::nested;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use Perl6::Pod::To::XHTML;
use XML::ExtOn('create_pipe');
use base 'TBase';

sub c01_nested_nested : Test {
    my $t = shift;
    my $x = $t->parse_to_xml(<<T);
=begin pod
=begin nested
=begin nested
Test B<er>
=end nested
=end nested
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><nested pod:type='block'><nested pod:type='block'>Test <B pod:type='code'>er</B>
</nested></nested></pod>#
    );
}

sub c02_as_docbook : Test {
    my $t = shift;
    my $x = $t->parse_to_docbook(<<T);
=begin pod
=begin nested
=begin nested
Test B<er>
=end nested
=end nested
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<chapter><blockquote><blockquote>Test <emphasis role='bold'>er</emphasis>
</blockquote></blockquote></chapter>#
    );
}

sub c02_as_xhml : Test {
    my $t = shift;
    my $x = $t->parse_to_xhtml(<<T);
=begin pod
=begin nested
=begin nested
Test B<er>
=end nested
=end nested
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<xhtml xmlns='http://www.w3.org/1999/xhtml'><blockquote><blockquote>Test <strong>er</strong></blockquote></blockquote></xhtml>#
    );
}



1;
