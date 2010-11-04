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
use open ':utf8';
use IO::File;
use Test::More;
use Data::Dumper;
use Perl6::Pod::Parser::Pod2Events;
use XML::ExtOn;
use Pod::Parser;
use Perl6::Pod::Parser::Context;
use Perl6::Pod::FormattingCode;
use Perl6::Pod::Block;
use base qw/XML::ExtOn/;

sub new {
    my $self = XML::ExtOn::new(@_);

    unless ( exists $self->{__DEFAULT_CONTEXT} ) {

        #create default context
        my $context =
          new Perl6::Pod::Parser::Context:: vars => { root => $self };

        #setup defaults
        $self->{__DEFAULT_CONTEXT} = $context;
    }
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
    #create class_options
    my $class_options = $self->current_context->class_opts->{$name};

    #get prop
    my $block = $mod_name->new(
        name          => $name,
        context       => $self->current_context,
        options       => $pod_opt,
        class_options => $class_options
    );

}

sub mk_fcode {
    my $self = shift;

    #try get current element
    if ( my $current_block = $self->current_element ) {
        return $current_block->mk_fcode(@_);
    }

    #make first element
    my ( $name, $pod_opt ) = @_;
    my $mod_name = $self->current_context->use->{ $name . "<>" }
      || 'Perl6::Pod::FormattingCode';

    #      or die "Unknown block_type $name. Try =use ...";
    #get prop
    my $block = $mod_name->new(
        name    => $name,
        context => $self->current_context,
        options => $pod_opt,
        class_options => $self->current_context->class_opts->{ $name . "<>" }
    );

}

sub _parse_chunk {
    my ( $self, $src ) = @_;
    my $need_close = 0;
    if ( ref $src eq 'SCALAR' ) {
        open( my $fh, '< ', $src );
        $need_close = 1;
        $src        = $fh;
    }
    my $ev = new Perl6::Pod::Parser::Pod2Events:: parser => $self;
    $ev->parse($src);
    $ev->new_line;
    $src->close if $need_close;
}

sub parse {
    my $self       = shift;
    my $src        = shift;
    my $need_close = 0;
    unless ( ref $src ) {
        $src = new IO::File:: $src , 'r' or die "Eror open file: $!";
        $need_close = 1;
    }
    if ( ref $src eq 'SCALAR' ) {
        open( my $fh, '< ', $src );
        $need_close = 1;
        $src        = $fh;
    }
    unless ( ( UNIVERSAL::isa( $src, 'IO::Handle' ) or ( ref $src ) eq 'GLOB' )
        or UNIVERSAL::isa( $src, 'Tie::Handle' ) )
    {
        croak "parse: Need  <ref to string|GLOB> or <file_handler>";
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

    #    warn "start element ". $blk->local_name;
    # call on_child for curretn element
    if ( my $elem = $self->current_element ) {

#    warn "on child!" .$elem->local_name ." -> on_child( ". $blk->local_name.")";;
#        $elem->on_child( $blk)
    }
    $blk->start( $self, $blk->get_attr() );
    return $blk;
}

sub on_end_element {
    my $self = shift;
    return $self->on_end_block(@_);
}

sub on_end_block {
    my $self = shift;
    my $blk  = shift;
    $blk->end( $self, $blk->get_attr() );
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

############### 5 basic events

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
    my ( $name, $opt, $str_num ) = @_;
    my $elem = ref($name) ? $name : $self->mk_block( $name, $opt );
    $self->start_element($elem);
}

sub __expand_array_ref {
    my $self = shift;
    my @res  = ();
    for (@_) {
        push @res, ref($_) eq 'ARRAY' ? $self->__expand_array_ref(@$_) : $_;
    }
    @res;
}

sub para {
    my $self = shift;
    my $txt  = shift;
    #hadnle block on_para
    if ( my $elem = $self->current_element ) {
        $txt = $elem->on_para( $self, $txt );
        if ( ref($txt) ) {
            $self->run_para($txt);
        }
        else {
            $self->_process_comm( $self->mk_characters($txt) );
        }
    }
}

sub end_block {
    my $self = shift;
    my ( $name, $opt, $str_num ) = @_;
    my $elem = $self->current_element;    #mk_block($name, $opt);
    $self->end_element($elem);
}

sub run_para {
    my $self = shift;
    my @in   = $self->__expand_array_ref(@_);
    foreach my $el (@in) {
        if ( UNIVERSAL::isa( $el, 'XML::ExtOn::Element' ) ) {
            $self->_process_comm($el);
            next;
        }
        unless ( exists $el->{type} ) {
            $self->__process_events( $self->__make_events($el) );
        }
        else {
            if ( $el->{type} eq 'para' ) {
                $self->_process_comm( $self->mk_characters( $el->{data} ) );
            }
        }
    }
}

#make events for root parser
sub __make_events {
    my $self = shift;
    my @res  = ();
    foreach my $el (@_) {
        unless ( ref($el) ) {
            $el = { type => 'para', data => $el };
        }

        #process refs
        if ( exists $el->{type} ) {
            push @res, $el;
        }
        else {
            my $name = $el->{name};

            #make start stop
            push @res,
              {
                type => 'start_fcode',
                data => $name
              },
              $self->__make_events( ref($el->{childs}) ? @{ $el->{childs} } : $el->{childs}),
              {
                type => 'end_fcode',
                data => $name
              };
        }
    }
    return @res;
}

sub __process_events {
    my $self  = shift;
    my $rootp = $self;    #->context->{vars}->{root};
    foreach my $ev (@_) {
        my $type = $ev->{type};
        if ( $type eq 'para' ) {
            $rootp->para( $ev->{data} );
        }
        else {

            #process format code
            my $fc = $self->mk_fcode( $ev->{data} );
            ( $ev->{type} eq 'start_fcode' )
              ? $rootp->start_block( $fc, '', 0 )
              : $rootp->end_block( $fc, '', 0 );
        }
    }
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
            $elem = $current_element->mk_fcode( $_->{name} );
            if ( my $childs = $_->{childs} ) {
                my $child_elements = $self->get_elements_from_ref($childs);
                $elem->add_content(@$child_elements);
            }
        }
        push @elems, $elem;
    }
    return \@elems;
}

#make XML::ExtOn objects from array
sub _make_elements {
    my $self = shift;
    my @res  = ();
    for (@_) {
        push @res, ref($_)
          ? ref($_) eq 'ARRAY'
              ? $self->_make_elements(@$_)
              : $_
          : $self->mk_characters($_);
    }
    return @res;
}
1;
__END__


=head1 SEE ALSO

L<http://zag.ru/perl6-pod/S26.html>,
Perldoc Pod to HTML converter: L<http://zag.ru/perl6-pod/>,
Perl6::Pod::Lib

=head1 AUTHOR

Zahatski Aliaksandr, <zag@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2010 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

