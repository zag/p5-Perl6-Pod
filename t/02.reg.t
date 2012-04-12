#########################
# Test pod blocks
#
package Perl6::Pod6::To::Dump;
use base 'Perl6::Pod::Utl::AbstractVisiter';
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    $self;
}

sub _dump_ {
    my $self = shift;
    my $el   = shift;
    ( my $type = ref($el) ) =~ s/.*:://;
    my %dump = ( class => $type );
    $dump{name} = $el->{name} if exists $el->{name};
    unless ( UNIVERSAL::can( $el, 'content' ) ) {
        use Data::Dumper;
        die 'bad element: ' . Dumper($el);
    }
    if ( my $content = $el->content ) {
        warn Dumper($el) unless ref($content) eq 'ARRAY';
#        warn "CONENET".Dumper ($el->content );
        $dump{content} = [ map { $self->_dump_($_) } @{ $el->content } ];
    }
    \%dump;
}

sub __default_method {
    my $self = shift;
    my $n    = shift;
    return $self->_dump_($n);

#    my $method = ref($n);
#    $method =~ s/.*:://;
#    die ref($self) . ": Method '$method' for class " . ref($n) . " not implemented at ";
}

1;

package Perl6::Pod6::Block;
use strict;
use warnings;
use Data::Dumper;

sub new {

    #    warn Dumper(\@_);
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    $self;
}

sub content {
    my $self = shift;
#    if ( my $cnt = $self->{content} ) {
#      if (ref($cnt) eq 'ARRAY') {
#        my @ref = grep {ref($_)} @$cnt;
#        return scalar(@ref) ? @ref : undef
#      }
#    }
    $self->{content};
}

1;

package Perl6::Pod6::File;
use base 'Perl6::Pod6::Block';
use strict;
use warnings;
1;


package Perl6::Pod6::RawText;
use base 'Perl6::Pod6::Block';
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self =
      bless( ( $#_ == 0 ) ? { content => shift } : {@_},
        ref($class) || $class );
    $self;
}

sub content {
    return undef;
}
1;

package Perl6::Pod6::Text;
use base 'Perl6::Pod6::RawText';
use strict;
use warnings;
1;

package Perl6::Pod6::Autoactions;
use strict;
use warnings;
use Data::Dumper;
use vars qw($AUTOLOAD);

sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    $self;
}

sub File {
    my $self = shift;
    my $ref  = shift;
    return Perl6::Pod6::File->new(%$ref);
}

sub delimblock {
    my $self = shift;
    my $ref  = shift;
    return Perl6::Pod6::Block->new( %$ref, srctype => 'delim' );
}


sub delimblock_raw {
    my $self = shift;
    my $ref  = shift;
    return Perl6::Pod6::Block->new( %$ref, srctype => 'delimraw' );
}

sub paragraph_block {
    my $self = shift;
    my $ref  = shift;
    return Perl6::Pod6::Block->new( %$ref, srctype => 'paragraph' );
}

sub abbr_block {
    my $self = shift;
    my $ref  = shift;
    return Perl6::Pod6::Block->new( %$ref, srctype => 'abbr' );
}
sub text_content {
    my ( $self, $ref ) = @_;
   #     die Dumper $ref;
    #    return undef;
    if ( my $type = $ref->{type} ) {
       return $self->raw_content($ref) if  $type eq 'raw'
    }        
    return Perl6::Pod6::Text->new($ref)
}

sub raw_content {
    my ( $self, $ref ) = @_;

    #        die Dumper $ref;
    #        return undef;
    return Perl6::Pod6::RawText->new($ref);
}
sub AAUTOLOAD {
    my $self = shift;
    my $method = $AUTOLOAD;
#    $method =~ s/.*:://;
    return if $method eq 'DESTROY';
    warn $method . Dumper(\@_);
    return $_[0];
}
1;

package main;
use strict;
use warnings;

use Test::More tests => 1;    # last test to print
use Regexp::Grammars;
use Perl6::Pod::Grammars;
use v5.10;

use Data::Dumper;

#use_ok('Perl6::Pod::Grammars');

my $ref = <<TXT;
=begin pod
=end pod
TXT

#    <rule: block_content> <block=text_content>
#    <rule: text_content> (?{ $MATCH{type} = "text"}) <[line=([^\n]+)]>+ %  <.newline>

my $IN_POD          = 0;
my $CURRENT_VMARGIN = 0;
my $r               = qr{
       <extends: Perl6::Pod::Grammars::Blocks>
       <matchline>
#        <debug:step>

        \A <File> \Z
    <token: hs>[ \t]*
    <token: hs1>[ \t]
    <token: hsp>[ \t]+
    <token: newline> <.hs1>* \n
    <token: emptyline> <.hs1>* \n

    <rule: File><[content=block_content]>+
    <rule: directives> begin | for | END | end | config
    <rule: raw_content_blocks> 
               code 
            #io blocks
            | input 
            | output
            | comment
            | table
            # User Defined Blocks
           |  <MATCH=(\w++)>  <require: (?{ $MATCH eq ucfirst ($MATCH) })>
    <rule: raw_content> 
                        .*?
    <rule: block_content> 
         <MATCH=paragraph_block>
        | <MATCH=delimblock_raw>
        | <MATCH=delimblock> 
        | <MATCH=abbr_block>
        | <MATCH=text_content> 
    <rule: text_content> 
          ( (?! <hs>? \=\w+ ) # not start with directive
            <line=([^\n]+)>  \n 
           (?{ $MATCH{type} = $ARG{content_type} // "text"}) )+

    <rule: varbatim_content>
    <rule: pair> \:<name=(\w+)>
    <rule: pod_block> =begin pod
                      =end pod

    <token: delimblock_raw>             <matchpos><matchline>
    ^ <spaces=hs>? =begin <.hs> <!directives> <name=raw_content_blocks>
     ( ( <.newline>  = )? <.hs>  <[attr=pair]>+ % <.hs> )* <.newline>

            <[content=raw_content]>?

     ^ <spacesend=hs>?  =end <.hsp> <\name> <.hs> <.newline>

    <token: delimblock>                 <matchpos><matchline>
    ^ <spaces=hsp>? =begin <.hs> <!directives>  <name=(\w+)>
     ( ( <.newline>  = )? <.hs>  <[attr=pair]>+ % <.hs> )* <.newline>
                   <[content=block_content]>*
     ^ <spacesend=hs>?  =end <.hs> <\name> <.hs> <.newline>

    <token: paragraph_block>             <matchpos><matchline>
    ^ <spaces=hsp>? =for <.hs> <!directives>   
            (  <name=raw_content_blocks>
               (?{ $MATCH{content_type} = "raw"})
              | <name=(\w+)>  )
     ( ( <.newline>  = )? <.hs>  <[attr=pair]>+ % <.hs> )* <.newline>
                    <[content=text_content(:content_type)]>*
      <.newline>?

     <token: abbr_block>                 <matchpos><matchline>
    ^ <spaces=hsp>? =<!directives> (  <name=raw_content_blocks>
               (?{ $MATCH{content_type} = "raw"})
              | <name=(\w+)>  )
                    <[content=text_content(:content_type)]>*
         <.emptyline>?
    }xms;


my @t;
my $STOP_TREE = 1;

@t = (
'=begin pod
=code
asdasd
=para
asd

e
=end pod
'
);

my @t2 = ();
$STOP_TREE = 2;
#$STOP_TREE = 1;

my @grammars = (
    '=begin pod
d
=end pod
',
    {
        'content' => [
            {
                'content' => [ { 'class' => 'Text' } ],
                'name'    => 'pod',
                'class'   => 'Block'
            }
        ],
        'class' => 'File'
    },
    '=pod + text',

    '=begin pod
=begin para
=end para
=end pod
',
    {
        'content' => [
            {
                'content' => [
                    {
                        'name'    => 'para',
                        'class'   => 'Block'
                    }
                ],
                'name'  => 'pod',
                'class' => 'Block'
            }
        ],
        'class' => 'File'
    },
    'para insite =pod',

    '=begin pod
=begin para
=begin para
text
=end para
=end para
=end pod
',
    {
        'content' => [
            {
                'content' => [
                    {
                        'content' => [
                            {
                                'content' => [ { 'class' => 'Text' } ],
                                'name'    => 'para',
                                'class'   => 'Block'
                            }
                        ],
                        'name'  => 'para',
                        'class' => 'Block'
                    }
                ],
                'name'  => 'pod',
                'class' => 'Block'
            }
        ],
        'class' => 'File'
    },
    'para inside para',

    '=begin pod
        =begin Sode
                asd
        =end Sode
    =begin code
      asd
    =end code

asdasd
=end pod
',
 {
          'content' => [
                         {
                           'content' => [
                                          {
                                            'content' => [
                                                           {
                                                             'class' => 'RawText'
                                                           }
                                                         ],
                                            'name' => 'Sode',
                                            'class' => 'Block'
                                          },
                                          {
                                            'content' => [
                                                           {
                                                             'class' => 'RawText'
                                                           }
                                                         ],
                                            'name' => 'code',
                                            'class' => 'Block'
                                          },
                                          {
                                            'class' => 'Text'
                                          }
                                        ],
                           'name' => 'pod',
                           'class' => 'Block'
                         }
                       ],
          'class' => 'File'
        }, 'raw content',
'=begin pod
=for Para
asd
   =for code
   sd
=for para
re
=end pod
',
{
          'content' => [
                         {
                           'content' => [
                                          {
                                            'content' => [
                                                           {
                                                             'class' => 'RawText'
                                                           }
                                                         ],
                                            'name' => 'Para',
                                            'class' => 'Block'
                                          },
                                          {
                                            'content' => [
                                                           {
                                                             'class' => 'RawText'
                                                           }
                                                         ],
                                            'name' => 'code',
                                            'class' => 'Block'
                                          },
                                          {
                                            'content' => [
                                                           {
                                                             'class' => 'Text'
                                                           }
                                                         ],
                                            'name' => 'para',
                                            'class' => 'Block'
                                          }
                                        ],
                           'name' => 'pod',
                           'class' => 'Block'
                         }
                       ],
          'class' => 'File'
        }, 'paragraph_block (with text and raw)',

);

@grammars = @t if scalar(@t);
while ( my ( $src, $extree, $name ) = splice( @grammars, 0, 3 ) ) {
    $name //= $src;
    my $dump;
    if ( $src =~ $r->with_actions( Perl6::Pod6::Autoactions->new ) ) {
        if ( $STOP_TREE == 2 ) { say Dumper( {%/}->{File} ); exit; }
        $dump = Perl6::Pod6::To::Dump->new->visit( {%/}->{File} );
    }
    else {
        fail($name);
        die "Can't parse: \n" . $src;

    }

    #       say Dumper $dump;
    #       say Dumper  {%/}->{File}
    if ( $STOP_TREE == 1 ) { say Dumper($dump); exit; }

    is_deeply( $dump, $extree, $name )
      || do { say "fail Deeeple" . Dumper( $dump, $extree, ); exit; };

}

exit;
