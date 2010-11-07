#===============================================================================
#
#  DESCRIPTION:  SERVICE SEMANTIC BLOCK for NOTES
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package Perl6::Pod::Parser::NOTES;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Parser::NOTES  - help export N<> to html

=head1 SYNOPSIS

    =NOTES
    1  King Arthur's singing shovel   
    2  Master of cutlery              
    3  Ticking time bomb of fury      
    4  Haunted bowling ball           

=head1 DESCRIPTION

=cut
use warnings;
use strict;
use Data::Dumper;
use Test::More;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';

sub on_para {
    my ( $self, $p, $txt ) = @_;
    if ( exists $self->attrs_by_name->{note_id} ) {
        return $self->SUPER::on_para( $p, $txt );
    }
    # calculate count of fields
    foreach my $line ( split /\n/, $txt ) {
        # clean begin and end of line
        $line =~ s/^\s*//;
        $line =~ s/\s*$//;
        my ( $id, @columns) = split( /\t/, $line );
        my $col = $self->mk_block("_NOTE_");
        $col->attrs_by_name->{note_id} = "$id";
        $p->start_block( $col, '', 0 );
        $p->para(join("\t",@columns));
        $p->end_block( $col, '', 0 );
        
    }
    return undef;
}
1;
