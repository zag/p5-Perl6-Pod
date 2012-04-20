#===============================================================================
#
#  DESCRIPTION:  Base block
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Perl6::Pod::Lex::FormattingCode;
use strict;
use warnings;
use Perl6::Pod::Lex::Block;
use base 'Perl6::Pod::Lex::Block';

sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    $self;
}

1;


