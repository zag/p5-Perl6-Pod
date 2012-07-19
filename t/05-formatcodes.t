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
use Test::More tests => 16;    # last test to print
my %delim = ( '<' => '>', '«' => '»', '<<' => '>>' );
my %allow = ( '*' => 1 );
my $r     = qr{

       <extends: Perl6::Pod::Grammar::FormattingCodes>
       <matchline>
#      <debug:step>
       \A  <Text>  \Z
    <token: Text> <[content]>+
    <token: text> .+?
    <token: hs>[ \t]*
    <token: content> <MATCH=C_code> 
                    | <MATCH=D_code> 
                    | <MATCH=L_code> 
                    | <MATCH=X_code> 
                    | <MATCH=P_code> 
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

    <rule: LL_code>(?! \s+)
      <name=(L)><isValideFCode(:name)>
            <ldelim>     <content=(.*?)>   <rdelim(:ldelim)>
    <rule: L_code>(?! \s+)
#          <ws: ( [^\n] | \s++  )* >
          <ws: ([ \t])*>
#          <ws: (?: [^\n]|\s+)* >
      <name=(L)><isValideFCode(:name)>
            <ldelim>
            #alternate presentation
     (?: <alt_text=([^\n\|]*?)> \| )? #hack1: not work for 
    #L< http://cpan.org > B<sd > L< haname | http:perl.html  >
    # '' => 'L< http://cpan.org > B<sd > L< haname | http:perl.html  >'
   #         (?:<alt_text=(.*?)>)? #hack
               
                <scheme=([^|\s:]+:)>? #scheme specifier
                (?: <is_external=(//)> )? 
                  <address=([^\|]*?)>? #for hack1
                 (?: \# <section=(.*?)> )? #internal addresses
            <rdelim(:ldelim)>
    <rule: X_code_entry> <[entry=([^,\;]+?)]>* % (\s*,\s*)
    <rule: X_code>(?! \s+)
     <name=(X)><isValideFCode(:name)>
            <ldelim>
          # X<text>
          ( <text=([^\n\|]*?)>(?{$MATCH{entry}=$MATCH{text}; $MATCH{form} = 1  })
          |
            <text=([^\n\|]*?)>? \| <[entries=X_code_entry]>* % (\s*\;\s*) 
            (?{$MATCH{form} = 2})
             )
            <rdelim(:ldelim)>

    <rule: P_code>
     <name=(P)><isValideFCode(:name)>
             <ldelim> <.hs> 
                <scheme=([^|\s:]+:)>? #scheme specifier
                (?: <is_external=(//)> )? 
                  <address=([^\|]*?)> 
            <.hs> <rdelim(:ldelim)>
    <token: default_formatting_code> 
      <name=(\w)><isValideFCode(:name)>
            <ldelim> <.hs> <[content]>*? <.hs> <rdelim(:ldelim)>
}xms;

sub parse_para {
    my $src = shift;
    use Perl6::Pod::Utl;
    return Perl6::Pod::Utl::parse_para($src, reg=>$r);
}

my @t;
my $STOP_TREE = 2;

@t = ( ' sd C<<<s B<s>>ss» sB<d>' );
@t=('D<test>, and D<word | synonym1 ;synonym2>');
@t=('C<as> asds B<asdasI<d>sad >');
my @grammars;
#### test L<>
is parse_para('L<http://example.com>')->[0]->{scheme},'http:', 'L: scheme http://example.com';
#=pod 
my $t1 = parse_para('L<http://example.com/test#test>')->[0];
#print Dumper $t1;exit;
is $t1->{section}, 'test', 'L: section';
ok $t1->{is_external}, 'L: external';

$t1 = parse_para('L<#test>')->[0];
is $t1->{section}, 'test', 'L: only section';

$t1 = parse_para('L<text | #test>')->[0];
is $t1->{alt_text}, 'text', 'L: alternate text';

$t1  = parse_para('L<mailto:devnull@rt.cpan.org>')->[0];
is $t1->{scheme},'mailto:','L: mailto';

$t1 = parse_para('L<issn:1087-903X>')->[0];
is $t1->{scheme},'issn:','L: issn';

$t1 = parse_para('L<OK |file://sdsd/config#test>')->[0];
is $t1->{scheme},'file:','L: file';

$t1 = parse_para('L<file:./cpan.org >
B<sd > L<< haname | http:perl.html  >>')->[0];
is $t1->{scheme},'file:','L: L<> L<|>';
$t1 = parse_para('L<B<test1>|http://example.com> test')->[0];
is $t1->{alt_text}, 'B<test1>','nested formatting codes';

$t1 = parse_para('X< array >')->[0];
is $t1->{text}, $t1->{entry}, 'X<array>';
is $t1->{text}, 'array', 'check text X<array>';
$t1 = parse_para('X< arrays | array1, array2; use array >')->[0];
is @{$t1->{entries}}, 2, "more than one entries";
is $t1->{text}, 'arrays', 'check text: X< arrays | array1, array2; use array >';
$t1 = parse_para('X<| array1, array2; use array >')->[0];
is $t1->{text},'', 'empty text';
$t1 = parse_para('P<http://example.com>')->[0];
is $t1->{'scheme'},'http:', 'P: scheme';

#diag Dumper $t1;

#diag Dumper $t1;
#diag Dumper parse_para('L<http://example.com/test#test>');
#diag Dumper parse_para('C«E<nbsp>»');

exit;

#@t         = ();

@grammars = @t if scalar(@t);
while ( my ( $src, $extree, $name ) = splice( @grammars, 0, 3 ) ) {
    $name //= $src;
    my $dump;
    use Perl6::Pod::Utl;
    my $res = Perl6::Pod::Utl::parse_para($src, reg=>$r);
    diag Dumper $res; exit;
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

