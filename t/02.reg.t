#########################
# Test pod blocks
#
package Perl6::Pod::Grammars1;
use strict;
use warnings;
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
sd
saasd

    =end pod
TXT

    my $IN_POD = 0;
    my $r = qr{
       <extends: Perl6::Pod::Grammars::Blocks>
        <matchline>
#        <debug:step>

        \A <File> \Z
    <rule: Pod::File><block=delimblock>
    <rule: directives> begin | for | END | end | config
    <rule: pod_block> =begin pod
                      =end pod
    <token: delimblock> ^ <spaces=(\s*)>? =begin <.ws> (?! directives ) <.ws> <name=(\w+)> 
                        (?{ ($MATCH{name} eq 'pod') &&  ($IN_POD = 1) && (  say "pod On :VMARGIN".length($MATCH{spaces} )) })

                        <content=(.*?)>
                       
                       =end <.ws> <\name> (?{ ( $MATCH{name} eq 'pod' ) &&  !($IN_POD = 0) && ( say "pod off" )})
    <rule: newline>
            \s* \n

    }xms;
    if ( $ref =~ $r ) {
       say Dumper  {%/}->{File};
    }
    else  { }
exit;
