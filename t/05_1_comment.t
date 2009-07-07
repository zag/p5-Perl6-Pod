#===============================================================================
#
#  DESCRIPTION:  
#
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================
=pod

test for =comment block

=cut


#$Id$

package Test::comment;
use Perl6::Pod::Parser;
use base 'Perl6::Pod::Parser';
use Test::More;
use Data::Dumper;
use strict;
use warnings;

sub on_start_block {
    my $self = shift;
    my $elem = shift;
    push @{$self->{NAMES}}, $elem->local_name;
    return $elem;
}

package main;
use warnings;
use strict;
use Test::More (tests=>2);
use Data::Dumper;
use XML::ExtOn('create_pipe');

use_ok('Perl6::Pod::Parser');


sub to_abstract {
    my $class = shift;
    my $out   = shift;
    my %arg   = ();
    $arg{out_put} = $out if defined($out);
    my $out_formatter = $class->new(%arg);
    my $p = create_pipe( 'Perl6::Pod::Parser', $out_formatter );
    return wantarray ? ( $p, $out_formatter ) : $p;
}

my ($p, $f) = to_abstract('Test::comment');

$p->parse(\<<TXT1);

=test1

=comment test message
test message

=test2
TXT1
is_deeply $f->{NAMES},[
           'test1',
           'test2'
         ], 'deleted';





