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
use lib 't/lib';
use T::To::XML;
Test::Class->runtests;


