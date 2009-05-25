package Perl6::Pod::Parser;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Parser - base class for perl6's pod parsers

=head1 SYNOPSIS


=head1 DESCRIPTION

Perl6::Pod::Parser - base class for perl6's pod parsers

DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !

=cut

use warnings;
use strict;
use Carp;
use IO::File;
use Test::More;
use Data::Dumper;
use Perl6::Pod::Parser::Pod2Events;
use XML::ExtOn;
use Pod::Parser;
use Perl6::Pod::Parser::Context;
use base qw/XML::ExtOn/;


sub new {
    my $self = XML::ExtOn::new(@_);

    #create default context
    my $context = new Perl6::Pod::Parser::Context::;

    #setup defaults
    $self->{__DEFAULT_CONTEXT} = $context;
    $context->use->{test} = 'Perl6::Pod::Block::Test';
    return $self;
}

sub current_context {
    my $self = shift;
    if ( my $current_block = $self->current_element ) {
        return $current_block->context;
    }
    return $self->{__DEFAULT_CONTEXT};
}


sub mk_block {
    my $self = shift;

    #try get current element
    if ( my $current_block = $self->current_element ) {
        return $current_block->mk_block(@_);
    }

    #make first element
    my ( $name, $pod_opt ) = @_;
    my $mod_name = $self->current_context->use->{$name}
      || 'Perl6::Pod::Block';

    #      or die "Unknown block_type $name. Try =use ...";

    #get prop
    my $block = $mod_name->new(
        name    => $name,
        context => $self->current_context,
        options => $pod_opt
    );

}



sub _parse_chunk {
    my ( $self, $src ) = @_;
    my $ev = new Perl6::Pod::Parser::Pod2Events:: parser => $self;
    $ev->parse($src);

}
sub parse {
    my $self = shift;
    my $src = shift ;
    my $need_close = 0;
    unless ( ref $src ) {
        $src = new IO::File::  $src ,'r'  or die "Eror open file: $!";
        $need_close = 1;
    }
    if ( ref $src eq 'SCALAR') {
         open( my $fh , '< ', $src );
        $need_close = 1;
        $src = $fh
    }
    unless (
            ( UNIVERSAL::isa( $src, 'IO::Handle' ) or ( ref $src ) eq 'GLOB' )
            or UNIVERSAL::isa( $src, 'Tie::Handle' )
           )
        {
            croak "parse: Need  <ref to string|GLOB> or <file_nadler>"
        }
    $self->begin_input;
    $self->_parse_chunk($src);
    $self->end_input;
    close $src if $need_close;
    
}

sub on_start_element {
    my $self = shift;
    return $self->on_start_block(@_)

}

sub on_start_block {
    my $self = shift;
    my $blk  = shift;
    $blk->start( $blk->get_attr() );
    return $blk;
}

sub on_end_element {
    my $self = shift;
    return $self->on_end_block(@_);
}

sub on_end_block {
    my $self = shift;
    my $blk  = shift;
    $blk->end( $blk->get_attr(), );
    return $blk;

}

sub on_para {
    my $self = shift;
    my ( $bl, $txt ) = @_;
    return $txt;
}

sub on_characters {
    my $self = shift;
    return $self->on_para(@_);
}

sub begin_input {
    my $self = shift;
    $self->start_document;
}

sub end_input {
    my $self = shift;
    $self->end_document;
}

sub start_block {
    my $self = shift;
    my ( $name, $opt, ) = @_;
    my $elem = $self->mk_block( $name, $opt );

    #get attributes
    #create context
    #{ block_name }=>{ opt1 => opt2}
    $self->start_element($elem);
}

sub para {
    my $self  = shift;
    my $txt   = shift;
    my $elems = $self->get_elements_from_ref( $self->parse_str($txt) );
    $self->_process_comm($_) for @$elems;

    #    $p1
    #    $self->characters( { Data => $txt } );
}

sub end_block {
    my $self = shift;
    my ( $name, $opt ) = @_;
    my $elem = $self->current_element;    #mk_block($name, $opt);
    $self->end_element($elem);
}

sub _parse_tree_ {
    my $self = shift;
    my $elem = shift;
    if ( ref($elem) ) {
        if ( UNIVERSAL::isa( $elem, 'Pod::ParseTree' ) ) {
            return [ map { ref($_) ? $self->_parse_tree_($_) : $_ }
                  $elem->children ];
        }
        elsif ( UNIVERSAL::isa( $elem, 'Pod::InteriorSequence' ) ) {
            my %attr = ( name => $elem->cmd_name );
            if ( my $ptree = $elem->parse_tree ) {
                $attr{childs} = $self->_parse_tree_($ptree);
            }
            return \%attr;
        }
    }
}

sub parse_str {
    my $self = shift;
    my $str  = shift;
    my $p    = new Pod::Parser::;
    my $res  = $self->_parse_tree_( Pod::Parser->new->parse_text( $str, 123 ) );
    return $res;
}

sub get_elements_from_ref {
    my $self = shift;
    my $ref  = shift;

    #create array of elements
    my @elems = ();
    foreach (@$ref) {
        my $elem;
        unless ( ref $_ ) {
            $elem = $self->mk_characters($_);
        }
        else {
            my $current_element = $self->current_element || $self;
            $elem = $current_element->mk_block( $_->{name} );
            if ( my $childs = $_->{childs} ) {
                my $child_elements = $self->get_elements_from_ref($childs);
                $elem->add_content(@$child_elements);
            }
        }
        push @elems, $elem;
    }
    return \@elems;
}

1;
__END__


=head1 SEE ALSO

L<http://perlcabal.org/syn/S26.html>

=head1 AUTHOR

Zahatski Aliaksandr, <zag@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

