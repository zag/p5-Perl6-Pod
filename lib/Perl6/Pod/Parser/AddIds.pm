package Perl6::Pod::Parser::AddIds;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Parser::AddIds - generate attribute id for elements

=head1 SYNOPSIS


=head1 DESCRIPTION


DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !

=cut

use strict;
use warnings;
use base 'Perl6::Pod::Parser';
use Test::More;
use Data::Dumper;

sub on_para {
    my ( $self, $el, $txt ) = @_;
    unless ( exists $el->attrs_by_name->{id}) {
        $el->attrs_by_name->{id} =  $self->_make_uniq_id($txt)
    }
    return $txt;
}

=head2 _make_id($text[, $base_id])

Function will construct an element id string. Id string is composed of
C<< join (':', $base_id || $parser->{base_id} , $text) >>, where C<$text> in most cases
is the pod heading text.

The xml id string has strict format. Checkout L</"cleanup_id"> function for
specification.

=cut

sub _make_id {
    my $parser  = shift;
    my $text    = shift || '';
    my $base_id = shift || $parser->{base_id} || '';

    # trim text spaces
    $text =~ s/^\s*//xms;
    $text =~ s/\s*$//xms;

    #replace \n\r to spaces
    $text =~ s/[\r\n]+/ /gxms;

    $base_id =~ s/^\s*//xms;
    $base_id =~ s/\s*$//xms;

    return _cleanup_id( join( ':', $base_id, $text ) );
}

=head2 _make_uniq_id($text)

Calls C<< $parser->make_id($text) >> and checks if such id was already
generated. If so, generates new one by adding _i1 (or _i2, i3, ...) to the id
string. Return value is new uniq id string.

=cut

sub _make_uniq_id {
    my $parser = shift;
    my $text   = shift;

    my $id_string = $parser->_make_id($text);

    # prevent duplicate ids
    my $ids_used = $parser->{'ids_used'} || {};
    while ( exists $ids_used->{$id_string} ) {
        if ( $id_string =~ m/_i(\d+)$/xms ) {
            my $last_used_id_index = $1;
            substr(
                $id_string,         0 - length($last_used_id_index),
                length($id_string), $last_used_id_index + 1
            );
        }
        else {
            $id_string .= '_i1';
        }
    }
    $ids_used->{$id_string} = 1;
    $parser->{'ids_used'} = $ids_used;

    return $id_string;
}

=head2 _cleanup_id($id_string)

This function is used internally to remove/change any illegal characters
from the elements id string. (see http://www.w3.org/TR/2000/REC-xml-20001006#NT-Name
for the id string specification)

    $id_string =~ s/<!\[CDATA\[(.+?)\]\]>/$1/g;   # keep just inside of CDATA
    $id_string =~ s/<.+?>//g;                     # remove tags
    $id_string =~ s/^\s*//;                       # ltrim spaces
    $id_string =~ s/\s*$//;                       # rtrim spaces
    $id_string =~ tr{/ }{._};                     # replace / with . and spaces with _
    $id_string =~ s/[^\-_a-zA-Z0-9\.: ]//g;       # closed set of characters allowed in id string

In the worst case when the C<$id_string> after clean up will not conform with
the specification, warning will be printed out and random number with leading colon
will be used.

=cut

sub _cleanup_id {
    my $id_string = shift;

    $id_string =~ s/<!\[CDATA\[(.+?)\]\]>/$1/gxms;   # keep just inside of CDATA
    $id_string =~ s/<.+?>//gxms;                     # remove tags
    $id_string =~ s/^\s*//xms;                       # ltrim spaces
    $id_string =~ s/\s*$//xms;                       # rtrim spaces
    $id_string =~ tr{/ }{._};    # replace / with . and spaces with _
    $id_string =~ s/[^\-_a-zA-Z0-9\.:\s]//gxms
      ;                          # closed set of characters allowed in id string

# check if the id string is valid (SEE http://www.w3.org/TR/2000/REC-xml-20001006#NT-Name)
# TODO refactor to the function, we will need if also later and some tests will be handfull
#      we should also "die" if the base_id is set through the command line parameter
    if ( $id_string !~ m/^[A-Za-z_:] [-A-Za-z0-9_.:]*/xms ) {
        $id_string = q{:} . _big_random_number();
        warn 'wrong xml id string "', $id_string, '", throwing away and using ',
          $id_string, ' instead!', "\n";
    }

    return $id_string;
}

sub _big_random_number {
    ## no critic ValuesAndExpressions::ProhibitMagicNumbers
    return int( rand(9e10) + 10e10 );
    ## use critic
}

1;

