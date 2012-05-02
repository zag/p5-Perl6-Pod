#===============================================================================
#
#  DESCRIPTION:  Base block
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
package Perl6::Pod::Lex::Block;
use strict;
use warnings;

sub get_attr {
    my $self = shift;
    my $attr = $self->{attr} || return {};
    my %res;
    foreach my $a (@{ $attr }) {
        my $name = $a->{name};
        my $value = $a->{items};
        my $type = $a->{type};
        if ($type eq 'hash') {
          my %hash = ();
          for ( @{ $value }) {
            $hash{$_->{key}} = $_->{value}
          }
          $value = \%hash;
        }
        $res{$name} = $value
    }
    return \%res;
}

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


