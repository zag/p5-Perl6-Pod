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
use XML::SAX::Writer;
use XML::ExtOn('create_pipe');

sub make_doc_parser {
    my $t          = shift;
    my $out        = shift;
    my $xml_writer = new XML::SAX::Writer:: Output => $out;
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
=for item :numbered
entry 
=for item :numbered
entry2
=end pod
T1
    $t->is_deeply_xml(
        $t->parse_to_doc($pod),
        q#<chapter><orderedlist><listitem><para>entry 
</para></listitem><listitem><para>entry2
</para></listitem></orderedlist></chapter>#
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
=for item :term<TEST> 
entry 
=for item :term<TEST2> 
entry2
=end pod
T1

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

1;

