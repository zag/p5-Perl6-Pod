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
    unless ( 
    UNIVERSAL::isa( $el, 'Perl6::Pod::Lex::Block' )
            ||
        ref ($el) eq 'HASH' ) {
        use Data::Dumper;
        die "NOT VALIDE". Dumper($el);
    }
    $dump{name}        = $el->{name}        if exists $el->{name};
    $dump{block_name}  = $el->{block_name}  if exists $el->{block_name};
    $dump{encode_name} = $el->{encode_name} if exists $el->{encode_name};
    $dump{alias_name} = $el->{alias_name} if exists $el->{alias_name};

    if ( my $attr = $el->{attr} ) {
#        my @attr_dump = map { $_->dump() } @$attr;
        my @attr_dump = map {     {
        name  => $_->{name},
        value => $_->{items}
    } } @$attr;
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

        $dump{content} = [
            map {
                    ref($_) ? $self->_dump_($_)
                  : $_ =~ /^\s+ / ? 'CODE'
                  : 'TEXT'

              } @{ $el->childs }
        ];

    }
    \%dump;
}

sub __default_method {
    my $self = shift;
    my $n    = shift;
    if (ref($n) and ( ref($n) eq 'ARRAY' ) ) {
        return [ map {$self->_dump_($_)} @{$n} ]
    }
    return $self->_dump_($n);
}

1;

package main;
use strict;
use warnings;

use Test::More tests => 10;    # last test to print
use Perl6::Pod::Utl;

use v5.10;
use Data::Dumper;

my $r = do {
    use Regexp::Grammars;
    use Perl6::Pod::Grammars;
    use Perl6::Pod::Autoactions;
    qr{
       <extends: Perl6::Pod::Grammar::Blocks>
       <matchline>
#       <debug:step>
        \A <File> \Z
    }xms;
};

my @t;
my $STOP_TREE = 1;

@t = (
'
text

=begin pod
=for Test :1
bracket sequence. For example:
=end pod
'
);
package Perl6::Pod::Lex1;
use Perl6::Pod::Lex;
use base 'Perl6::Pod::Lex';
sub make_block {
    my $self = shift;
    my %ref  = @_;
    my $name = $ref{name};
    my $is_implicit_code_and_para_blocks =
         $ref{force_implicit_code_and_para_blocks}
      || $name =~ /(pod|item|defn|nested|finish|\U $name\E )/x
      ;

    my $childs = $ref{content} || [];
    my $vmargin = length( $ref{spaces} // '' );

    #is first para if item|defn ?
    my $is_first = 1;
    #convert paragraph's to blocks
    foreach my $node (@$childs) {
        if ( $node->{type} eq 'block') {
            $node = $self->make_block(%$node);

        } elsif ($node->{type} =~  /text|raw/ ) {
            my $type = $node->{type};
            if ($type eq 'text') {
                $node =  Perl6::Pod::Lex::Text->new( %$node );
            } else {
                $node = Perl6::Pod::Lex::RawText->new ( %$node);
            }

        } else { die "Unknown". Dumper($node) };
        next
          unless UNIVERSAL::isa( $node, 'Perl6::Pod::Lex::Text' )
              || UNIVERSAL::isa( $node, 'Perl6::Pod::Lex::RawText' );
        use Perl6::Pod::Utl;
        my $content =  delete $node->{''};
        #remove virual margin
        $content = Perl6::Pod::Utl::strip_vmargin($vmargin, $content);
        #skip first text block for item| defn
        if ( $name =~ 'item|defn' and $is_first ) {

            #always ordinary text
            $content =~ s/^\s+//;
            $node = $content;
            next;

        }
        if ($is_implicit_code_and_para_blocks) {
            my $block_name = $content =~ /^\s+/ ? 'code' : 'para';
            $node = Perl6::Pod::Lex::Block->new(
                %$node,
                name    => $block_name,
                srctype => 'implicit',
                content => [$content]
            );

        }
        else {
            if ( $name eq 'para' ) {

                #para blocks always
                # ordinary text
                $content =~ s/^\s+//;
            }
            $node = $content;
        }
    }
    return Perl6::Pod::Lex::Block->new(%ref);

}
sub process_file {
    my $self = shift;
    my $ref = shift;
    #clear all ambient blocks
    if ( 1 || $self->{default_pod} ) {
        $ref->{force_implicit_code_and_para_blocks} = 1;
    } 
    my $block = $self->make_block(%$ref, name=>'File');
    return    $block->childs;
}


sub process_block {

}

sub make_tree {
    use Data::Dumper;
    my $self = shift;
    my $tree = shift;
    my $type  = $tree->{type};
    my $method = "process_" . $type;
    return $self->$method($tree);
};
1;
package main;
$STOP_TREE = 2;
$STOP_TREE = 0;

@t=();
#if ( $t[0] =~ $r ) {
#   die Dumper( Perl6::Pod::Lex1->new->make_tree($/{File}) );
#}
#die Dumper Perl6::Pod::Utl::parse_pod($t[0]);

my @grammars = (
    '=begin pod
=for item
  dd  d
sdsdsd


=end pod
',
    {
        'content' => [
            {
                'content' => [
                    {
                        'content' => ['TEXT'],
                        'name'    => 'item',
                        'class'   => 'Block'
                    }
                ],
                'name'  => 'pod',
                'class' => 'Block'
            }
        ],
        'name'  => 'File',
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
        'name'  => 'File',
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
                                'content' => ['TEXT'],
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
        'class' => 'File',
        'name'  => 'File',

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
                        'content' => ['CODE'],
                        'name'    => 'Sode',
                        'class'   => 'Block'
                    },
                    {
                        'content' => ['CODE'],
                        'name'    => 'code',
                        'class'   => 'Block'
                    },
                    {
                        'content' => ['TEXT'],
                        'name'    => 'para',
                        'class'   => 'Block'
                    }
                ],
                'name'  => 'pod',
                'class' => 'Block'
            }
        ],
        'name'  => 'File',
        'class' => 'File'
    }

    ,
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
                        'content' => ['TEXT'],
                        'name'    => 'Para',
                        'class'   => 'Block'
                    },
                    {
                        'content' => ['TEXT'],
                        'name'    => 'code',
                        'class'   => 'Block'
                    },
                    {
                        'content' => ['TEXT'],
                        'name'    => 'para',
                        'class'   => 'Block'
                    }
                ],
                'name'  => 'pod',
                'class' => 'Block'
            }
        ],
        'name'  => 'File',
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
                'content' => [
                    {
                        'content' => ['TEXT'],
                        'name'    => 'para',
                        'class'   => 'Block'
                    }
                ],
                'name'  => 'pod',
                'class' => 'Block',
                'attr'  => [
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
        'name'  => 'File',
        'class' => 'File'
    },

    'attributes',
    '=begin pod :r<test> :name{ t=>1, t2=>1}
s
=end pod
',
    {
        'content' => [
            {
                'content' => [
                    {
                        'content' => ['TEXT'],
                        'name'    => 'para',
                        'class'   => 'Block'
                    }
                ],
                'name'  => 'pod',
                'class' => 'Block',
                'attr'  => [
                    {
                        'value' => 'test',
                        'name'  => 'r'
                    },
                    {
                        'value' => {
                            't2' => '1',
                            't'  => '1'
                        },
                        'name' => 'name'
                    }
                ]
            }
        ],
        'name'  => 'File',
        'class' => 'File'
    },
    'attrs: hash',

    '=begin pod
   =begin OO
     ed
   =end OO
sdsd

 d
sdsdsds

=end pod
',
    {
        'content' => [
            {
                'content' => [
                    {
                        'content' => [
                            {
                                'content' => ['CODE'],
                                'name'    => 'code',
                                'class'   => 'Block'
                            }
                        ],
                        'name'  => 'OO',
                        'class' => 'Block'
                    },
                    {
                        'content' => ['TEXT'],
                        'name'    => 'para',
                        'class'   => 'Block'
                    },
                    {
                        'content' => ['TEXT'],
                        'name'    => 'code',
                        'class'   => 'Block'
                    }
                ],
                'name'  => 'pod',
                'class' => 'Block'
            }
        ],
        'name'  => 'File',
        'class' => 'File'
    },
    'text and verbatim blocks',
    'some parar
parapar
=begin pod
asdasd
=end pod
',
    {
        'content' => [
            {
                'content' => [
                    {
                        'content' => ['TEXT'],
                        'name'    => 'para',
                        'class'   => 'Block'
                    }
                ],
                'name'  => 'pod',
                'class' => 'Block'
            }
        ],
        'name'  => 'File',
        'class' => 'File'
    },
    'ambient text',
    '=begin pod
=begin para
=config name :like<head1>
= :t
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
                                'block_name' => 'name',

                                'name'  => 'config',
                                'class' => 'Block',
                                'attr'  => [
                                    {
                                        'value' => 'head1',
                                        'name'  => 'like'
                                    },
                                    {
                                        'value' => 1,
                                        'name'  => 't'
                                    }
                                ]
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
        'name'  => 'File',
        'class' => 'File'
    },
    '=config directive',
    '=begin pod
=encoding Macintosh
=encoding KOI8-R
=end pod
',
    {
        'content' => [
            {
                'content' => [
                    {
                        'encode_name' => 'Macintosh',
                        'name'        => 'encoding',
                        'class'       => 'Block'
                    },
                    {
                        'encode_name' => 'KOI8-R',
                        'name'        => 'encoding',
                        'class'       => 'Block'
                    }
                ],
                'name'  => 'pod',
                'class' => 'Block'
            }
        ],
        'name'  => 'File',
        'class' => 'File'
    },
    '=encoding directive',
'=begin pod
=alias PROGNAME    Earl Irradiatem Eventually
=                  =item  Also text
=end pod
',{
          'content' => [
                         {
                           'content' => [
                                          {
                                            'alias_name' => 'PROGNAME',
                                            'name' => 'alias',
                                            'class' => 'Block'
                                          }
                                        ],
                           'name' => 'pod',
                           'class' => 'Block'
                         }
                       ],
          'name' => 'File',
          'class' => 'File'
        }, '=alias directive'


);

@grammars = @t if scalar(@t);
while ( my ( $src, $extree, $name ) = splice( @grammars, 0, 3 ) ) {
    $name //= $src;
    my $dump;
#    if ( $src =~ $r->with_actions( Perl6::Pod::Autoactions->new ) ) {
    if ( $src =~ $r ) {
        my $tree = Perl6::Pod::Lex1->new->make_tree($/{File});
        if ( $STOP_TREE == 2 ) { say Dumper( {%/}->{File} ); exit; }
         $dump = Perl6::Pod::To::Dump->new->visit( $tree );
#        $dump = Perl6::Pod::To::Dump->new->visit( {%/}->{File} );

        #    if ( my $tree = Perl6::Pod::Utl::parse_pod($src) ) {
        #        if ( $STOP_TREE == 2 ) { say Dumper($tree ); exit; }
        #        $dump = Perl6::Pod::To::Dump->new->visit( $tree );

    }
    else {
        fail($name);
        die "Can't parse: \n" . $src;

    }
    if ( $STOP_TREE == 1 ) { say Dumper($dump); exit; }

    is_deeply( $dump, $extree, $name )
      || do { say "fail deeply" . Dumper( $dump, $extree, ); exit; };

}

#check not ambient
@grammars = (
    'para texxt
=begin pod
text
=end pod

 codesd
',
    {
        'content' => [
            {
                'content' => ['TEXT'],
                'name'    => 'para',
                'class'   => 'Block'
            },
            {
                'content' => [
                    {
                        'content' => ['TEXT'],
                        'name'    => 'para',
                        'class'   => 'Block'
                    }
                ],
                'name'  => 'pod',
                'class' => 'Block'
            },
            {
                'content' => ['TEXT'],
                'name'    => 'code',
                'class'   => 'Block'
            }
        ],
        'name'  => 'File',
        'class' => 'File'
    },
    'check default pod content'

);

while ( my ( $src, $extree, $name ) = splice( @grammars, 0, 3 ) ) {
    $name //= $src;
    my $dump;
    if ( $src =~
        $r->with_actions( Perl6::Pod::Autoactions->new( default_pod => 1 ) ) )
    {
        if ( $STOP_TREE == 2 ) { say Dumper( {%/}->{File} ); exit; }
        $dump = Perl6::Pod::To::Dump->new->visit( {%/}->{File} );

    #    if ( my $tree = Perl6::Pod::Utl::parse_pod($src, default_pod => 1 ) ) {
    #        if ( $STOP_TREE == 2 ) { say Dumper($tree ); exit; }
    #        $dump = Perl6::Pod::To::Dump->new->visit( $tree );

    }
    else {
        fail($name);
        die "Can't parse: \n" . $src;

    }
    if ( $STOP_TREE == 1 ) { say Dumper($dump); exit; }

    is_deeply( $dump, $extree, $name )
      || do { say "fail deeply" . Dumper( $dump, $extree, ); exit; };

}

exit;
