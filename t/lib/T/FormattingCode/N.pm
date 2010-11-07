#===============================================================================
#
#  DESCRIPTION:  Test N<>
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::FormattingCode::N;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use Perl6::Pod::To::XHTML;
use base 'TBase';

sub t01_as_xml : Test {
    my $t = shift;
    my $x = $t->pod6xml( <<T);
=para
Text  this N<Some note>.
T
    $t->is_deeply_xml( $x,
q#<pod6 xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'>Text  this <N pod:type='code' pod:n='1'>Some note</N>.</para><_NOTES_ pod:type='block'><_NOTE_ pod:note_id='1' pod:type='block'>Some note</_NOTE_></_NOTES_></pod6>#
    );
}

sub t01_as_xhtml : Test {
    my $t = shift;
    my $x = $t->parse_to_xhtml( <<T);
=begin pod
=para
Text  N<Same B<note>>.
=end pod
T

    #    diag $x;
    $t->is_deeply_xml( $x,
q|<xhtml xmlns='http://www.w3.org/1999/xhtml'><p>Text  <sup><a href='#ftn.nid1' name='nid1'>[1]</a></sup>.</p><div class='footnote'><p>NOTES</p><p><a href='#nid1' name='ftn.nid1'><sup>1.</sup></a>Same <strong>note</strong></p></div></xhtml>|
    );
}

1;

