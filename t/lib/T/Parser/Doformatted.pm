#===============================================================================
#
#  DESCRIPTION:  test for :formatted filter
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package WarnBlocks;
use strict;
use warnings;
use base 'Perl6::Pod::Parser';
use Test::More;
use Data::Dumper;

sub on_start_element {
    my $self = shift;
    my $el = shift;
#    warn "start".$el->local_name;
    return $el
}
sub on_end_element {
    my $self = shift;
    my $el = shift;
#    warn "end".$el->local_name;
    return $el
}

1;
package T::Parser::Doformatted;
use strict;
use warnings;
use base "TBase";
use Test::More;
use Data::Dumper;
use XML::ExtOn qw(create_pipe);

sub f01_formatted : Test {
    my $t= shift;
    my $x = $t->parse_to_xml(<<T, 'Perl6::Pod::Parser::Doformatted');
=begin pod
=for para :formatted<I B>
B<Test more text> test
=end pod
T

 $t->is_deeply_xml ( $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block' formatted='I,B'><I pod:type='code'><B pod:type='code'><B pod:type='code'>Test more text</B> test
 </B></I></para></pod>#)

}
1;


