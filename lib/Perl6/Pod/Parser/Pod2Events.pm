#$Id$
#
#  Test blocks events
package Perl6::Pod::Parser::Pod2Events;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use XML::ExtOn;
use Carp;
use base qw/ XML::ExtOn /;

use constant {
    NEW_LINE  => qr/^ \s* $/xms,
    DIRECTIVE => qr/^(begin|config|encoding|end|for|use)$/xms,
    BLOCK_NULL_CONTENT => qr/^(config|encoding|use)$/xms,
};

=head2 parse_config_str

Parse config for element

=cut

sub parse_config_str {
    my $self = shift;
    my $el   = shift;
    my $str  = shift;
    $el->{CONFIG} .= " " . $str if defined $str;
    return $el;
}

=head2 in_ambient_mode 

Check if in ambient mode

=cut

sub in_ambient_mode {
    my $self = shift;
    if ( $self->current_element() ) {
        return 0;
    }
    1;
}

sub stop_config {
    my $self = shift;
    my $elem = shift;
    return if $elem->{STOP_CONFIG};    #skip already stopped
    $elem->{STOP_CONFIG} = 1;
    $elem->{OPT}         = '';
    my $name      = $elem->local_name;
    my @block_opt = ();
    if ( my $opt = $elem->{CONFIG} ) {
        $opt =~ s/^\s+//;

        #$opt =~ s/\s+$//;
        @block_opt = split( /\s+/, $opt );
    }
    unless ( exists $elem->{Abbr} ) {

        #get block name for ' head1 :allow<V>= :like'
        if ( $name =~ /begin|for/ ) {

            #get name
            $name = shift @block_opt;
        }
    }
    $elem->{NAME} = $name;
    $elem->{OPT} = join " ", @block_opt;
    my $parser = $self->{parser} || die '$self->{parser} - > undef !';
    $parser->start_block( $elem->{NAME}, $elem->{OPT}, $elem->{LINE_NUM} );
}

sub on_characters {
    my $self = shift;
    my $elem = shift;
    my $text = shift;
    return unless defined $text;
    my $parser = $self->{parser} || die '$self->{parser} - > undef !';

    if ( $text =~ /${\( NEW_LINE )}/ ) {
        $self->_flush_para( $elem )
    }
    else {
        $elem->{TEXT} .= $text;
    }
    return;
}

sub _flush_para {
    my $self = shift;
    my $elem = shift || return;
    if ( my $agregated = delete $elem->{TEXT} ) {
        my $parser = $self->{parser} || die '$self->{parser} -> undef !';
        $parser->para($agregated);
    }
    return
}

sub on_end_element {
    my $self = shift;
    my $elem = shift;

    #flush agregated characters
    $self->_flush_para( $elem);
    my $parser = $self->{parser} || die '$self->{parser} - > undef !';
    $parser->end_block( $elem->{NAME}, $elem->{OPT}, $elem->{END_LINE} );
    $elem;
}

=head2 new_line 

Process new line in pod

=cut

sub new_line {
    my $self    = shift;
    my $str_num = shift;

    #stop previus block
    if ( my $el = $self->current_element ) {
        unless ( $el->{STOP_CONFIG} ) {
            $self->stop_config($el);

        }
#        else {
            if ( $el->local_name eq 'begin' ) {
                $self->characters( { Data => "\n" } );
            }
#        }

        #skip already stopped
        if ( $el->local_name ne 'begin' ) {
            $el->{END_LINE} = $str_num;
            $self->end_element($el);
        }
    }
}

# =begin test
# =for
# =end test
#
sub before_start_directive {
    my $self    = shift;
    my $str_num = shift;
    if ( my $current = $self->current_element ) {
        $self->stop_config($current);
        $self->_flush_para( $current );
        unless ( $current->local_name eq 'begin' ) {
            $current->{END_LINE} = $str_num;
            $self->end_element($current);

        }
    }
}

sub parse {
    my $self = shift;
    my $in   = shift;

    #check if block
    while (<$in>) {
        my $str_num = $.;

        #s/[\n\r]+/ /;
        /^=/ && do {

            #start directive ?
            if (/^=(\S+)\s*( .*)?$/) {
                my ( $name, $data ) = ( $1, $2 );
                $data =~ s/^\s+// if defined $data;
                $data =~ s/\s+$// if defined $data;

                #event for start directive
                $self->before_start_directive($str_num);
                if ( $name eq 'end' ) {
                    my $curr = $self->current_element
                      or die("Error: =end without begin at line $str_num: $_");
                    unless ( $data =~ /(\S+)/ ) {
                        die("Error: bad =end  at line $str_num: $_");
                    }
                    my ($name) = $data =~ m/(\w+)/;

                    if ( $curr->{NAME} ne $name ) {
                        die
"Error: Expected '=end  $curr->{NAME}'  at line $str_num:  $_";
                    }
                    $curr->{END_LINE} = $str_num;
                    $self->end_element($curr);
                }
                else {

                    my $block = $self->mk_element($name);
                    $block->{PARA}     = $_;
                    $block->{LINE_NUM} = $str_num;

                    #start element
                    $self->start_element($block);
                    if ( $name !~ /${\( DIRECTIVE )}/ ) {

                        #for Abbreviated blocks
                        $block->{Abbr} = 1;
                        $self->stop_config($block);

                        #set BLOCK_DATA for Abbreviated blocks
                        $data .= "\n" if defined $data;
                        $self->characters( { Data => $data } );
                    }
                    else {

                        #add additional info as CONFIG INFO
                        $self->parse_config_str( $block, $data );
                    }
                }
            }
            else {

                if ( my $current = $self->current_element() ) {
                    if ( $current->{STOP_CONFIG} ) {
                        carp
" Error at line $str_num: config_data not in block_head : $_ ";
                    }
                    else {

                        #get config string
                        my $conf = $_;
                        $conf =~ s/^=\s+(.*)?/$1/;
                        $self->parse_config_str( $current, $conf );
                    }
                }
                else {
                    carp
                      " Error at line $str_num: config_data without block: $_ ";
                }
            }
            1;
          }
          || ( !$self->in_ambient_mode ) && do {
            #check if new line
            if (/${\( NEW_LINE )}/) {
                $self->new_line($str_num);
            }
            else {
                my $lname = $self->current_element->local_name;
                #for directives use|config|encoding
                if ($lname =~ /${\( BLOCK_NULL_CONTENT )}/) {
                  $self->before_start_directive(); 
                }
                $self->characters( { Data => $_ } );
            }
          }
    }

}
1;

