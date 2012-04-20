#===============================================================================
#
#  DESCRIPTION:  Test Perl6::To* API
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Perl6::Pod::Writer::DocBook;
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    $self;
}

sub o {
    return $_[0]->{out};
}

sub print {
    my $fh = shift->o;
    print $fh @_;
}

sub say {
    my $fh = shift->o;
    print $fh @_;
    print $fh "\n";
}
1;

package Perl6::Pod::To::DocBook;

=head1 NAME

Perl6::Pod::To::DocBook - DocBook formater 

=head1 SYNOPSIS

    my $p = new Perl6::Pod::To::DocBook:: 
                header => 0, doctype => 'chapter';


=head1 DESCRIPTION

Process pod to docbook

Sample:

        =begin pod
        =NAME Test chapter
        =para This is a test para
        =end pod

Run converter:

        pod6docbook test.pod > test.xml

Result xml:

        <?xml version="1.0"?>
        <chapter>
          <title>Test chapter
        </title>
          <para>This is a test para
        </para>
        </chapter>


=cut

use strict;
use warnings;
use Perl6::Pod::To;;
use base 'Perl6::Pod::To';

sub block_para {
    my $self = shift;
    my $el   = shift;
    foreach my $para (@{ $el->childs }) {
        $self->w->print( '<para>' . $para->content . '</para>' );
    }
}

sub block_code {
    my $self = shift;
    my $el   = shift;
    $self->w->print(
        '<programlisting><![CDATA[' . $el->content . ']]></programlisting>' );
}

sub start_write {
    my $self = shift;
    my $w    = $self->writer;
    if ( $self->{header} ) {
        $w->say(
q@<!DOCTYPE chapter PUBLIC '-//OASIS//DTD DocBook V4.2//EN' 'http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd' ></@
        );
    }
    $self->w->say( '<' . ( $self->{doctype} || 'chapter' ) . '>' );
}

sub write {
    my $self = shift;
    my $tree = shift;
    $self->visit($tree);
}

sub end_write {
    my $self = shift;
    $self->w->say( '</' . ( $self->{doctype} || 'chapter' ) . '>' );
}

1;

package main;
use strict;
use warnings;
use Test::More 'no_plan'; #tests => 1;                      # last test to print

my $text = '=begin pod

=begin para

Para

dr

=end para
=end pod
';

my $tree = Perl6::Pod::To::->new()->parse_blocks($text);
use Data::Dumper;

#die Dumper($tree);
my $str = '';
open( my $fd, ">", \$str );
my $docbook = new Perl6::Pod::To::DocBook::
  writer  => new Perl6::Pod::Writer::DocBook( out => $fd ),
  header  => 1,
  doctype => 'chapter';
$docbook->start_write;
$docbook->write($tree);
$docbook->end_write;

#diag Dumper($tree);
diag $str;
ok "1";

