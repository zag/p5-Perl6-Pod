#===============================================================================
#
#  DESCRIPTION:  
#
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================
package main;
use strict;
use warnings;
use Test::More(tests=>21);
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

is_deeply $c1->_opt2hash(':w["223","123123"]'),
  {
    'w' => {
        'src'   => '["223","123123"]',
        'value' => [ '223', '123123' ],
        'type'  => 'List'
    }
  },
  'parse opt: list';

is_deeply $c1->_opt2hash(':we("12 3 asdas a")'),
  {
    'we' => {
        'src'   => '("12 3 asdas a")',
        'value' => '12 3 asdas a',
        'type'  => 'String'
    }
  },
  'parse opt: string';

is_deeply $c1->_opt2hash(':w2{12=>1}'),
  {
    'w2' => {
        'src'   => '{12=>1}',
        'value' => { '12' => 1 },
        'type'  => 'Hash'
    }
  },
  'parse opt: hash';

is_deeply $c1->_opt2hash(':!r'),
  {
    'r' => {
        'src'   => '',
        'value' => 0,
        'type'  => 'Boolean'
    }
  },
  'parse opt: boolean false';

is_deeply $c1->_opt2hash(':r'),
  {
    'r' => {
        'src'   => '',
        'value' => 1,
        'type'  => 'Boolean'
    }
  },
  'parse opt: boolean true';

is_deeply $c1->_opt2hash(
    ':w["223","123123"] :!r :we("12 3 asdas a") :r2 :w2{12=>1, 123=>56}'),
  {
    'w' => {
        'src'   => '["223","123123"]',
        'value' => [ '223', '123123' ],
        'type'  => 'List'
    },
    'r' => {
        'src'   => '',
        'value' => 0,
        'type'  => 'Boolean'
    },
    'r2' => {
        'src'   => '',
        'value' => 1,
        'type'  => 'Boolean'
    },
    'w2' => {
        'src'   => '{12=>1, 123=>56}',
        'value' => {
            '123' => 56,
            '12'  => 1
        },
        'type' => 'Hash'
    },
    'we' => {
        'src'   => '("12 3 asdas a")',
        'value' => '12 3 asdas a',
        'type'  => 'String'
    }
  },
  'check attrs string';

my $str1 = $c1->_hash2opt( w => { value => [ 1, 2 ] } );
is_deeply $c1->_opt2hash($str1)->{w}->{value}, [ 1, 2 ],
  'check trans ARRAY> ' . $str1;

my $str2 = $c1->_hash2opt( w => { value => { 1 => 2, 3 => 4 } } );
is_deeply $c1->_opt2hash($str2)->{w}->{value}, { 1 => 2, 3 => 4 },
  'check trans HASH> ' . $str2;

my $str3 = $c1->_hash2opt( w => { value => "txt" } );
is_deeply $c1->_opt2hash($str3)->{w}->{value}, "txt",
  'check trans STRING>' . $str3;

my $str4 = $c1->_hash2opt( w => { value => 0 } );
is_deeply $c1->_opt2hash($str4)->{w}->{value}, 0,
  'check trans BOOLEAN val>' . $str4;
is_deeply $c1->_opt2hash($str4)->{w}->{type}, 'Boolean',
  'check trans BOOLEAN type>' . $str4;

my $str5 = $c1->_hash2opt( w => { value => 1 } );
is_deeply $c1->_opt2hash($str5)->{w}->{value}, 1,
  'check trans BOOLEAN val>' . $str5;
is_deeply $c1->_opt2hash($str5)->{w}->{type}, 'Boolean',
  'check trans BOOLEAN type>' . $str5;

my $str6 = $c1->_hash2opt(
    w  => { value => 1, type => 'List' },
    w2 => { value => 1, type => 'List' }
);

my $res = $c1->_opt2hash($str6);
delete $_->{src} for values(%$res);
is_deeply $res,
  {
    'w' => {
        'value' => [ '1' ],
        'type'  => 'List'
    },
    'w2' => {
        'value' => [ '1' ],
        'type'  => 'List'
    }
  },
  "check trans 2 arrays $str6 ";





