#===============================================================================
#
#  DESCRIPTION:  Test format codes
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
package Perl6::Pod::Codeactions;
use Perl6::Pod::Lex::FormattingCode;
use strict;
use warnings;
use Data::Dumper;
use Carp;

sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    $self;
}

sub tidy_format_codes_content {
    my @res = ();
    my $tmp = '';
    foreach my $c (@_) {
        if (ref($c)) {
            if ( $tmp )
            {
                push @res, $tmp;
                $tmp = '';
            }
            push @res, $c;

          } else {
            $tmp .= $c;
        }
    }
    push @res, $tmp if $tmp;
    @res;

}

sub Text {
    my $self = shift;
    my $rec  = shift;
    if ( my $content = $rec->{content} ) {
        $rec->{content} = [ tidy_format_codes_content(@$content) ];
    }
    return $rec->{content}
}

sub C_code {
    my $self = shift;
    my $rec  = shift;
    return Perl6::Pod::Lex::FormattingCode->new($rec);
}

sub default_formatting_code {
    my $self = shift;
    my $rec  = shift;
    if ( my $content = $rec->{content} ) {
        $rec->{content} = [ tidy_format_codes_content(@$content) ];
    }
    return Perl6::Pod::Lex::FormattingCode->new($rec);
}


package main;
use strict;
use warnings;
use Data::Dumper;
use v5.10;
use Regexp::Grammars;
use Perl6::Pod::Grammars;
use Test::More tests => 1;    # last test to print
my %delim = ( '<' => '>', '«' => '»', '<<' => '>>' );
my %allow = ( '*' => 1 );
my $r     = qr{

       <extends: Perl6::Pod::Grammar::FormattingCodes>
       <matchline>
#      <debug:step>
       \A  <Text>  \Z
    <rule: Text> <[content]>+
    <rule: text>  .+?
    <rule: content> <MATCH=C_code>| <MATCH=default_formatting_code> | <.text>
    <rule: ldelim> <%delim>
    <rule: rdelim> (??{ quotemeta $delim{$ARG{ldelim}} })
    <rule: isValideFCode>
            <require: (?{ 
            ( $ARG{name} eq  uc($ARG{name} ) ) 
                        &&
            ( exists $allow{'*'} ||  exists $allow{$ARG{name}} )
            
            })>
    <rule: C_code>
       <name=([C])><isValideFCode(:name)>
            <ldelim>     <content=( .*? )>   <rdelim(:ldelim)>
    <token: default_formatting_code> 
      <name=(\w)><isValideFCode(:name)>
            <ldelim>  <[content]>*?   <rdelim(:ldelim)>
}xms;

my @t;
my $STOP_TREE = 2;

@t = ( ' sd C<<<s B<s>>ss» sB<d>' );
my @grammars;

#@t         = ();

@grammars = @t if scalar(@t);
while ( my ( $src, $extree, $name ) = splice( @grammars, 0, 3 ) ) {
    $name //= $src;
    my $dump;
    use Perl6::Pod::Autoactions;
    if ( $src =~ $r->with_actions( Perl6::Pod::Codeactions->new ) ) {

        #    if ( $src =~ $r ) {
        if ( $STOP_TREE == 2 ) { say Dumper( {%/}->{Text} ); exit; }

        #        $dump = Perl6::Pod::To::Dump->new->visit( {%/}->{File} );
    }
    else {
        fail($name);
        die "Can't parse: \n" . $src;

    }
    if ( $STOP_TREE == 1 ) { say Dumper($dump); exit; }

    is_deeply( $dump, $extree, $name )
      || do { say "fail Deeeple" . Dumper( $dump, $extree, ); exit; };

}

