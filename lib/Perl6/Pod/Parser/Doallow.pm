#===============================================================================
#
#  DESCRIPTION:
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Perl6::Pod::Parser::Doallow;

=pod

=head1 NAME

Perl6::Pod::Parser::Doallow - handle :allow configuration option

=head1 SYNOPSIS

    =begin para  :allow< B >
    B<say> Hello R<name>;
    =end code

identicaly to ( R<> is cleaned from output): 

    =begin para  :allow< B >
    B<say> Hello name;
    =end code

=head1 DESCRIPTION

This option expects a list of formatting codes that are to be recognized within any codes that appear in (or are implicitly applied to) the current block.

    =begin pod
    =for para :allow<I>
    B<Test more text> I<test>
    =end pod

(skip B<> formatting code)

=cut

use strict;
use warnings;
use Data::Dumper;
use Test::More;
use base 'Perl6::Pod::Parser';

sub on_start_element {
    my $self          = shift;
    my $el            = shift;
    my $allow_context = $el->context->custom;
    my $attr          = $el->get_attr;
    if ( my $allow = $attr->{allow} ) {

        #make array and use it for set key
        my @set_allow = ref($allow) ? @$allow : ($allow);
        @$allow_context{ 'NEED_ALLOW', @set_allow, ( keys %$allow_context ) } =
          ();
    }
    return $el          unless exists $allow_context->{NEED_ALLOW};
    #skip blocks
    return $el          unless $el->isa('Perl6::Pod::FormattingCode');
    $el->delete_element unless exists $allow_context->{ $el->local_name };
    return $el;
}
1;

