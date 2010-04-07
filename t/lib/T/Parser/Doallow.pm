#===============================================================================
#
#  DESCRIPTION:  test :allow atribute
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::Parser::Doallow;
use strict;
use warnings;
use base "TBase";
use Test::More;
use Data::Dumper;
use XML::ExtOn qw(create_pipe);

sub f01_skip : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T, 'Perl6::Pod::Parser::Doallow' );
=begin pod
=for para :allow<I>
B<Test more text> I<test>
=end pod
T

    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block' allow='I'>Test more text <I pod:type='code'>test</I>
</para></pod>#
    );
}

sub f02_allow_in_config : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T, 'Perl6::Pod::Parser::Doallow' );
=begin pod
=config head1 :allow<B>
=for head1 
B<Test more text> I<test>
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><head1 pod:type='block' allow='B'><B pod:type='code'>Test more text</B> test
</head1></pod>#
    );
}

sub f03_allow_and_formatted : Test {

    my $t = shift;
    my $x = $t->parse_to_xml(
        <<T, 'Perl6::Pod::Parser::Doformatted', 'Perl6::Pod::Parser::Doallow' );
=begin pod :allow<B>
=config head1 
=for head1 :formatted<I>
B<Test more text> I<test>
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html' allow='B'><head1 pod:type='block' formatted='I'><B pod:type='code'>Test more text</B> test
</head1></pod>#
    );
}

1;

