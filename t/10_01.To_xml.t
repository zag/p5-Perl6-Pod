#===============================================================================
#
#  DESCRIPTION:  test XML out put
#
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================

package Test::Tag;
use strict;
use warnings;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';
use XML::Flow;

sub to_xml {
    my ( $self, $parser, @in ) = @_;
    return "<p>@in</p>";
}

package main;
use strict;
use warnings;
use Test::More qw/no_plan/;    # last test to print
use XML::SAX::Writer;
use Data::Dumper;
use_ok('Perl6::Pod::To');
use_ok('Perl6::Pod::To::XML');

#tests for create
my $buf0;
my $o0 = new XML::SAX::Writer:: Output => \$buf0;
ok UNIVERSAL::isa( $o0, 'XML::Filter::BufferText' ),
  'class of instance of XML::SAX::Writer';
my ( $p0, $f0 ) = Perl6::Pod::To::to_abstract( 'Perl6::Pod::To::XML', $o0 );
isa_ok( $f0->{out_put}, 'XML::ExtOn', 'if output is writer' );
my $o1 = new XML::ExtOn::;
my ( $p1, $f1 ) = Perl6::Pod::To::to_abstract( 'Perl6::Pod::To::XML', $o1 );
isa_ok( $f1->{out_put}, 'XML::ExtOn', 'if output is ExtOn' );
my $buf;
my ( $p, $f ) = Perl6::Pod::To::to_abstract( 'Perl6::Pod::To::XML', \$buf );
isa_ok( $f->{out_put}, 'XML::ExtOn', 'if output is string buffer' );

$p->parse( \<<TXT);
=begin pod
=use Test::Tag test2
=config test1 :we1
=begin para
N<erC<ds>>this is a para

this is a para
=end para
=for test1 :w1
test
=for test2 
Heelo
=end pod
TXT

sub gen_h {
    my $attr_name = shift;
    return sub {
        my $attr = shift;
        return { $attr_name => { attr => $attr, content => \@_ } };
      }
}
my $fr    = new XML::Flow \$buf;
my $tree1 = {};
$fr->read(
    {
        pod => sub { $tree1 = \@_ },
        C   => gen_h('C'),
        N   => gen_h('N'),
        para => gen_h('para'),

    }
);

is_deeply $tree1, [
    {
        'pod:type'  => 'block',
        'xmlns:pod' => 'http://perlcabal.org/syn/S26.html'
    },
    {
        'para' => {
            'content' => [
                {
                    'N' => {
                        'content' => [
                            'er',
                            {
                                'C' => {
                                    'content' => ['ds'],
                                    'attr'    => { 'pod:type' => 'code' }
                                }
                            }
                        ],
                        'attr' => { 'pod:type' => 'code' }
                    }
                },
                'this is a para
this is a para
'
            ],
            'attr' => { 'pod:type' => 'block' }
        }
    }
  ],
  'check xml for code';

my $buf2;
my ( $p2, $f2 ) = Perl6::Pod::To::to_abstract( 'Perl6::Pod::To::XML', \$buf2 );
isa_ok( $f2->{out_put}, 'XML::ExtOn', 'if output is string buffer' );

$p2->parse( \<<TXT1);
=begin pod
=config head1 :w1
=config TT<> :like<head1>
=head1 This is a head1

format code M<TT: test mssage>
=end pod
TXT1

my $fr2    = new XML::Flow \$buf2;
my $tree2 = {};

$fr2->read(
    {
        pod => sub { $tree2 = \@_ },
        M   => gen_h('M'),
        para => gen_h('para'),

    }
);

#diag $buf2;
diag Dumper $tree2;

#diag UNIVERSAL::isa('XML::Flow','XML::Flow');

