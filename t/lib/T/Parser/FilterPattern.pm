#===============================================================================
#
#  DESCRIPTION:  Test for filter
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::Parser::FilterPattern;
use base 'TBase';
use strict;
use warnings;
use Data::Dumper;
use Test::More;

sub p01_check_empty_patterns : Test {
    my $t      = shift;
    my $filter = new Perl6::Pod::Parser::FilterPattern:: patterns => [];
    my $XML    = <<T;
=begin pod
=for para :allow<I>
wrwr
=for para :!public
private
=end pod
T
    my $x1 = $t->parse_to_xml( $XML, $filter );
    my $x2 = $t->parse_to_xml($XML);
    $t->is_deeply_xml( $x2, $x1 );

}

sub p01_check_pattern_by_local_name : Test {
    my $t      = shift;
    my $dummy  = new Perl6::Pod::Parser::FilterPattern:: patterns => [];
    my $p1     = $dummy->mk_block('para');
    my $filter = new Perl6::Pod::Parser::FilterPattern:: patterns => [$p1];
    my $XML    = <<T;
=begin pod
=head1 Main
=for para :allow<I>
wrwr
=for para :!public
private
=end pod
T
    my $x = $t->parse_to_xml( $XML, $filter );
    $t->is_deeply_xml(
        qq#<r>$x</r>#,
q#<r><para pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html' allow='I'>wrwr
 </para><para pod:type='block' public='0'>private
 </para></r>#
      )

}

sub p01_check_pattern_by_local_name_and_attr : Test {
    my $t      = shift;
    my $dummy  = new Perl6::Pod::Parser::FilterPattern:: patterns => [];
    my $p1     = $dummy->mk_block( 'para', ':!public' );
    my $filter = new Perl6::Pod::Parser::FilterPattern:: patterns => [$p1];
    my $XML    = <<T;
=begin pod
=head1 Main
=for para :allow<I>
wrwr
=for para :!public
private
=end pod
T
    my $x = $t->parse_to_xml( $XML, $filter );
    $t->is_deeply_xml(
        qq#<r>$x</r>#, q#<r>
    <para pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html' public='0'>private
</para></r>#
      )

}

sub p02_check_empty_out : Test {
    my $t      = shift;
    my $dummy  = new Perl6::Pod::Parser::FilterPattern:: patterns => [];
    my $p1     = $dummy->mk_block( 'para', ':!public' );
    my $filter = new Perl6::Pod::Parser::FilterPattern:: patterns => [$p1];
    my $XML    = <<T;
=begin pod
=head1 Main
=for para :allow<I>
wrwr
=for para :public
private
=end pod
T
    my $x = $t->parse_to_xml( $XML, $filter );
    $t->is_deeply_xml( qq#<r>$x</r>#, q#<r></r># )

}

sub p03_check_multiply_patterns : Test {
    my $t     = shift;
    my $dummy = new Perl6::Pod::Parser::FilterPattern:: patterns => [];
    my $p1    = $dummy->mk_block( 'para', ':!public' );
    my $p2    = $dummy->mk_block( 'head1', ':!public' );
    my $filter =
      new Perl6::Pod::Parser::FilterPattern:: patterns => [ $p1, $p2 ];
    my $XML = <<T;
=begin pod
=head1 Main
=for head1  :!public
Main
=for para :allow<I>
wrwr
=for para :!public
private
=end pod
T
    my $x = $t->parse_to_xml( $XML, $filter );
    $t->is_deeply_xml(
        qq#<r>$x</r>#,
q#<r><head1 pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html' public='0'>Main
</head1><para pod:type='block' public='0'>private
</para>
</r>#
      )

}

sub p03_check_only_attr_in_pattern : Test {
    my $t     = shift;
    my $dummy = new Perl6::Pod::Parser::FilterPattern:: patterns => [];
    my $p1    = $dummy->mk_block( 'none', ':!public' );
    $p1->attrs_by_name->{no_name} = 1;
    my $filter = new Perl6::Pod::Parser::FilterPattern:: patterns => [$p1];
    my $XML = <<T;
=begin pod
=head1 Main
=for head1  :!public
Main
=for para :allow<I>
wrwr
=for para :!public
private
=end pod
T
    my $x = $t->parse_to_xml( $XML, $filter );
    $t->is_deeply_xml(
        qq#<r>$x</r>#,
q#<r><head1 pod:type='block' xmlns:pod='http://perlcabal.org/syn/S26.html' public='0'>Main
</head1><para pod:type='block' public='0'>private
</para></r>#
    );

}

1;

