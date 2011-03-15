#===============================================================================
#
#  DESCRIPTION:  test DocBook out put
#
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::To::DocBook;
use strict;
use warnings;
use Test::More;
use T::To;
use base 'T::To';
use Data::Dumper;
use XML::ExtOn::Writer;
use XML::ExtOn('create_pipe');

sub make_doc_parser {
    my $t          = shift;
    my $out        = shift;
    my $xml_writer = new XML::ExtOn::Writer:: Output => $out;
    my $out_filters =
      create_pipe( create_pipe( @_ ? @_ : 'XML::ExtOn', $xml_writer ) );
    my ( $p, $f ) = Perl6::Pod::To::to_abstract(
        'Perl6::Pod::To::DocBook', $out,
        doctype => 'chapter',
        headers => 0
    );
    return wantarray ? ( $p, $f ) : $p;
}

sub parse_to_doc {
    my $t    = shift;
    my $text = shift;
    my $str  = '';
    my $p    = $t->make_doc_parser( \$str, @_ );
    $p->parse( \$text );
    return $str;
}


sub d01_doctype : Test {
    my $t = shift;
    my $buf;
    $t->make_doc_parser( \$buf )->parse( \<<T1);
=begin pod
=end pod
T1
    $t->is_deeply_xml( $buf, q!<chapter/>! );
    'empty';
}

sub d02_NAME : Test {
    my $t = shift;
    my $buf;
    $t->make_doc_parser( \$buf )->parse( \<<T1);
=begin pod
=NAME test
=end pod
T1
    $t->is_deeply_xml(
        $buf, q!<chapter><title>test
 </title></chapter>!
    );
}

sub d03_Heads : Test {
    my $t = shift;
    my $buf;
    $t->make_doc_parser( \$buf )->parse( \<<T1);
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
        q! <chapter>
    <title>test
 </title>
   <section>
    <title>Testing
 proverjka
 </title>
     <section><title>Testing
 level 2
 </title>
     </section>
   </section>
   <section><title>Testing
 </title>
     <section><title>Testing
 </title>
      </section>
   </section>
</chapter>!, 'multi head level'
    );
}

sub pl01_test_ordered : Test {
    my $t   = shift;
    my $pod = <<T1;

=begin pod
=for item1 :numberedd
# entry 
=for item1 :numberedd
# entry2
=for item2 
entry l21
=for item2 
entry l21
=para
sdfsdfsdf

=for item1 :numbered :continued
asdasd
=end pod
T1
    $t->is_deeply_xml(
        $t->parse_to_doc($pod),
        q#<?xml version="1.0"?>
<chapter>
  <orderedlist>
    <listitem>
      <para>entry 
</para>
    </listitem>
    <listitem>
      <para>entry2
</para>
    </listitem>
  </orderedlist>
  <blockquote>
    <itemizedlist mark="opencircle">
      <listitem>
        <para>entry l21
</para>
      </listitem>
      <listitem>
        <para>entry l21
</para>
      </listitem>
    </itemizedlist>
  </blockquote>
  <para>sdfsdfsdf
</para>
  <orderedlist continuation="continues">
    <listitem>
      <para>asdasd
</para>
    </listitem>
  </orderedlist>
</chapter>
#
      )

}

sub pl01_test_itemized : Test {
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
        $t->parse_to_doc($pod),
        q#<chapter><itemizedlist><listitem><para>entry 
</para></listitem><listitem><para>entry2
</para></listitem></itemizedlist></chapter>#
    );
}

sub pl01_test_variable : Test {
    my $t   = shift;
    my $pod = <<T1;

=begin pod
=for item :term('TEST')
entry 
=for item :term('TEST2')
entry2
=end pod
T1
#    diag $t->parse_to_doc($pod); exit;
    $t->is_deeply_xml(
        $t->parse_to_doc($pod),
q#<chapter><variablelist><varlistentry><term>TEST</term><listitem><para>entry 
</para></listitem></varlistentry><varlistentry><term>TEST2</term><listitem><para>entry2

</para></listitem></varlistentry></variablelist></chapter>#
    );

}

sub pl02_test_variable : Test {
    my $t   = shift;
    my $pod = <<T1;

=begin pod
=for item :term('TEST + AAA') 
entry1 
=for item :term<TEST2> 
entry2
=end pod
T1
    $t->is_deeply_xml(
        $t->parse_to_doc($pod),
q#<chapter><variablelist><varlistentry><term>TEST + AAA</term><listitem><para>entry1 
</para></listitem></varlistentry><varlistentry><term>TEST2</term><listitem><para>entry2
</para></listitem></varlistentry></variablelist></chapter>#)
}

sub z002_item_levels : Test {
    my $t         = shift;
    my $pod = <<T;
=begin pod
=item1 Term1
=item2 sdsd
=item3 sdsd
=item1 
2
=end pod
T
    $t->is_deeply_xml(
        $t->parse_to_doc($pod),
        q#<?xml version="1.0"?>
<chapter>
  <itemizedlist>
    <listitem>
      <para>Term1
 </para>
    </listitem>
  </itemizedlist>
  <blockquote>
    <itemizedlist mark="opencircle">
      <listitem>
        <para>sdsd
 </para>
      </listitem>
    </itemizedlist>
  </blockquote>
  <blockquote>
    <blockquote>
      <itemizedlist mark="box">
        <listitem>
          <para>sdsd
 </para>
        </listitem>
      </itemizedlist>
    </blockquote>
  </blockquote>
  <itemizedlist>
    <listitem>
      <para>2
 </para>
    </listitem>
  </itemizedlist>
</chapter>
#
    );
}

1;

