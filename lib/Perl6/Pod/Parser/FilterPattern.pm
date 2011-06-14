#===============================================================================
#
#  DESCRIPTION:  Filter input events via pattern
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
package Perl6::Pod::Parser::FilterPattern;

=pod

=head1 NAME

Perl6::Pod::FormattingCode::P::FilterPattern - Filter input events via pattern

=head1 SYNOPSIS
    my $p1 = $dummy->mk_block( 'para', ':!public' );
    my $filter =
      new Perl6::Pod::Parser::FilterPattern:: patterns => [$p1];


=head1 DESCRIPTION

Filter elements via patterns. Use OR operand for patterns.

=cut

use strict;
use warnings;
use Data::Dumper;
use Perl6::Pod::Parser;
use base 'Perl6::Pod::Parser';

sub on_start_element {
    my $self     = shift;
    my $el       = shift;
    my $patterns = $self->{patterns} || return $el;

    #skip empty list
    return $el unless @{$patterns};
    my $lname = $el->local_name;
    my $lattr = $el->get_attr;
    my $is_eq = 0;
    foreach my $pelem ( @{$patterns} ) {

        my $pname = $pelem->local_name;
        unless ( $pelem->attrs_by_name->{no_name} ) {
                next unless $lname eq $pname;
        }

        #skip if empty attributes in pattern
        my $pattr = $pelem->get_attr;
        unless ( keys %$pattr ) {
            $is_eq = 1;
            last;
        }

        #check by attribs
        while ( my ( $key, $val ) = each %$pattr ) {
            next unless ( exists $lattr->{$key} );

            #check only scalar values !!!
            if ( ref($val) ) {
                warn "filter: $pname :$key  Check only scalars!";
                next;    #attribute
            }

            #check values
            my $lval = $lattr->{$key};
            if ( $val eq $lval ) {
                $is_eq = 1;
                last;
            }
        }
        if ($is_eq) { last; }
    }
    unless ($is_eq) {

        #skip element
        $el->delete_element;

        #don't delete content if pod block
        $el->skip_content unless ( $lname eq 'pod' );
    }

    return $el;
}
1;

