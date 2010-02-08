#===============================================================================
#
#  DESCRIPTION:  
#
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================
package Perl6::Pod::Parser::DUMMY;
use warnings;
use strict;
use Perl6::Pod::Parser;
use Test::More;
use Data::Dumper;
use base qw/Perl6::Pod::Parser/;

sub start_block {
    my $self = shift;
    my ( $name, $opt ) = @_;
    push @{ $self->{BLOCKS} },
      { event => '_begin', name => $name, opt => $opt };
}

sub para {
    my $self = shift;
    my $txt  = shift;
    push @{ $self->{BLOCKS} }, { event => '_para', name => 'para'};
}

sub end_block {
    my $self = shift;
    my ( $name, $opt ) = @_;
    push @{ $self->{BLOCKS} }, { event => '_end', name => $name, opt => $opt };
}
1;

package main;
use strict;
use warnings;
use Test::More('no_plan');
use Data::Dumper;
use_ok 'Perl6::Pod::Parser';
use_ok 'Perl6::Pod::Parser::Context';
use_ok 'Perl6::Pod::Block';
use_ok 'XML::ExtOn', 'create_pipe';
use_ok 'XML::SAX::Writer';
use_ok 'Perl6::Pod::Parser::Pod2Events';

sub parse_pod {
    my $t1    = shift;
    my $class = shift || 'Perl6::Pod::Parser::DUMMY';
    my $ev    = ${class}->new;
    my $buf;
    open( my $f1, "<", \$t1 );
    $ev->parse($f1);
    close $f1;
    return $ev;
}

my $p1 = new Perl6::Pod::Parser::;
eval { $p1->parse( {} ) };
ok $@, 'prase: bad args';

eval { $p1->parse() };
ok $@, 'prase: empty args';

my $r1 = parse_pod(<<TXT01);
=begin pod
= :we

str1
str3

=end pod
TXT01
is_deeply $r1->{BLOCKS},
  [
    {
        'name'  => 'pod',
        'opt'   => ':we',
        'event' => '_begin'
    },
    {
        'name'  => 'para',
        'event' => '_para'
    },
    {
        'name'  => 'pod',
        'opt'   => ':we',
        'event' => '_end'
    }
  ],
  'check delimited: =begin and =end';

my $r2 = parse_pod(<<TXT01);
=for pod
= :we
str1
str3

TXT01

is_deeply $r2->{BLOCKS},
  [
    {
        'name'  => 'pod',
        'opt'   => ':we',
        'event' => '_begin'
    },
    {
        'name'  => 'para',
        'event' => '_para'
    },
    {
        'name'  => 'pod',
        'opt'   => ':we',
        'event' => '_end'
    }
  ],
  'check paragraph: =for';

my $r3 = parse_pod(<<TXT03);
=pod
str1
str3

TXT03
is_deeply $r3->{BLOCKS},
  [
    {
        'name'  => 'pod',
        'opt'   => '',
        'event' => '_begin'
    },
    {
        'name'  => 'para',
        'event' => '_para'
    },
    {
        'name'  => 'pod',
        'opt'   => '',
        'event' => '_end'
    }
  ],
  'abbreviated blocks';

my $r04 = parse_pod(<<TXT04);
=pod
str1
str3

unknown

TXT04

is_deeply $r04->{BLOCKS},
  [
    {
        'name'  => 'pod',
        'opt'   => '',
        'event' => '_begin'
    },
    {
        'name'  => 'para',
        'event' => '_para'
    },
    {
        'name'  => 'pod',
        'opt'   => '',
        'event' => '_end'
    }
  ],
  'ambient text';

my $r5 = parse_pod(<<TXT05);
=begin test
=for item1 
sdsdds
=for item2
=end test
TXT05

is_deeply $r5->{BLOCKS},
  [
    {
        'name'  => 'test',
        'opt'   => '',
        'event' => '_begin'
    },
    {
        'name'  => 'item1',
        'opt'   => '',
        'event' => '_begin'
    },
    {
        'name'  => 'para',
        'event' => '_para'
    },
    {
        'name'  => 'item1',
        'opt'   => '',
        'event' => '_end'
    },
    {
        'name'  => 'item2',
        'opt'   => '',
        'event' => '_begin'
    },
    {
        'name'  => 'item2',
        'opt'   => '',
        'event' => '_end'
    },
    {
        'name'  => 'test',
        'opt'   => '',
        'event' => '_end'
    }
  ],
  'nested =for';

my $r06 = parse_pod(<<TXT06);
=begin pod
=config head1 :w1<1> :w2<2>
=for we :capt
para para para

para para

=end pod
TXT06
is_deeply $r06->{BLOCKS},
  [
    {
        'name'  => 'pod',
        'opt'   => '',
        'event' => '_begin'
    },
    {
        'name'  => 'config',
        'opt'   => 'head1 :w1<1> :w2<2>',
        'event' => '_begin'
    },
    {
        'name'  => 'config',
        'opt'   => 'head1 :w1<1> :w2<2>',
        'event' => '_end'
    },
    {
        'name'  => 'we',
        'opt'   => ':capt',
        'event' => '_begin'
    },
    {
        'name'  => 'para',
        'event' => '_para'
    },
    {
        'name'  => 'we',
        'opt'   => ':capt',
        'event' => '_end'
    },
    {
        'name'  => 'para',
        'event' => '_para'
    },
    {
        'name'  => 'pod',
        'opt'   => '',
        'event' => '_end'
    }
  ],
  'nested config';


my $r07 = parse_pod(<<TXT07);
=for we :w1<1>
= :w2<2>
test para test
para test para

TXT07
is_deeply $r07->{BLOCKS}, [
          {
            'name' => 'we',
            'opt' => ':w1<1> :w2<2>',
            'event' => '_begin'
          },
          {
            'name' => 'para',
            'event' => '_para'
          },
          {
            'name' => 'we',
            'opt' => ':w1<1> :w2<2>',
            'event' => '_end'
          }
        ], 'extra opt in =for';


my $r08 = parse_pod(<<TXT08);
=begin para
= :w2<2>

test para test
para test para

test para test
para test para

=end para

TXT08
is_deeply $r08->{BLOCKS}, [
          {
            'name' => 'para',
            'opt' => ':w2<2>',
            'event' => '_begin'
          },
          {
            'name' => 'para',
            'event' => '_para'
          },
          {
            'name' => 'para',
            'opt' => ':w2<2>',
            'event' => '_end'
          }
        ], 'nested para';

