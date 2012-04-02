#########################
# Test pod blocks
#
package Perl6::Pod::Grammars1;
use strict;
use warnings;
1;

package Perl6::Pod6::Block;
use strict;
use warnings;
1;
package Perl6::Pod6::Autoactions;
use strict;
use warnings;
use Data::Dumper;
use vars qw($AUTOLOAD);

sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    $self;
}
sub delimblock {
    my $self =shift;
    my $ref = shift;
    warn Dumper {"delimblock"=>$ref};
    return {'block_content'=>1}
}

1;
package main;
use strict;
use warnings;

use Test::More tests => 1;                      # last test to print
use Regexp::Grammars;
use Perl6::Pod::Grammars;
use v5.10;

use Data::Dumper;
#use_ok('Perl6::Pod::Grammars');

my $ref = <<TXT;
=begin pod

=begin para :23
=begin code
asd
=end code
=end para

=end pod
TXT
#    <rule: block_content> <block=text_content>
#    <rule: text_content> (?{ $MATCH{type} = "text"}) <[line=([^\n]+)]>+ %  <.newline>

    my $IN_POD = 0;
    my $r = qr{
       <extends: Perl6::Pod::Grammars::Blocks>
       <matchline>
#        <debug:step>

        \A <File> \Z
    <token: hs>[ \t]*
    <token: newline> <hs> \n
    <token: emptyline> <hs> \n

    <rule: File><block=delimblock>
    <rule: directives> begin | for | END | end | config
    <rule: block_content>  <MATCH=delimblock> | <MATCH=text_content> 
    <rule: text_content> <emptyline> | (?{ $MATCH{type} = "text"}) <line=([^\n]+)>  \n
    <rule: pair> \:<name=(\w+)>
    <rule: pod_block> =begin pod
                      =end pod
    <token: delimblock> <matchpos><matchline>
    ^ <spaces=hs>? =begin <.hs> (?! directives ) <.hs> <name=(\w+)>
                        ( ( <.newline> <.hs> = )? <.hs>  <[attr=pair]>+ % <.hs> )*
#                        (?{ ($MATCH{name} eq 'pod') 
#                            &&  ($IN_POD = 1)
#                            && (  say "pod On :VMARGIN ".length($MATCH{spaces} )) ; 1; 
#                        })

                        <[content=block_content]>+
                       
                       =end <.hs> <\name> <.hs> <.newline>
#                       (?{ ( $MATCH{name} eq 'pod' ) 
#                          &&  !($IN_POD = 0) 
#                          && ( say "pod off" ); 1;})

    }xms;
    if ( $ref =~ $r->with_actions(Perl6::Pod6::Autoactions->new) ) {
       say Dumper  {%/}->{File};
    }
    else  { }
exit;
