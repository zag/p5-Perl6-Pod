#===============================================================================
#
#  DESCRIPTION:  
#
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================
package Perl6::Pod::Block::Test;
use strict;
use warnings;
use Perl6::Pod::Block;
use Test::More;
use Data::Dumper;
use base 'Perl6::Pod::Block';

sub on_para {
    my ( $self, $parser, $txt ) = @_;
    if ( exists $self->get_attr->{w2} ) {
       $txt = uc $txt;
    }
    $txt;
}

sub to_xml1 {
    my ( $self, $parser, $text ) = @_;
    my $attr = $self->get_attr();
    chomp($text);
    $parser->{TEST} = $self->get_attr;

    #warn Dumper $attr;
    return "<x>$text</x>";
}

1;

package Perl6::Pod::FormattingCode::Test;
use strict;
use warnings;
use Perl6::Pod::FormattingCode;
use Test::More;
use Data::Dumper;
use base 'Perl6::Pod::FormattingCode';

sub on_para {
    my ( $self, $parser, $txt ) = @_;
    if ( exists $self->get_attr->{w2} ) {
       $txt = uc $txt;
    }
    $txt;
}

sub to_xml1 {
    my ( $self, $parser, $text ) = @_;
    my $attr = $self->get_attr();
    chomp($text);
    $parser->{HEAD1} = $self->get_attr;
    my $ln = $self->local_name;
    # warn Dumper $attr;
    return "<$ln>$text</$ln>";
}

1;

package Perl6::Pod::To::XML1;
use warnings;
use strict;
use Perl6::Pod::To;
use base 'Perl6::Pod::To';

use Test::More;
use Data::Dumper;

sub export_block_pod {
    my $self  = shift;
    my $block = shift;
    return "<a>@_</a>";
}

sub export_block_test {
    chomp $_[2];
    return "<t>$_[2]</t>";
}

sub export_code_C {
    return "C[" . $_[2] . "]";
}

sub export_code_M {
    my ( $self, $elem, $data) = @_;
    $self->{M} = 
    return "M[".$data."]";
}

sub export_block_head1 {
    my ( $self, $el, @data ) = @_;

    return "<head1>@data</head1>"
}
sub export_block {
    my ( $self, $el, @data ) = @_;
    my $lname = $el->local_name;
    if ( $lname =~ /test1/ ) {
        return $el->to_xml1( $self, @data );
    }
    else {
        return $self->SUPER::export_block( $el, @data );
    }
}

1;

package T::Parser;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use lib 't/lib';
use base "TBase";;

sub p1_create_id : Test(no_plan){
    my $t = shift;
    
    my $x = $t->parse_to_xml( <<T1,);
=begin pod
=begin head1
test
test2

asdasdasdasd B< sd>
asdasd

=end head1
=end pod
T1
#    diag $x;
#    exit;
}

1;
package main;
use strict;
use warnings;
use Test::More(tests=>30);
use Data::Dumper;
my $FORMATTING_CODE = q{[BCDEIKLMNPRSTUVXZ]};
use_ok 'Perl6::Pod::Parser';
use_ok 'Perl6::Pod::Parser::Context';
use_ok 'Perl6::Pod::Block';
use_ok 'XML::ExtOn', 'create_pipe';
use_ok 'XML::ExtOn::Writer';
use_ok 'Perl6::Pod::Parser::Pod2Events';
use_ok 'Perl6::Pod::Parser::Context';
use_ok 'Perl6::Pod::To';
use_ok 'Perl6::Pod::To::XML';
####################test context ##########

use strict;
use warnings;
use lib 't/lib';
use T::Parser;
Test::Class->runtests;
use utf8;

=head2 to_xml (<$in_buf_ref|IN_FILE> , <$out_buf_ref|OUT_FILE> )

create XML formatter;
return link to formatter 

=cut

sub to_xml1 {
    return to_abstract( 'Perl6::Pod::To::XML1', @_ );
    my $out = shift;
    my %arg = ();
    $arg{out_put} = $out if defined($out);
    my $out_formatter = new Perl6::Pod::To::XML1:: %arg;
    my $p = create_pipe( 'Perl6::Pod::Parser', $out_formatter );
    return wantarray ? ( $p, $out_formatter ) : $p;
}

sub to_abstract {
    my $class = shift;
    my $out   = shift;
    my %arg   = ();
    $arg{out_put} = $out if defined($out);
    my $out_formatter = $class->new(%arg);
    my $p = create_pipe( 'Perl6::Pod::Parser', $out_formatter );
    return wantarray ? ( $p, $out_formatter ) : $p;
}

#test ABSTRACT output formatter
my $buf;
my $abs = new Perl6::Pod::To:: format_name => 'xml', out_put => \$buf;
isa_ok $abs, 'Perl6::Pod::To', 'abstract formatter';
is $abs->{format_name}, 'xml', 'in param format_name';
is ref( $abs->{out_put} ), 'SCALAR', 'in param out_put';

my $abs1 = new Perl6::Pod::To::;
isa_ok $abs1, 'Perl6::Pod::To', 'abstract formatter';
ok !$abs1->{format_name}, 'in param format_name';

my $buf1;
my ( $p, $f ) = to_xml1( \$buf1 );
ok $p && $f, 'return array';
$p->parse( \<<TXT_1);
=begin pod

=begin test
sdsd C<code>
=end test

=end pod

TXT_1

is $buf1, '<a><t>sdsd C[code]</t></a>', 'check sample formater';

#set predefined config
my $buf2;
my ( $_p1, $_f1 ) = to_xml1( \$buf2 );

$_p1->_parse_chunk( \<<TXT_2);
=use  Perl6::Pod::Block::Test test1  :w
=use  Perl6::Pod::Block::Test test2  :w1
TXT_2

my $use1    = $_p1->current_context->use;
my @bnames1 = qw/ test1 test2/;
is_deeply [ @$use1{@bnames1} ], [ ('Perl6::Pod::Block::Test') x 2 ],
  'register config';
$_p1->parse( \<<TXT_3);
=test1 sd
TXT_3

is $buf2, '<x>sd</x>', 'to_xml1';

my $buf3;
my ( $_p3, $_f3 ) = to_xml1( \$buf3 );
$_p3->parse( \<<TXT_4);
=use  Perl6::Pod::Block::Test test1  :w
=config  test1 :w2 :!w3

=for test1 :w1 :w3 :up_case
msg
TXT_4

my $use3 = $_p3->current_context->config;
is_deeply $_f3->{TEST},
  {
    'w3' => 1,
    'w1' => 1,
    'w2' => 1,
    'up_case'=>1
  },
  'config and block opt';

is $buf3, '<x>MSG</x>', 'on_para';

my $buf5;
my ( $_p5, $_f5 ) = to_xml1( \$buf5 );
$_p5->parse( \<<TXT_5);
=use Perl6::Pod::FormattingCode::Test FT<> :w1
=config head1 :w1
=config FT<> :rerer :like<head1>
=head1 This is a head1
format code M<FT: test message>
TXT_5

#diag Dumper $_p5->current_context;
#diag $buf5;
#diag Dumper \@INC;
