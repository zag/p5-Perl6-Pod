#===============================================================================
#
#  DESCRIPTION:  Test format codes
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================


package main;
use strict;
use warnings;
use Data::Dumper;
use v5.10;
use Regexp::Grammars;
use  Perl6::Pod::Codeactions;
use Perl6::Pod::Grammars;
use Test::More tests => 1;    # last test to print
my %delim = ( '<' => '>', '«' => '»', '<<' => '>>' );
my %allow = ( '*' => 1 );
my $r     = qr{

       <extends: Perl6::Pod::Grammar::FormattingCodes>
       <matchline>
#      <debug:step>
       \A  <Text>  \Z
    <token: Text> <[content]>+
    <token: text>  .+?
    <token: hs>[ \t]*
    <token: content> <MATCH=C_code> 
                    | <MATCH=D_code> 
                    | <MATCH=default_formatting_code> 
                    | <.text>
    <token: ldelim> <%delim>
    <token: rdelim> (??{ quotemeta $delim{$ARG{ldelim}} })
    <token: isValideFCode>
            <require: (?{ 
            ( $ARG{name} && ( $ARG{name} eq  uc($ARG{name} ) ) ) 
                        &&
            ( exists $allow{'*'} ||  exists $allow{$ARG{name}} )
            
            })>
    <rule: C_code>(?! \s+)
      <name=([C])><isValideFCode(:name)>
            <ldelim>     <content=( .*? )>   <rdelim(:ldelim)>
    <rule: D_code>(?! \s+)
      <name=([D])><isValideFCode(:name)>
            <ldelim>  <term=([^\|]*?)> (?: \| <[syns=(\S+)]>+ % ;)?  <rdelim(:ldelim)>
    <token: default_formatting_code> 
      <name=(\w)><isValideFCode(:name)>
            <ldelim>  <[content]>*?   <rdelim(:ldelim)>
}xms;

my @t;
my $STOP_TREE = 2;

@t = ( ' sd C<<<s B<s>>ss» sB<d>' );
@t=('D<test>, and D<word | synonym1 ;synonym2>');
@t=('C<as> asds B<asdasI<d>sad >');
my @grammars;

#@t         = ();

@grammars = @t if scalar(@t);
while ( my ( $src, $extree, $name ) = splice( @grammars, 0, 3 ) ) {
    $name //= $src;
    my $dump;
#    use Perl6::Pod::Autoactions;
#    if ( $src =~ $r->with_actions( Perl6::Pod::Codeactions->new ) ) {
            if ( $src =~ $r ) {
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

