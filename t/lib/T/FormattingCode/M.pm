#===============================================================================
#  DESCRIPTION:
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================
package CustomCode;
use strict;
use warnings;
use base 'Perl6::Pod::FormattingCode';
1;

package CustomCodeCF;
use strict;
use warnings;
use base 'Perl6::Pod::FormattingCode';

sub to_mem {
    my ( $self, $parser, $para ) = @_;
    return { name => "ok", attr => $self->get_attr };
}
1;

package CustomCodeFF;
use strict;
use warnings;
use base 'Perl6::Pod::FormattingCode';

sub to_mem1 {
    my ( $self, $parser, $para ) = @_;
    return { name => "ok", attr => $self->get_attr };
}
1;

package T::FormattingCode::M;
use strict;
use warnings;
use Data::Dumper;
use Test::More;
use base "T::FormattingCode";

sub startup : Test(startup=>1) {
    use_ok('Perl6::Pod::Parser::CustomCodes');
}

sub check_use : Test(2) {
    my $test = shift;
    my ( $p, $f, $o ) = $test->parse_mem(<<TXT);
=use   CustomCode TT<>
=head1 Test M<TT: test_code>
TXT
    is $p->current_context->use->{'TT<>'}, 'CustomCode',
      'define custom formatcode';
    is_deeply $o,
      [
        {
            'name'   => 'head1',
            'childs' => [
                'Test ',
                {
                    'name'   => 'M',
                    'childs' => ['TT: test_code'],
                    'attr'   => {}
                },
                ''
            ],
            'attr' => {}
        }
      ];
}

sub resolve_filter : Test {
    my $test = shift;
    my $o = $test->parse_mem( <<TXT, 'Perl6::Pod::Parser::CustomCodes' );
=begin pod
=use CustomCode TT<>
sds M<TT: test_code>
=end pod
TXT

    is_deeply $o,
      [
        {
            'name'   => 'pod',
            'childs' => [
                'sds ',
                {
                    'name'   => 'TT',
                    'childs' => ['test_code'],
                    'attr'   => {}
                },
                ''
            ],
            'attr' => {}
        }
      ];
}

sub custom_code_export_mem : Test {
    my $test = shift;
    my ( $p, $f, $o ) =
      $test->parse_mem( <<TXT, 'Perl6::Pod::Parser::CustomCodes' );
=use CustomCodeCF CF<>
=begin head1
M<CF:eer>
=end head1
TXT
    is_deeply $o,
      [
        {
            'name'   => 'head1',
            'childs' => [
                {
                    'name' => 'ok',
                    'attr' => {}
                },
                ''
            ],
            'attr' => {}
        }
      ];
}
sub code_preconfig : Test {
    my $test  =shift;
    my ($p, $f, $o) = $test->parse_mem(<<TXT, 'Perl6::Pod::Parser::CustomCodes');
=use CustomCodeCF OO<>
=config OO<> :w1
=begin para
M<OO: r>
=end para
TXT
is_deeply $o,
[
           {
             'name' => 'para',
             'childs' => [
                           {
                             'name' => 'ok',
                             'attr' => {
                                         'w1' => 1
                                       }
                           },
                           ''
                         ],
             'attr' => {}
           }
         ];
}

sub multiline_M : Test {
    my $test = shift;
    my $o = $test->parse_mem(<<TXT, 'Perl6::Pod::Parser::CustomCodes');
=use CustomCode FF<>
=for head1
M<FF: test sdsd
sdsdsd
sdsd >
TXT
is_deeply $o,  [
          {
            'name' => 'head1',
            'childs' => [
                          {
                            'name' => 'FF',
                            'childs' => [
                                          'test sdsd
sdsdsd
sdsd '
                                        ],
                            'attr' => {}
                          },
                          ''
                        ],
            'attr' => {}
          }
        ];
}
1;

