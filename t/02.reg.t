#########################
# Test pod blocks
#
package Perl6::Pod::To::Dump;
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
    if ( my $attr = $el->{attr} ) {
        my @attr_dump = map { $_->dump() } @$attr;
        if (@attr_dump) {
            $dump{attr} = \@attr_dump;
        }
    }
    unless ( UNIVERSAL::can( $el, 'childs' ) ) {
        use Data::Dumper;
        die 'bad element: ' . Dumper($el);
    }
    if ( my $content = $el->childs ) {
        warn Dumper($el) unless ref($content) eq 'ARRAY';
        $dump{content} = [ map { $self->_dump_($_) } @{ $el->childs } ];
    }
    \%dump;
}

sub __default_method {
    my $self = shift;
    my $n    = shift;
    return $self->_dump_($n);
}

1;


package main;
use strict;
use warnings;

use Test::More tests => 8;    # last test to print
use Regexp::Grammars;
use Perl6::Pod::Grammars;
use Perl6::Pod::Autoactions;
use v5.10;

use Data::Dumper;

my $r               = qr{
       <extends: Perl6::Pod::Grammar::Blocks>
       <matchline>
    #   <debug:step>
        \A <File> \Z
    }xms;

my @t;
my $STOP_TREE = 1;

@t = (
'=begin pod
=para
 asd asd
=end pod
'
);

@t         = ();
$STOP_TREE = 2;

$STOP_TREE = 0;

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
                        'content' => [ { 'class' => 'RawText' } ],
                        'name'    => 'Sode',
                        'class'   => 'Block'
                    },
                    {
                        'content' => [ { 'class' => 'RawText' } ],
                        'name'    => 'code',
                        'class'   => 'Block'
                    },
                    { 'class' => 'Text' }
                ],
                'name'  => 'pod',
                'class' => 'Block'
            }
        ],
        'class' => 'File'
    },
    'raw content',
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
                        'content' => [ { 'class' => 'RawText' } ],
                        'name'    => 'Para',
                        'class'   => 'Block'
                    },
                    {
                        'content' => [ { 'class' => 'RawText' } ],
                        'name'    => 'code',
                        'class'   => 'Block'
                    },
                    {
                        'content' => [ { 'class' => 'Text' } ],
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
    'paragraph_block (with text and raw)',

    '=begin pod  :test
= :t :r[1,2, "r"] :s<1 2 3322>
= :!t
d
=end pod
',
    {
        'content' => [
            {
                'content' => [ { 'class' => 'Text' } ],
                'name'    => 'pod',
                'class'   => 'Block',
                'attr'    => [
                    {
                        'value' => 1,
                        'name'  => 'test'
                    },
                    {
                        'value' => 1,
                        'name'  => 't'
                    },
                    {
                        'value' => [ '1', '2', 'r' ],
                        'name'  => 'r'
                    },
                    {
                        'value' => [ '1', '2', '3322' ],
                        'name'  => 's'
                    },
                    {
                        'value' => 0,
                        'name'  => 't'
                    }
                ]
            }
        ],
        'class' => 'File'
    },
    'attributes',
'=begin pod :r<test> :name{ t=>1, t2=>1}
s
=end pod
', {
          'content' => [
                         {
                           'content' => [
                                          {
                                            'class' => 'Text'
                                          }
                                        ],
                           'name' => 'pod',
                           'class' => 'Block',
                           'attr' => [
                                       {
                                         'value' => 'test',
                                         'name' => 'r'
                                       },
                                       {
                                         'value' => {
                                                      't2' => '1',
                                                      't' => '1'
                                                    },
                                         'name' => 'name'
                                       }
                                     ]
                         }
                       ],
          'class' => 'File'
        }, 'attrs: hash',

'=begin pod
   =begin OO
     ed
   =end OO
sdsd

 d
sdsdsds

=end pod
',{
          'content' => [
                         {
                           'content' => [
                                          {
                                            'content' => [
                                                           {
                                                             'class' => 'RawText'
                                                           }
                                                         ],
                                            'name' => 'OO',
                                            'class' => 'Block'
                                          },
                                          {
                                            'class' => 'Text'
                                          },
                                          {
                                            'class' => 'RawText'
                                          }
                                        ],
                           'name' => 'pod',
                           'class' => 'Block'
                         }
                       ],
          'class' => 'File'
        }, 'text and verbatim blocks',


);

@grammars = @t if scalar(@t);
while ( my ( $src, $extree, $name ) = splice( @grammars, 0, 3 ) ) {
    $name //= $src;
    my $dump;
    if ( $src =~ $r->with_actions( Perl6::Pod::Autoactions->new ) ) {
        if ( $STOP_TREE == 2 ) { say Dumper( {%/}->{File} ); exit; }
        $dump = Perl6::Pod::To::Dump->new->visit( {%/}->{File} );
    }
    else {
        fail($name);
        die "Can't parse: \n" . $src;

    }
    if ( $STOP_TREE == 1 ) { say Dumper($dump); exit; }

    is_deeply( $dump, $extree, $name )
      || do { say "fail Deeeple" . Dumper( $dump, $extree, ); exit; };

}

exit;
