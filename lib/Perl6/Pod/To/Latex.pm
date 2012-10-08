#===============================================================================
#
#  DESCRIPTION:  
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Perl6::Pod::To::Latex;
use strict;
use warnings;
use strict;
use warnings;
use Perl6::Pod::To::DocBook;
use base 'Perl6::Pod::To::DocBook';
use Perl6::Pod::Utl;

sub new {
    my $class =  shift;
    my %args = @_;
    unless ( $args{writer} ) {
        use Perl6::Pod::Writer::Latex;
        $args{writer} = new Perl6::Pod::Writer::Latex(
            out => ( $args{out} || \*STDOUT ),
        );
    }
    my $self = $class->SUPER::new(%args);
    return $self;
}
1;


