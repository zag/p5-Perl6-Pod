#===============================================================================
#
#  DESCRIPTION:  Test para blocks
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================

use strict;
use warnings;

#use Test::More tests => 1;                      # last test to print
use Test::More 'no_plan';                      # last test to print
use Perl6::Pod::Utl;
use Data::Dumper;
use Perl6::Pod::Test;

my $t1 = Perl6::Pod::Utl::parse_pod(<<TXT, default_pod=>1);
=begin para
  B<test> text C<verb>

=SYNS
  esdsdsd

=end para

TXT
my $test = Perl6::Pod::Test::parse_to_docbook(<<TXT);
=NAME Test
=begin para
 B<I<test>> text C<I<verb>>
=for code
    ode
=SYN
tesxt
=end para
TXT

diag $test;


