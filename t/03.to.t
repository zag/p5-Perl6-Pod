#===============================================================================
#
#  DESCRIPTION:  Test Perl6::To* API
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
package Perl6::Pod::Writer::DocBook;
use strict;
use warnings;
use Perl6::Pod::Writer;
use base 'Perl6::Pod::Writer';
1;

1;

package main;
use strict;
use warnings;
use Test::More 'no_plan'; #tests => 1;                      # last test to print

my $text = '=begin pod

=head1 test
Para
=begin para


 dr

=end para
 sd
=end pod
';
use Perl6::Pod::Utl;
my $tree = Perl6::Pod::Utl::parse_pod($text);
use Data::Dumper;

my $str = '';
open( my $fd, ">", \$str );
my $docbook = new Perl6::Pod::To::DocBook::
  writer  => new Perl6::Pod::Writer::DocBook( out => $fd ),
  header  => 1,
  doctype => 'chapter';

#diag Dumper($tree);
diag $str;
ok "1";

