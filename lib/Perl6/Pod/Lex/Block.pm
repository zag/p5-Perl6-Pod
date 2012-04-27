#===============================================================================
#
#  DESCRIPTION:  Base block
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Perl6::Pod::Lex::Block;
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    $self;
}

sub content {
    my $self = shift;
    $self->{''};
}

sub childs {
    my $self = shift;
    if (scalar @_) {
        $self->{content} = shift;
    }
    $self->{content};
}

sub name {
    my $self = shift;
    return $self->{name}
}

1;


