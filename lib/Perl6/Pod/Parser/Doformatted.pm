#===============================================================================
#
#  DESCRIPTION:  
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Perl6::Pod::Parser::Doformatted;

=pod

=head1 NAME

Perl6::Pod::Parser::Doformatted - handle :formatted configuration option

=head1 SYNOPSIS

        =config head2  :like<head1> :formatted<I>
        =config head1  :formatted<B U>  :numbered


=head1 DESCRIPTION

This option specifies that the contents of the block should be treated as if they had one or more formatting codes placed around them.

For example, instead of:

        =for comment
            The next para is both important and fundamental,
            so doubly emphasize it...

        =begin para
        B<I<
        Warning: Do not immerse in water. Do not expose to bright light.
        Do not feed after midnight.
        >>
        =end para

you can just write:

        =begin para :formatted<B I>
        Warning: Do not immerse in water. Do not expose to bright light.
        Do not feed after midnight.
        =end para

The internal representations of these two versions are exactly the same, except that the second one retains the :formatted option information as part of the resulting block object.

Like all formatting codes, codes applied via a :formatted are inherently cumulative. For example, if the block itself is already inside a formatting code, that formatting code will still apply, in addition to the extra "basis" and "important" formatting specified by :formatted<B I>.

=cut

use strict;
use warnings;
use Data::Dumper;
use Test::More;
use base 'Perl6::Pod::Parser';
sub on_start_element {
    my $self = shift;
    my $el = shift;
    my $attr =  $el->get_attr;
    if ( my $formatted = $attr->{formatted}) {
        #make array
        $formatted = ref($formatted) ? $formatted : [ $formatted ] ;
        #wrap contents to format codes
        $el->wrap_around( map {$el->mk_fcode($_)} @$formatted );
    }
    return $el;
}
1;


