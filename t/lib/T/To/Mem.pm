#===============================================================================
#  DESCRIPTION:  Test Mem formater
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================
package T::To::Mem;
use strict;
use warnings;
use base 'T::To';
use Test::More;
use Data::Dumper;

sub setup : Test(setup) {
    my $test = shift;

    #my $filter =
    #die;

}

sub make_parser {
    my $test  = shift;
    my $out   = shift;
    my $class = $test->testing_class;
    my $obj   = $class->new( out_put => $out );
    return $test->SUPER::make_parser($obj)

}

sub parse {
    my $test = shift;
    my $text = shift;
    my $out  = [];
    my ( $p, $f ) = $test->make_parser($out);
    $p->parse( \$text );
    return wantarray ? ( $p, $f, $out ) : $out;
}

sub block_01 : Test {
    my $test = shift;
    my $o    = $test->parse(<<T1);
=begin pod :w1
pod_text
=end pod
T1


is_deeply $o,
 [
           {
             'name' => 'pod',
             'childs' => [
                           {
                            'name' => 'para',
                             'childs' => [
                                           'pod_text'
                                        ],
                             'attr' => {}
                           }
                         ],
             'attr' => {
                         'w1' => 1
                       }
           }
         ],
'simply pod';
}

sub block_02 : Test {
    my $test = shift;
    my $o    = $test->parse(<<TXT);
=begin pod
=for head1 head
=end pod
TXT
    is_deeply $o,
      [
        {
            'name'   => 'pod',
            'childs' => [
                {
                    'name'   => 'head1',
                    'childs' => [],
                    'attr'   => {}
                }
            ],
            'attr' => {}
        }
      ],
      'with childs';
}

sub block_03 : Test {
    my $test = shift;
    my $o    = $test->parse(<<TXT);
TXT
    is_deeply $o, [], 'empty pod';
}

sub block_04 : Test {
    my $test = shift;
    my $o    = $test->parse(<<TXT);
=config head1 :w1
=config head2 :w2
=head1 te
=head2 C<re>
TXT
    is_deeply $o,
      [
        {
            'name'   => 'head1',
            'childs' => [ 'te' ],
            'attr'   => { 'w1' => 1 }
        },
        {
            'name'   => 'head2',
            'childs' => [
                {
                    'name'   => 'C',
                    'childs' => [ 're' ],
                    'attr'   => {}
                },
                ''
            ],
            'attr' => { 'w2' => 1 }
        }
      ],
      'formatting code';
}

=pod

sub block_04 :Test {
    my $test = shift;
    my $o = $test->parse(<<TXT);
=config head1 :w1
=head1 te
TXT
    print Dumper $o;
#    is_deeply $o, [], 'attr pod'
}
=cut

1;
