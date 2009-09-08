#===============================================================================
#
#  DESCRIPTION:  test parser
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package CustomBlock;
use strict;
use warnings;
use Test::More;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';

sub on_para {
    my ( $self, $parser, $txt ) = @_;
    $self->attrs_by_name->{on_para} = 1;
    return $txt;
}

1;

package CustomFormattingCode;
use strict;
use warnings;
use Test::More;
use Perl6::Pod::FormattingCode;
use base 'Perl6::Pod::FormattingCode';

sub on_para {
    my ( $self, $p, $txt ) = @_;
    $self->attrs_by_name->{on_para} = 1;
    return $txt;
}

1;

package ParsePara;
use strict;
use warnings;
use Test::More;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';

sub on_para {
    my ( $self, $parser, $txt ) = @_;
    foreach my $line ( split( /\n/, $txt ) ) {
        my ( $block_name, $para ) = split( /:\s+/, $line );
        next unless defined($block_name) or defined($para);
        $parser->start_block($block_name);
        $parser->para($para);
        $parser->end_block($block_name);
    }
    $self->attrs_by_name->{on_para} = 1;
    return;
}

package T::Parser;
use strict;
use warnings;
use Data::Dumper;
use Test::More;
use Perl6::Pod::Parser::CustomCodes;
use base 'TBase';

sub p01_custom_code_on_para : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T, 'Perl6::Pod::Parser::CustomCodes' );
=begin pod
=use CustomFormattingCode Tcustom<>
M<Tcustom:some text>
=end pod
T
    $t->is_deeply_xml(
        $x,
q# <pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'><Tcustom pod:type='code' pod:on_para='1'>some text</Tcustom>
 </para></pod>#
    );
}

sub p02_custom_block_on_para : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, );
=begin pod
=use CustomBlock CustomB
=CustomB test
=end pod
T1
    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><CustomB pod:type='block' pod:on_para='1'>test
 </CustomB></pod>#
    );
}

sub p02_custom_block_on_paraq {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, );
=begin pod
=use CustomBlock CustomB
=CustomB test
=end pod
T1
    $t->is_deeply_xml(
        $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><CustomB pod:type='block' pod:on_para='1'>test
 </CustomB></pod>#
    );
}

sub p03_new_elems_from_para : Test {
    my $t = shift;
    my $x = $t->parse_to_xml( <<T1, );
=begin pod
=use  ParsePara ParsePara
=for ParsePara
code: test
para: test

=end pod
T1
    $t->is_deeply_xml( $x,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><ParsePara pod:type='block' pod:on_para='1'><code pod:type='block'><![CDATA[test]]></code><para pod:type='block'>test</para></ParsePara></pod>#
    );
}

sub p04_process_para : Test(2) {
    my $t         = shift;
    my $out       = '';
    my $to_parser = new Perl6::Pod::To::XML:: out_put => \$out;
    my ( $p, $f ) = $t->make_parser($to_parser);
    my $txt = <<T;
test S<L<k>>
T
    my $ref1 = $p->parse_para($txt);
    is_deeply $ref1, [
        {
            'type' => 'para',
            'data' => 'test '
        },
        {
            'name'   => 'S',
            'childs' => [
                {
                    'name'   => 'L',
                    'childs' => [ 'k' ]
                }
            ]
        },
        {
            'type' => 'para',
            'data' => '
'
        }
      ],
      'check stuct';
    is_deeply $ref1, $p->parse_para($ref1), 'duble pass';
}

sub p05_process_events : Test(3) {
    my $t         = shift;
    my $out       = '';
    my $to_parser = new Perl6::Pod::To::XML:: out_put => \$out;
    my ( $p, $f ) = $t->make_parser($to_parser);
    my $blk = $p->mk_block( 'some', '', 1 );
    my $txt = <<T;
S<L<k>>test
T
    my $ref = $p->parse_para($txt);
    is_deeply $ref, [
        {
            'name'   => 'S',
            'childs' => [
                {
                    'name'   => 'L',
                    'childs' => [ 'k' ]
                }
            ]
        },
        {
            'type' => 'para',
            'data' => 'test
'
        }
      ],
      'check parse_para for S<L<k>>test';

    is_deeply [ $p->__make_events( $ref->[0] ) ],
      [
        {
            'data' => 'S',
            'type' => 'start_fcode'
        },
        {
            'data' => 'L',
            'type' => 'start_fcode'
        },
        {
            'data' => 'k',
            'type' => 'para'
        },
        {
            'data' => 'L',
            'type' => 'end_fcode'
        },
        {
            'data' => 'S',
            'type' => 'end_fcode'
        }
      ],
      '__make_events for element';
    $p->begin_input;
    $p->start_block( 'pod',,  0 );
    $p->start_block( 'para',, 0 );
    $p->run_para($ref);
    $p->end_block( 'para',, 0 );
    $p->end_block( 'pod',,  0 );
    $p->end_input;
    $t->is_deeply_xml(
        $out,
q#<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'><para pod:type='block'><S pod:type='code'><L pod:section='' pod:type='code' pod:scheme='' pod:is_external='' pod:name='' pod:address=''>k</L></S>test
 </para></pod>#
    );
}

1;

