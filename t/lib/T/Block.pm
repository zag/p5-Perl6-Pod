#===============================================================================
#
#  DESCRIPTION:  Test Perl6::Pod::Block methods
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Block::DUMMY;
use strict;
use warnings;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';

sub to_text {
    my ( $self, $attr, $para ) = @_;
    return $para;
}
1;

package T::Block;
use strict;
use warnings;
use base "TBase";
use Test::More;
use Data::Dumper;

sub b01_use_Context : Test {
    use_ok 'Perl6::Pod::Parser::Context';
}

sub b02_base_types_of_attributes : Test(1) {
    my $c = new Perl6::Pod::Parser::Context;
    my $b = new Perl6::Pod::Block::
      name    => 'test',
      context => $c,
      options =>
":array['23' ,'test' , 22] :!false :true :string('test') :hash{1=>2} :number(2)";
    is_deeply $b->get_attr,
      {
        'array' => [ '23', 'test', 22 ],
        'hash'   => { '1' => 2 },
        'false'  => 0,
        'number' => 2,
        'true'   => 1,
        'string' => 'test'
      };

}

sub b02_config_attribute : Test(9) {
    my $c = new Perl6::Pod::Parser::Context;
    $c->config->{'test'} = ":w";
    my $b = new Perl6::Pod::Block::
      name    => 'test',
      context => $c,
      options => ':w2';
    isa_ok $b->context, 'Perl6::Pod::Parser::Context', '$block->context';
    is_deeply my $attr = $b->get_attr,
      {
        'w'  => 1,
        'w2' => 1
      },
      'config opt and init pod';
    ok $b->context->set_use( 'Block::DUMMY', ':Mytestblock' ), 'set use';
    is $b->context->use->{Mytestblock}, 'Block::DUMMY',, 'test set_use';

    isa_ok my $b2 = $b->mk_block( 'Mytestblock', ':w3(33)' ), 'Block::DUMMY';
    ok $b2->get_attr->{w3}, 'check opt';

    ok $b2->start( $b2->get_attr, 'xml' ), '$b2->start';
    ok $b2->to_text( $b2->get_attr, 'some text' ), '$b2->to_text';
    ok $b2->end( $b2->get_attr, 'xml' ), '$b2->stop';
}

sub b03_like_attribute_in_config : Test {
    my $c = new Perl6::Pod::Parser::Context;
    $c->config->{'test1'} = ":w1 :like<test2>";
    $c->config->{'test2'} = ":w2('2')";
    my $b = new Perl6::Pod::Block::
      name    => 'test1',
      context => $c,
      options => ":o1('3')";
    my $tattr = $b->get_attr;
    is_deeply [ @{$tattr}{qw/w1 w2 o1/} ], [ 1, 2, 3 ];
}

sub b04_like_attribute_in_opt : Test {
    my $c = new Perl6::Pod::Parser::Context;
    $c->config->{'test1'} = ":w1";
    $c->config->{'test2'} = ":w2('2')";
    my $b = new Perl6::Pod::Block::
      name    => 'test1',
      context => $c,
      options => ":o1('3') :like<test2>";
    my $tattr = $b->get_attr;
    is_deeply [ @{$tattr}{qw/w1 w2 o1/} ], [ 1, 2, 3 ];
}

sub b05_like_attribute_deep_recurse : Test {
    my $c = new Perl6::Pod::Parser::Context;
    $c->config->{'test1'} = ":w1 :like<test4>";
    $c->config->{'test2'} = ":w2(2) :w3(4) :like<test3>";
    $c->config->{'test3'} = ":w3(3) :o1(4) :like<test2>";
    $c->config->{'test4'} = ":w4";
    my $b = new Perl6::Pod::Block::
      name    => 'test1',
      context => $c,
      options => ":o1('3') :like<test2>";
    my $tattr = $b->get_attr;
    delete $tattr->{like};
    is_deeply $tattr,
      {
        'o1' => '3',
        'w3' => 4,
        'w1' => 1,
        'w2' => 2
      };
}

sub b06_like_attribute_array : Test {
    my $c = new Perl6::Pod::Parser::Context;
    $c->config->{'test1'} = ":w1 :like<test4>";
    $c->config->{'test2'} = ":w2(2) :w3(4) :like<test3>";
    $c->config->{'test3'} = ":w3(3) :o1(4) :w4(2)";
    $c->config->{'test4'} = ":w4";
    my $b = new Perl6::Pod::Block::
      name    => 'test1',
      context => $c,
      options => ":o1('3') :like['test3','test4']>";
    my $tattr = $b->get_attr;
    delete $tattr->{like};
    is_deeply $tattr,
      {
        'w4' => 2,
        'o1' => '3',
        'w3' => 3,
        'w1' => 1
      }, ":like['test3','test4']>";
}

sub b07_allow_attribute: Test  {
    return "skip";
    my $t = shift;
    my $x = $t->parse_to_xml(<<T,);
=begin pod
=for para :allow<B>
B<Test more text>I<test>
=end pod
T
    diag $x;exit;
    my $c = new Perl6::Pod::Parser::Context;
    $c->config->{'test1'} = ":w1 :like<test4>";
    $c->config->{'test2'} = ":w2(2) :w3(4) :like<test3>";
    $c->config->{'test3'} = ":w3(3) :o1(4) :w4(2)";
    $c->config->{'test4'} = ":w4";
    my $b = new Perl6::Pod::Block::
      name    => 'test1',
      context => $c,
      options => ":o1('3') :like['test3','test4']>";
    my $tattr = $b->get_attr;
    delete $tattr->{like};
    is_deeply $tattr,
      {
        'w4' => 2,
        'o1' => '3',
        'w3' => 3,
        'w1' => 1
      }, ":like['test3','test4']>";
}





1;

