package Perl6::Pod::Block;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Block - base class for Perldoc blocks

=head1 SYNOPSIS


=head1 DESCRIPTION

Perl6::Pod::Block - base class for Perldoc blocks

=cut

use strict;
use warnings;
use Data::Dumper;
use XML::ExtOn::Element;
use XML::ExtOn::Context;
use base 'XML::ExtOn::Element';
use Perl6::Pod::FormattingCode;

sub new {
    my ( $class, %args ) = @_;
    my $doc_context = new XML::ExtOn::Context::;
    my $self =
      $class->SUPER::new( context => $doc_context, name => $args{name} );

    #save orig context
    $self->{__context}    = $args{context} || die 'need context !';
    $self->{_pod_options} = $args{options} || '';
    $self;
}

sub context {
    $_[0]->{__context};
}

=head2 mk_block <BLOCK_NAME>, <POD_OPTIONS>

Create block element.

=cut

sub mk_block {
    my $self = shift;
    my ( $name, $pod_opt ) = @_;
    my $mod_name = $self->context->use->{$name}
      || 'Perl6::Pod::Block'; # or die "Unknown block_type $name. Try =use ...";
                              #get prop
    my $block = $mod_name->new(
        name    => $name,
        context => $self->context,
        options => $pod_opt
    );
    return $block;

}

=head2 mk_fcode <BLOCK_NAME>, <POD_OPTIONS>

Create block element.

=cut

sub mk_fcode {
    my $self = shift;
    my ( $name, $pod_opt ) = @_;
    my $mod_name = $self->context->use->{$name."<>"}
      || 'Perl6::Pod::FormattingCode'
      ;    # or die "Unknown block_type $name. Try =use ...";
           #get prop
    my $block = $mod_name->new(
        name    => $name,
        context => $self->context,
        options => $pod_opt
    );
    return $block;

}

sub start {
    my ( $self, $attr ) = @_;
}

sub end {
    my ( $self, $attr ) = @_;
}

sub on_para {
    my ( $self, $parser, $txt ) = @_;
    #process formating codes by default
    return $parser->parse_para($txt); 
}

#make events for root parser DEPRECATED
sub __make_events {
    my $self = shift;
    my @res  = ();
    foreach my $el (@_) {
        unless ( ref($el) ) {
            $el = { type=>'para', data=>$el }
        }
        #process refs
        if  ( exists $el->{type} ) {
           push @res, $el 
        } else {
            my $name = $el->{name};
            #make start stop
            push @res, { 
                type=>'start_fcode',
                data =>$name
                }, $self->__make_events(@{$el->{childs}}), { 
                type=>'end_fcode',
                data =>$name
                }
        }
    }
    return @res;
}

=head2 parse_para

DEPRECATED

Parse format codes

=cut

sub parse_para {
    my $self  = shift;
    my $rpara = $self->context->{vars}->{root};
    my @args = ();
    foreach my $para ( @_ )  {
       push @args ,  ref( $para ) ? $para :  @{ $rpara->parse_str($para) }
    }
    return $self->__make_events( @args )
}

sub on_child {
    my ( $self, $parser, $elem  ) = @_;
    return $elem;
}


=head2 get_attr [block name]

Return blocks attributes splited with pre-configured via =config.
Unless provided <block_name> return attributes for current block.

=cut

sub get_attr {
    my $self    = shift;
    my $context = $self->context;
    my $name =  shift || $self->local_name ;
    #warn $context->config;
    my $pre_config_opt = $context->config->{ $name } || '';
    my $opt            = $self->{_pod_options};
    my $hash           = $context->_opt2hash( $pre_config_opt . " " . $opt );
    my %res            = ();
    while ( my ( $key, $val ) = each %$hash ) {
        $res{$key} = $val->{value};
    }
    \%res;
}

#default export methods

sub to_xml1 {
    my $self     = shift;
    my $parser   = shift;
    my $ln       = $self->local_name;
    my $attr     = $self->get_attr;
    my $elem = $parser->mk_element( $ln);
    my $eattr = $elem->attrs_by_name;
    %{$elem->attrs_by_name}= %$attr;
    my @content = ();
    foreach my $in_param ( @_) {
        push @content, $in_param
    }
    return $elem
}
sub to_sax2 {
    return $_[0];
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

