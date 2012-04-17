#===============================================================================
#
#  DESCRIPTION: Make Syntax tree 
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
package Perl6::Pod::Lex::Block;
use base 'Perl6::Pod::Block';
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    $self;
}

sub content {
    my $self = shift;
    $self->{''};
}

sub childs {
    my $self = shift;
    $self->{content};
}

sub name {
    my $self = shift;
    return $self->{name}
}

1;

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
sub name { 'File'}
1;

package Perl6::Pod::Lex::RawText;
use base 'Perl6::Pod::Lex::Block';
use strict;
use warnings;

sub new {
    my $class = shift;
#    if ( ( $#_ == 0 ) ) {
#        use Data::Dumper;
#        warn Dumper(\@_);; 
#       warn Dumper ([ map {[caller($_)]} (0..3)]);
#        unless (ref($_[0])) {
#        $_[0] = {''=>$_[0]}
#        }
#    }
    my $self =
      bless( ( $#_ == 0 ) ? { '' => shift } : {@_},
#      bless( ( $#_ == 0 ) ? shift : {@_},
        ref($class) || $class );
    $self;
}

sub name { 'code'}

sub childs {
    return undef;
}


1;

package Perl6::Pod::Lex::Text;
use base 'Perl6::Pod::Lex::RawText';
use strict;
use warnings;
sub name { 'para'}
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

sub File {
    my $self = shift;
    my $ref  = shift;
    return Perl6::Pod::Lex::File->new(%$ref);
}

#with non raw content
sub delimblock {
    my $self = shift;
    my $ref  = shift;
    # check VMARGIN and convert 
    # Text content to verbatim
    my $vmargin = length($ref->{spaces} //'');
    if ( my $childs = $ref->{content}) {
     foreach my $node (@$childs)  {
      next unless UNIVERSAL::isa($node, 'Perl6::Pod::Lex::Text');
      #check if margin text > vmargin of parent block
      my $node_margin =  length( $node->{spaces} // '');
      # when it raw block
       if ( $node_margin > $vmargin ) {
         #this is a code block !
         $node = $self->raw_content( %$node );
       }
      }
     }
    return Perl6::Pod::Lex::Block->new( %$ref, srctype => 'delim' );
}

sub delimblock_raw {
    my $self = shift;
    my $ref  = shift;
    return Perl6::Pod::Lex::Block->new( %$ref, srctype => 'delimraw' );
}

sub paragraph_block {
    my $self = shift;
    my $ref  = shift;
    return Perl6::Pod::Lex::Block->new( %$ref, srctype => 'paragraph' );
}

sub abbr_block {
    my $self = shift;
    my $ref  = shift;
    return Perl6::Pod::Lex::Block->new( %$ref, srctype => 'abbr' );
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
    if ($type && ( $type eq 'hash' )) {
        my %hash = ();
        foreach my $item (@{ $ref->{items}} ) {
            $hash{$item->{key}} = $item->{value}
        }
        $ref->{items} = \%hash
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


