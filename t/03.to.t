#===============================================================================
#
#  DESCRIPTION:  Test Perl6::To* API
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$

package Perl6::Pod::To;
use strict;
use warnings;
use Carp;
use Perl6::Pod::Autoactions;
use Perl6::Pod::Utl::AbstractVisiter;
use base 'Perl6::Pod::Utl::AbstractVisiter';

=pod
        use     => 'Perl6::Pod::Directive::use',
        config  => 'Perl6::Pod::Directive::config',
        comment => 'Perl6::Pod::Block::comment',
        alias   => 'Perl6::Pod::Directive::alias',
        code    => 'Perl6::Pod::Block::code',
        pod     => 'Perl6::Pod::Block::pod',
        para    => 'Perl6::Pod::Block::para',
        table   => 'Perl6::Pod::Block::table',
        output  => 'Perl6::Pod::Block::output',
        input   => 'Perl6::Pod::Block::input',
        nested  => 'Perl6::Pod::Block::nested',
        item    => 'Perl6::Pod::Block::item',
        defn    => 'Perl6::Pod::Block::item',
        '_NOTES_'   => 'Perl6::Pod::Parser::NOTES',
        'C<>'   => 'Perl6::Pod::FormattingCode::C',
        'D<>'   => 'Perl6::Pod::FormattingCode::D',
        'K<>'   => 'Perl6::Pod::FormattingCode::K',
        'M<>'   => 'Perl6::Pod::FormattingCode::M',
        'L<>'   => 'Perl6::Pod::FormattingCode::L',
        'B<>'   => 'Perl6::Pod::FormattingCode::B',
        'I<>'   => 'Perl6::Pod::FormattingCode::I',
        'X<>'   => 'Perl6::Pod::FormattingCode::X',

        #        'P<>'   => 'Perl6::Pod::FormattingCode::P',
        'U<>' => 'Perl6::Pod::FormattingCode::U',
        'E<>' => 'Perl6::Pod::FormattingCode::E',
        'N<>' => 'Perl6::Pod::FormattingCode::N',
        'A<>' => 'Perl6::Pod::FormattingCode::A',
        'R<>' => 'Perl6::Pod::FormattingCode::R',
        'S<>' => 'Perl6::Pod::FormattingCode::S',
        'T<>' => 'Perl6::Pod::FormattingCode::T',
        'V<>' => 'Perl6::Pod::FormattingCode::C', #V like C
        'Z<>' => 'Perl6::Pod::FormattingCode::Z',
=cut

use constant {
    DEFAULT_USE => {
        'File' => '-',
        'para' => 'Perl6::Pod::Block::para',
        '*'    => 'Perl6::Pod::Block',
        '*<>'  => 'Perl6::Pod::FormattingCode',
    }
};

sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    # check if exists context
    # create them instead
    unless ( $self->context ) {
        use Perl6::Pod::Utl::Context;
        $self->context( new Perl6::Pod::Utl::Context:: )
    }
    $self;
}

sub writer {
    return $_[0]->{writer};
}

sub w {
    return $_[0]->writer;
}

sub context {
    my $self = shift;
    if ($#_ > 0) {
        $self->{context} = shift;
    }
    return $self->{context}
}
#TODO then visit to child -> create new context !
sub visit_childs {
    my $self = shift;
    foreach my $n (@_) {
        die "Unknow type $n (not isa Perl6::Pod::Block)"
          unless UNIVERSAL::isa( $n, 'Perl6::Pod::Block' )
              || UNIVERSAL::isa( $n, 'Perl6::Pod::Lex::Block' );
        foreach my $ch ( @{ $n->childs } ) {
            $self->visit($ch);
        }
    }
}

sub visit {
    my $self = shift;
    my $n    = shift;

    if ( ref($n) eq 'ARRAY' ) {
        $self->visit($_) for @$n;
        return;
    }

    # if string -> paragraph
    unless ( ref($n) ) { return $self->ordinary_characters($n) }

    die "Unknown node type $n (not isa Perl6::Pod::Lex::Block)"
      unless UNIVERSAL::isa( $n, 'Perl6::Pod::Lex::Block' );

    # here convert lexer base block to
    # instance of DOM class
    my $name = $n->name;
    my $map  = DEFAULT_USE;
    my $class;

    #convert lexer blocks
    unless ( UNIVERSAL::isa( $n, 'Perl6::Pod::Block' ) ) {

        my %additional_attr = ();
        if ( UNIVERSAL::isa( $n, 'Perl6::Pod::Lex::FormattingCode' ) ) {
            $class = $map->{ $name . '<>' } || $map->{'*<>'};
        }

        # UNIVERSAL::isa( $n, 'Perl6::Pod::Lex::Block' )
        else {

            # convert item1, head1 -> item, head
            if ( $name =~ /(item|head)(\d+)/ ) {
                $name = $1;
                $additional_attr{level} = $2;
            }
            elsif ( $name =~ /(para|code)/ ) {

                # add { name=>$name }
                # for text and code blocks
                $additional_attr{name} = $name;
            }

            $class = $map->{$name} || $map->{'*'};
        }

        #create instance
        my $el =
            $class eq '-'
          ? $n
          : $class->new( %$n, %additional_attr, context => $self->context );

        #if no instanse -> skip this element
        return undef unless ($el);
        $n = $el;
    }
    my $method = $self->__get_method_name($n);

    #make method name
    $self->$method($n);
}

sub __get_method_name {
    my $self = shift;
    my $el = shift || croak "empty object !";
    my $method;
    use Data::Dumper;
    my $name = $el->name || die "Can't get element name for " . Dumper($el);
    if ( UNIVERSAL::isa( $el, 'Perl6::Pod::FormattingCode' ) ) {
        $method = "code_$name";
    }
    else {
        $method = "block_$name";
    }
    return $method;
}

sub block_File {
    my $self = shift;
    return $self->visit_childs(@_);
}

sub block_pod {
    my $self = shift;
    return $self->visit_childs(@_);
}

sub parse_blocks {
    my $self = shift;
    my $text = shift;
    my $r    = do {
        use Regexp::Grammars;
        use Perl6::Pod::Grammars;
        qr{
       <extends: Perl6::Pod::Grammar::Blocks>
       <matchline>
        \A <File> \Z
    }xms;
    };
    if ( $text =~ $r->with_actions( Perl6::Pod::Autoactions->new ) ) {
        return {%/}->{File};
    }
    else {

        #    die "Can't parse";
        undef;
    }
}

sub __default_method {
    my $self   = shift;
    my $n      = shift;
    my $method = $self->__get_method_name($n);
    die ref($self)
      . ": Method '$method' for class "
      . ref($n)
      . " not implemented at ";
}

1;

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
use base 'Perl6::Pod::To';

sub block_para {
    my $self = shift;
    my $el   = shift;
    $self->w->print( '<para>' . $el->content . '</para>' );
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

