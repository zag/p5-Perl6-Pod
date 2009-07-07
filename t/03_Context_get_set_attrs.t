#===============================================================================
#
#  DESCRIPTION:  
#
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================
use strict;
use warnings;
use Test::More(tests=>16);
use Data::Dumper;
use_ok 'Perl6::Pod::Parser';
use_ok 'Perl6::Pod::Parser::Context';
use_ok 'Perl6::Pod::Block';
use_ok 'XML::ExtOn', 'create_pipe';
use_ok 'XML::SAX::Writer';
use_ok 'Perl6::Pod::Parser::Pod2Events';
use_ok 'Perl6::Pod::Parser::Context';
####################test context ##########

my $c1 = new Perl6::Pod::Parser::Context::;


###############test set and get attr for BLOCK type ############

is_deeply $c1->get_attr('item1'), {}, 'check get empty opt : item1';
ok  $c1->set_attr( 'item1', { w => [12] } ), 'set_attr for item1';
is_deeply $c1->get_attr('item1'), { w => [12] }, 'check get opt item1 after save';

ok  $c1->set_attr( 'item3', { w => {1=>2}, w2=>[1..3] } ), 'set_attr for item3';
is_deeply $c1->get_attr('item3'), {
          'w' => {
                    '1' => '2'
                  },
           'w2' => [
                     '1',
                     '2',
                     '3'
                   ]
         }, 'set_attr: hash and array';

############### chech sub context

isa_ok my $c2 = $c1->sub_context(),'Perl6::Pod::Parser::Context', 'create sub context';
is_deeply  $c2->get_attr('item1'), {
           'w' => [
                    '12'
                  ]
         }, 'itmem1 in sub context';

ok $c2->set_attr('item1', { w=>[13], w2=>1 } ), "change item1";
is_deeply  [ $c2->get_attr('item1'),$c1->get_attr('item1') ], [
           {
             'w' => [
                      '13'
                    ],
             'w2' => 1
           },
           {
             'w' => [
                      '12'
                    ]
          }
         ],'check sub context';


