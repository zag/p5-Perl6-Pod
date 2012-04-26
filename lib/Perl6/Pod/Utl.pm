#===============================================================================
#
#  DESCRIPTION:  Utils for Perl6 Pod
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
package Perl6::Pod::Utl;
use strict;
use warnings;
use Perl6::Pod::Autoactions;

=head2  parse_pod [default_pod => 0 ]

=item * default_pod => 0/1 

switch on/off ambient mode for para out of =pod blocks. Default 0 (ambient mode)

return ref to tree

=cut

sub parse_pod {
    use Regexp::Grammars;
    use Perl6::Pod::Grammars;
    use Perl6::Pod::Autoactions;
    use v5.10;
    use Data::Dumper;
    my ( $src, %args ) = @_;
    my $r = qr{
       <extends: Perl6::Pod::Grammar::Blocks>
       <matchline>
        \A <File> \Z
    }xms;

    my $tree ;
    if ( $src =~ $r  ) {
#    if ( $src =~ $r->with_actions( Perl6::Pod::Autoactions->new (%args) ) ) {
        $tree = {%/}->{File};
    }
    else {
        return undef;
    }

}

=head2 strip_vmargin $vmargin, $txt

  =begin pod
  <vmargin=(\s+)> =para 
                  text
  =end pod

=cut

sub strip_vmargin {
        my ($vmargin, $content )= @_;
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
        return $content
}

1;

