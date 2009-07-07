#===============================================================================
#  DESCRIPTION:  Test heading levels
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================
package T::Parser::AddHeadLevels;
use strict;
use warnings;
use Test::More;
use base 'TBase';
use Perl6::Pod::Parser::AddHeadLevels;
use Data::Dumper;

sub test_one_level : Test {
    my $test = shift;
    my ( $p, $f, $o ) =
      $test->parse_mem( <<TXT, 'Perl6::Pod::Parser::AddHeadLevels' );
=begin pod
=head1 test1
=end pod
TXT
    is_deeply $o,
      [
        {
            'name'   => 'pod',
            'childs' => [
                {
                    'name'   => 'headlevel',
                    'childs' => [
                        {
                            'name'   => 'head1',
                            'childs' => ['test1'],
                            'attr'   => {}
                        }
                    ],
                    'attr' => { 'level' => 1 }
                }
            ],
            'attr' => {}
        }
      ];
}

sub test_two_levels : Test {
    my $test = shift;
    my $o = $test->parse_mem( <<TXT, 'Perl6::Pod::Parser::AddHeadLevels' );
=begin pod
=head1 test1
=head2 test2
=end pod
TXT
    is_deeply $o,
      [
        {
            'name'   => 'pod',
            'childs' => [
                {
                    'name'   => 'headlevel',
                    'childs' => [
                        {
                            'name'   => 'head1',
                            'childs' => ['test1'],
                            'attr'   => {}
                        },
                        {
                            'name'   => 'headlevel',
                            'childs' => [
                                {
                                    'name'   => 'head2',
                                    'childs' => ['test2'],
                                    'attr'   => {}
                                }
                            ],
                            'attr' => { 'level' => 2 }
                        }
                    ],
                    'attr' => { 'level' => 1 }
                }
            ],
            'attr' => {}
        }
      ];
}

sub test_two_levelsX : Test {
    my $test = shift;
    my $o = $test->parse_mem( <<TXT, 'Perl6::Pod::Parser::AddHeadLevels' );
=begin pod
=head1
=head2
=head3
=head2
=head3
=head1
=head2
=end pod
TXT

    #    print Dumper $o;

    is_deeply $o,
      [
        {
            'name'   => 'pod',
            'childs' => [
                {
                    'name'   => 'headlevel',
                    'childs' => [
                        {
                            'name'   => 'head1',
                            'childs' => [],
                            'attr'   => {}
                        },
                        {
                            'name'   => 'headlevel',
                            'childs' => [
                                {
                                    'name'   => 'head2',
                                    'childs' => [],
                                    'attr'   => {}
                                },
                                {
                                    'name'   => 'headlevel',
                                    'childs' => [
                                        {
                                            'name'   => 'head3',
                                            'childs' => [],
                                            'attr'   => {}
                                        }
                                    ],
                                    'attr' => { 'level' => 3 }
                                }
                            ],
                            'attr' => { 'level' => 2 }
                        },
                        {
                            'name'   => 'headlevel',
                            'childs' => [
                                {
                                    'name'   => 'head2',
                                    'childs' => [],
                                    'attr'   => {}
                                },
                                {
                                    'name'   => 'headlevel',
                                    'childs' => [
                                        {
                                            'name'   => 'head3',
                                            'childs' => [],
                                            'attr'   => {}
                                        }
                                    ],
                                    'attr' => { 'level' => 3 }
                                }
                            ],
                            'attr' => { 'level' => 2 }
                        }
                    ],
                    'attr' => { 'level' => 1 }
                },
                {
                    'name'   => 'headlevel',
                    'childs' => [
                        {
                            'name'   => 'head1',
                            'childs' => [],
                            'attr'   => {}
                        },
                        {
                            'name'   => 'headlevel',
                            'childs' => [
                                {
                                    'name'   => 'head2',
                                    'childs' => [],
                                    'attr'   => {}
                                }
                            ],
                            'attr' => { 'level' => 2 }
                        }
                    ],
                    'attr' => { 'level' => 1 }
                }
            ],
            'attr' => {}
        }
      ];
}

sub h1_repeated_12323123 : Test(no_plan) {
    my $t = shift;
    my $o = $t->parse_to_xml( <<T1, 'Perl6::Pod::Parser::AddHeadLevels');
=begin pod
=head1
=head2
=head3
=head2
=head3
=head1
=head2
=head3

=end pod
T1
#print $o;
$t->is_deeply_xml( $o,<<T2, 'xml for heads 12323123');
<pod pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html'>
   <headlevel level='1' pod:type='block'>
   <head1 pod:type='block' />
      <headlevel level='2' pod:type='block'>
      <head2 pod:type='block' />
           <headlevel level='3' pod:type='block'>
           <head3 pod:type='block' />
           </headlevel>
      </headlevel>
      <headlevel level='2' pod:type='block'>
      <head2 pod:type='block' />
          <headlevel level='3' pod:type='block'>
          <head3 pod:type='block' />
          </headlevel>
      </headlevel>
   </headlevel>
   <headlevel level='1' pod:type='block'>
   <head1 pod:type='block' />
       <headlevel level='2' pod:type='block'>
       <head2 pod:type='block' />
              <headlevel level='3' pod:type='block'>
              <head3 pod:type='block' />
              </headlevel>
        </headlevel>
    </headlevel>
</pod>

T2

}

sub test_two_levelsX_ : Test {
    return "";
    my $test = shift;
    my $o = $test->parse_mem( <<TXT, 'Perl6::Pod::Parser::AddHeadLevels' );
=begin pod
=head1 test1
=end pod
TXT
    print Dumper $o;
}

1;

