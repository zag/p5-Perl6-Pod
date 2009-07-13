#===============================================================================
#
#  DESCRIPTION:  test DocBook out put
#
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================
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

sub d01_doctype : Test(1) {
    my $t = shift;
    my $buf;
    $t->make_doc_parser( \$buf )->parse( \<<T1);
=begin pod
=end pod
T1
    $t->is_deeply_xml( $buf, q!<chapter/>! );
    'empty';
}

sub d02_NAME : Test(no_plan) {
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

sub d03_Heads : Test(no_plan) {
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

sub d02_create : Test(no_plan) {
    my $t = shift;
    return "ok";
    my $buf = '';
    my ( $p, $f ) = Perl6::Pod::To::to_abstract(
        'Perl6::Pod::To::DocBook', \$buf,
        doctype => 'chapter',
        headers => 0
    );
    $p->parse( \<<T);
=begin pod
=NAME TEST
asdasd
=pod1
asdasd
=head1 test
=end pod
T

    #diag Dumper keys %$f;
    diag $buf;
}

1;

