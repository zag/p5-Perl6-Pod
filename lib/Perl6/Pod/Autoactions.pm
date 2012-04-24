#===============================================================================
#
#  DESCRIPTION: Make Syntax tree
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================

package Perl6::Pod::Lex::Attr;
use base 'Perl6::Pod::Lex::Block';
use strict;
use warnings;

sub dump {
    my $self = shift;
    {
        name  => $self->name,
        value => $self->{items}
    };
}
1;

package Perl6::Pod::Lex::File;
use base 'Perl6::Pod::Lex::Block';
use strict;
use warnings;
sub name { 'File' }
1;

package Perl6::Pod::Lex::RawText;
use base 'Perl6::Pod::Lex::Block';
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    $self;
}

sub name { 'code' }

sub childs {
    return undef;
}

1;

package Perl6::Pod::Lex::Text;
use base 'Perl6::Pod::Lex::RawText';
use strict;
use warnings;
sub name { 'para' }
1;

package Perl6::Pod::Autoactions;
use strict;
use warnings;
use Data::Dumper;
use vars qw($AUTOLOAD);

sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    $self;
}

sub source {
    return $_[0]->{source} || 'UNKNOWN';
}

sub File {
    my $self = shift;
    my $ref  = shift;

    #clear all ambient blocks
    if ( $self->{default_pod} ) {
        $ref->{force_implicit_code_and_para_blocks} = 1;
    }
    else {

        #clear all block instead =pod
        my @res = ();
        foreach my $node ( @{ $ref->{'content'} } ) {
            push @res, $node
              if ( ref($node)
                && UNIVERSAL::isa( $node, 'Perl6::Pod::Lex::Block' )
                && ( $node->name && ( $node->name eq 'pod' ) ) );
        }
        $ref->{'content'} = \@res;
    }
    return Perl6::Pod::Lex::File->new(
        %{ $self->make_block( %$ref, name => 'File' ) } );

}

#convert content of blocks
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
        next
          unless UNIVERSAL::isa( $node, 'Perl6::Pod::Lex::Text' )
              || UNIVERSAL::isa( $node, 'Perl6::Pod::Lex::RawText' );

        #remove virual margin;
        my $content = delete $node->{''};
        my $node_margin = length( $node->{spaces} // '' );

        #get min margin of text
        my $min = $vmargin;
        foreach ( split( /[\n\r]/, $content ) ) {
            if (m/(\s+)/) {
                my $length = length($1);
                $min = $length if $length < $min;
            }
        }

        #remove only if $min > 0
        if ( $min > 0 ) {
            my $new_content = '';
            foreach ( split( /[\n\r]/, $content ) ) {
                $new_content .= substr( $_, $min ) . "\n";
            }
            $content = $new_content;
        }

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

#with non raw content
sub delimblock {
    my $self = shift;
    my $ref  = shift;
    return $self->make_block( %$ref, srctype => 'delim' );
}

sub delimblock_raw {
    my $self = shift;
    my $ref  = shift;
    return $self->make_block( %$ref, srctype => 'delimraw' );
}

sub paragraph_block {
    my $self = shift;
    my $ref  = shift;
    return $self->make_block( %$ref, srctype => 'paragraph' );
}

sub abbr_block {
    my $self = shift;
    my $ref  = shift;
    return $self->make_block( %$ref, srctype => 'abbr' );
}

sub text_content {
    my ( $self, $ref ) = @_;

    if ( my $type = $ref->{type} ) {
        return $self->raw_content(%$ref) if $type eq 'raw';
    }
    return Perl6::Pod::Lex::Text->new(%$ref);
}

sub text_abbr_content {
    my ( $self, $ref ) = @_;
    if ( my $type = $ref->{type} ) {
        return $self->raw_content(%$ref) if $type eq 'raw';
    }
    return Perl6::Pod::Lex::Text->new(%$ref);
}

sub raw_content {
    my $self = shift;
    return Perl6::Pod::Lex::RawText->new(@_);

}

sub pair {
    my ( $self, $ref ) = @_;

    #convert hashes from array
    my $type = $ref->{type};
    if ( $type && ( $type eq 'hash' ) ) {
        my %hash = ();
        foreach my $item ( @{ $ref->{items} } ) {
            $hash{ $item->{key} } = $item->{value};
        }
        $ref->{items} = \%hash;
    }
    return Perl6::Pod::Lex::Attr->new($ref);
}

sub AAUTOLOAD {
    my $self   = shift;
    my $method = $AUTOLOAD;

    #    $method =~ s/.*:://;
    return if $method eq 'DESTROY';
    warn $method . Dumper( \@_ );
    return $_[0];
}
1;

