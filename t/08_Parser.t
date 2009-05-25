package Perl6::Pod::Block::Test;
use strict;
use warnings;
use Perl6::Pod::Block;
use Test::More;
use Data::Dumper;
use base 'Perl6::Pod::Block';

sub start {
    my $self = shift;
    diag "start $self";

}

sub end {
    my $self = shift;
    diag "End $self";
}

sub to_xml {
    my ( $self, $parser, $text ) = @_;
    my $attr = $self->get_attr();

    #warn Dumper $attr;
    return "<x>$text</x>";
}
1;

package Perl6::Pod::Format::Test;
use warnings;
use Perl6::Pod::Block;
use Test::More;
use Data::Dumper;
use base 'Perl6::Pod::Block';

1;

package Perl6::Pod::FormattingCode::O;
use Perl6::Pod::FormattingCode;
use base 'Perl6::Pod::FormattingCode';
sub to_xml { "<O>$_[2]</O>" }

package Perl6::Pod::FormattingCode::L;
use warnings;
use Perl6::Pod::FormattingCode;
use Test::More;
use Data::Dumper;
use base 'Perl6::Pod::FormattingCode';

sub to_xml {
    my $self = shift;
    my ( $p, $txt ) = @_;
    diag "to_xml:: $txt";
    return $txt;
}

package Perl6::Pod::FormattingCode::C;
use Perl6::Pod::FormattingCode;
use base 'Perl6::Pod::FormattingCode';
sub to_xml {"<code>$_[2]</code>"}

1;


package main;
use strict;
use warnings;
use Test::More('no_plan');
use Data::Dumper;
my $FORMATTING_CODE = q{[BCDEIKLMNPRSTUVXZ]};
use_ok 'Perl6::Pod::Parser';
use_ok 'Perl6::Pod::Parser::Context';
use_ok 'Perl6::Pod::Block';
use_ok 'XML::ExtOn', 'create_pipe';
use_ok 'XML::SAX::Writer';
use_ok 'Perl6::Pod::Parser::Pod2Events';
use_ok 'Perl6::Pod::Parser::Context';
####################test context ##########

use utf8;

sub parse_pod {
    my $t1    = shift;
    my $class = shift || 'Perl6::Pod::Parser';
    my $ev    = ${class}->new;
    my $buf;
    open( my $f1, "<", \$t1 ) or die "parse_pod: " . $!;
    $ev->parse($f1);
    close $f1;
    return $ev;
}

=pod
my $r1 = parse_pod(<<TXT01);
=begin pod
= :we

str1
str3

    =end pod
TXT01

=cut

#diag Dumper $r1->{BLOCKS};

my $s1 = (<<TXT02);
=begin pod :w1
test message
=begin test :attr1

 =code

C<inside>

=end test


=end pod

TXT02

my $buf;
my $w = new XML::SAX::Writer:: Output => \$buf;
my $p = create_pipe( 'Perl6::Pod::Parser', 'Perl6::Pod::To::XML', $w );

#$p->parse( \$s1 );

#diag $buf;

my $s2 = (<<TXT03);
=begin pod
aa L< C<ds> |dsdasd
sd
>

O<ocode>
=end pod
TXT03

#diag Dumper( Pod::Parser->new->parse_text( $s2, 123 ) );
my $buf1;
my $w1 = new XML::SAX::Writer:: Output => \$buf1;
my $p1 = create_pipe( 'Perl6::Pod::Parser', 'Perl6::Pod::To::XML', $w1 );
$p1->current_context->use->{L} = 'Perl6::Pod::FormattingCode::L';
$p1->current_context->use->{C} = 'Perl6::Pod::FormattingCode::C';
$p1->current_context->use->{O} = 'Perl6::Pod::FormattingCode::O';
$p1->parse( \$s2 );
diag $buf1;

#diag my $p1 = new Perl6::Pod::Parser::;

