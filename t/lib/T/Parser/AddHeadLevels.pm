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

sub h01_test_one_level : Test {
    my $test = shift;
#    my ( $p, $f, $o ) =
    #  $test->parse_mem( <<TXT, 'Perl6::Pod::Parser::AddHeadLevels' );
    my ( $p, $f, $o ) =
      $test->parse_to_xml( <<TXT, 'Perl6::Pod::Parser::AddHeadLevels' );
=begin pod
=head1 test1
=end pod
TXT
    $test->is_deeply_xml( $o, <<T);
<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <headlevel level="1" pod:type="block" pod:hlevel="1" child="head1">
    <head1 pod:type="block">test1
</head1>
  </headlevel>
</pod>
T
}

sub h02_test_two_levels : Test {
    my $test = shift;
     my $o = $test->parse_to_xml( <<TXT, 'Perl6::Pod::Parser::AddHeadLevels');
=begin pod
=head1 test1
=head2 test2
=end pod
TXT
    $test->is_deeply_xml( $o, <<T);
<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <headlevel level="1" pod:type="block" pod:hlevel="1" child="head1">
    <head1 pod:type="block">test1
</head1>
    <headlevel level="2" pod:type="block" pod:hlevel="2" child="head2">
      <head2 pod:type="block">test2
</head2>
    </headlevel>
  </headlevel>
</pod>
T
}

sub h04_test_two_levelsX : Test {
    my $test = shift;
    my $o = $test->parse_to_xml( <<TXT, 'Perl6::Pod::Parser::AddHeadLevels' );
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
#print $o;exit;
   $test->is_deeply_xml( $o, <<T);
<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <headlevel level="1" pod:type="block" pod:hlevel="1" child="head1">
    <head1 pod:type="block"/>
    <headlevel level="2" pod:type="block" pod:hlevel="2" child="head2">
      <head2 pod:type="block"/>
      <headlevel level="3" pod:type="block" pod:hlevel="3" child="head3">
        <head3 pod:type="block"/>
      </headlevel>
    </headlevel>
    <headlevel level="2" pod:type="block" pod:hlevel="2" child="head2">
      <head2 pod:type="block"/>
      <headlevel level="3" pod:type="block" pod:hlevel="3" child="head3">
        <head3 pod:type="block"/>
      </headlevel>
    </headlevel>
  </headlevel>
  <headlevel level="1" pod:type="block" pod:hlevel="1" child="head1">
    <head1 pod:type="block"/>
    <headlevel level="2" pod:type="block" pod:hlevel="2" child="head2">
      <head2 pod:type="block"/>
    </headlevel>
  </headlevel>
</pod>
T

}

sub h1_repeated_12323123 : Test(1) {
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
$t->is_deeply_xml( $o,<<T2, 'xml for heads 12323123');
<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <headlevel level="1" pod:type="block" pod:hlevel="1" child="head1">
    <head1 pod:type="block"/>
    <headlevel level="2" pod:type="block" pod:hlevel="2" child="head2">
      <head2 pod:type="block"/>
      <headlevel level="3" pod:type="block" pod:hlevel="3" child="head3">
        <head3 pod:type="block"/>
      </headlevel>
    </headlevel>
    <headlevel level="2" pod:type="block" pod:hlevel="2" child="head2">
      <head2 pod:type="block"/>
      <headlevel level="3" pod:type="block" pod:hlevel="3" child="head3">
        <head3 pod:type="block"/>
      </headlevel>
    </headlevel>
  </headlevel>
  <headlevel level="1" pod:type="block" pod:hlevel="1" child="head1">
    <head1 pod:type="block"/>
    <headlevel level="2" pod:type="block" pod:hlevel="2" child="head2">
      <head2 pod:type="block"/>
      <headlevel level="3" pod:type="block" pod:hlevel="3" child="head3">
        <head3 pod:type="block"/>
      </headlevel>
    </headlevel>
  </headlevel>
</pod>
T2

}

sub test_two_levelsX_ : Test {
    #return "";
    my $test = shift;
    my $lname = "uus";
   my $o = $test->parse_to_xml( <<TXT, 'Perl6::Pod::Parser::AddHeadLevels' );
=begin pod
=NAME Test
=head2 test1
=end pod
TXT
    ok $o;
}

1;

