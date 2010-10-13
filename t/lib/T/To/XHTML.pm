#===============================================================================
#
#  DESCRIPTION:  test DocBook out put
#
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::To::XHTML;
use strict;
use warnings;
use Test::More;
use T::To;
use base 'T::To';
use Data::Dumper;
use XML::ExtOn::Writer;
use Perl6::Pod::To::XHTML::MakeBody;
use XML::ExtOn('create_pipe');

sub make_xhtml_parser {
    my $t          = shift;
    my $out        = shift;
    my $xml_writer = new XML::ExtOn::Writer:: Output => $out;
    my $out_filters =
      create_pipe( create_pipe( @_ ? @_ : 'XML::ExtOn', $xml_writer ) );
    my ( $p, $f ) = Perl6::Pod::To::to_abstract(
        'Perl6::Pod::To::XHTML', $out,
        doctype => 'xhtml',
        headers => 0
    );
    return wantarray ? ( $p, $f ) : $p;
}

sub parse_to_xhtml {
    my $t    = shift;
    my $text = shift;
    my $str  = '';
    my $p    = $t->make_xhtml_parser( \$str, @_ );
    $p->parse( \$text );
    return $str;
}

sub to_xml_01_doctype : Test {
    my $t = shift;
    my $buf;
    $t->make_xhtml_parser( \$buf )->parse( \<<T1);
=begin pod
=end pod
T1
    $t->is_deeply_xml( $buf, q#<xhtml xmlns='http://www.w3.org/1999/xhtml' />#,
        'empty' );
}

sub to_xml_02_NAME : Test {
    my $t = shift;
    my $buf;
    $t->make_xhtml_parser( \$buf )->parse( \<<T1);
=begin pod
=NAME test
=end pod
T1

    $t->is_deeply_xml(
        $buf, q#<xhtml xmlns='http://www.w3.org/1999/xhtml'><head><title>test
</title></head></xhtml>#
    );
}

sub to_xml_03_Heads : Test {
    my $t = shift;
    my $buf;
    $t->make_xhtml_parser( \$buf )->parse( \<<T1);
=begin pod
=NAME test
=head1 Testing
proverjka
=head2 Testing
level 2
=head1 Testing
=head2 Testing
=end pod
T1

    $t->is_deeply_xml(
        $buf,
        q#<xhtml xmlns='http://www.w3.org/1999/xhtml'><head><title>test
</title></head><h1>Testing
proverjka
</h1><h2>Testing
level 2
</h2><h1>Testing
</h1><h2>Testing
</h2></xhtml>#, 'multi head level'
    );
}

sub to_xml_04_test_ordered : Test {
    my $t   = shift;
    my $pod = <<T1;

=begin pod
=for item :numbered
entry 
=for item :numbered
entry2
=end pod
T1

    $t->is_deeply_xml(
        $t->parse_to_xhtml($pod),
        q#<xhtml xmlns='http://www.w3.org/1999/xhtml'><ol><li>entry 
</li><li>entry2
</li></ol></xhtml>#
      )

}

sub to_xml_05_itemized : Test {
    my $t   = shift;
    my $pod = <<T1;

=begin pod
=for item 
entry 
=for item 
entry2
=end pod
T1
    $t->is_deeply_xml(
        $t->parse_to_xhtml($pod),
        q#<xhtml xmlns='http://www.w3.org/1999/xhtml'><ul><li>entry 
</li><li>entry2
</li></ul></xhtml>#
    );
}

sub to_xml_06_variable : Test {
    my $t   = shift;
    my $pod = <<T1;
=begin pod
=for item :term<TEST> 
entry 
=for item :term<TEST2> 
entry2
=end pod
T1
    $t->is_deeply_xml(
        $t->parse_to_xhtml($pod),
q#<xhtml xmlns='http://www.w3.org/1999/xhtml'><dl><dt><strong>TEST</strong><dd>entry 
</dd></dt><dt><strong>TEST2</strong><dd>entry2
</dd></dt></dl></xhtml>#
    );
}

sub x01_add_custom_heads : Test {
    my $t         = shift;
    my $x         = '';
    my $to_parser = new Perl6::Pod::To::XHTML::
      out_put => \$x,
      header  => 1,
      head    => [
        link => {
            rel  => "stylesheet",
            href => "/styles/main.1232622176.css"
        }
      ];
    my ( $p, $f ) = $t->make_parser($to_parser);
    $p->parse( \<<T);
=pod
asdasdad
T
    $t->is_deeply_xml(
        $x,
q#<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd' ><html xmlns='http://www.w3.org/1999/xhtml'><head><link rel='stylesheet' href='/styles/main.1232622176.css' /></head><p>asdasdad
</p></html>#
      )

}

sub x01_add_custom_heads_and_NAME : Test {
    my $t         = shift;
    my $x         = '';
    my $to_parser = new Perl6::Pod::To::XHTML::
      out_put => \$x,
      header  => 1,
      head    => [
        link => {
            rel  => "stylesheet",
            href => "/styles/main.1232622176.css"
        }
      ];
    my ( $p, $f ) = $t->make_parser($to_parser);
    $p->parse( \<<T);
=pod
=NAME Test

asdasdad
T
    $t->is_deeply_xml(
        $x,
q#<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd' ><html xmlns='http://www.w3.org/1999/xhtml'><head><title>Test
</title><link rel='stylesheet' href='/styles/main.1232622176.css' /></head></html>#
    );
}

sub a002_add_body_head : Test {
    my $t           = shift;
    my $x           = '';
    my $xml_writer  = new XML::ExtOn::Writer:: Output => \$x;
    my $body_filter = new Perl6::Pod::To::XHTML::MakeBody::;
    my $out_filter  = create_pipe( $body_filter, $xml_writer );
    my $to_parser   = new Perl6::Pod::To::XHTML::
      out_put => $out_filter,
      header  => 1,
      head    => [
        link => {
            rel  => "stylesheet",
            href => "/styles/main.1232622176.css"
        }
      ];
    my ( $p, $f ) = $t->make_parser($to_parser);
    $p->parse( \<<T);
=begin pod
=NAME Test

asdasdad
asdasd
=end pod
T
    $t->is_deeply_xml(
        $x,
q#<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.1//EN' 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd' ><html xmlns='http://www.w3.org/1999/xhtml'><head><title>Test
 </title><link rel='stylesheet' href='/styles/main.1232622176.css' /></head><body><p>asdasdad
 asdasd
 </p></body></html>#
    );
}

sub a001_add_custom_heads_and_NAME : Test {
    my $t         = shift;
    my $x         = '';
    my $to_parser = new Perl6::Pod::To::XHTML::
      out_put => \$x,
      header  => 0,
      body    => 0,
      ;
    my ( $p, $f ) = $t->make_parser($to_parser);
    my $str = <<T;
=begin pod
=head1 asd

=for item :term<Term1>
B<1>
=head2 sdsd
=for item :term<Term2>
2
=end pod
T
    $p->parse( \$str );
    $t->is_deeply_xml(
        $x,
        q#<html xmlns='http://www.w3.org/1999/xhtml'><h1>asd
 </h1><dl><dt><strong>Term1</strong><dd><strong>1</strong>
 </dd></dt></dl><h2>sdsd
 </h2><dl><dt><strong>Term2</strong><dd>2
 </dd></dt></dl></html>#
    );
}
1;

