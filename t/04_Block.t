#
#===============================================================================
#
#         FILE:  04_Block.t
#
#  DESCRIPTION:  Test Block.pm
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#      COMPANY:  artpragmatica.ru
#      VERSION:  1.0
#      CREATED:  15.05.2009 08:55:35 MSD
#     REVISION:  ---
#===============================================================================
package Block::DUMMY;
use strict;
use warnings;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';
sub to_text {
    my ($self, $attr, $para) = @_;
    return $para
}
1;
package main;
use strict;
use warnings;

#use Test::More tests => 1;                      # last test to print
use Test::More 'no_plan';    # last test to print
use Data::Dumper;
use_ok 'Perl6::Pod::Block';
use_ok 'Perl6::Pod::Parser::Context';
#use Block::DUMMY;
my $c = new Perl6::Pod::Parser::Context;
$c->config->{'test'} = ":w";
my $b = new Perl6::Pod::Block::
  name    => 'test',
  context => $c,
  options => ':w2';
isa_ok $b->context, 'Perl6::Pod::Parser::Context', '$block->context';
is_deeply my $attr = $b->get_attr, {
           'w' => 1,
           'w2' =>1
         } , 'config opt and init pod';
ok  $b->context->set_use('Block::DUMMY',':Mytestblock' ), 'set use';
is $b->context->use->{Mytestblock} , 'Block::DUMMY',
         , 'test set_use';

isa_ok my $b2 = $b->mk_block('Mytestblock', ':w3(33)'), 'Block::DUMMY';
ok $b2->get_attr->{w3} , 'check opt';

ok $b2->start($b2->get_attr, 'xml'), '$b2->start';
ok $b2->to_text($b2->get_attr, 'some text'),'$b2->to_text';
ok $b2->end($b2->get_attr, 'xml'),'$b2->stop';

