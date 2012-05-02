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
use base 'Perl6::Pod::Lex::Block';

sub get_attr {
    my $self = shift;
    my $attr = $self->SUPER::get_attr;
    #union attr with =config
    if (my $ctx = $self->context) {
        if ( my $config = $ctx->get_config( $self->name ) ) {
         while ( my ($k, $v) = each %$config ) {
            $attr->{$k} = $v
           }
         }
    }
    $attr;
}

sub context {
    $_[0]->{context};
}

=pod
sub new {
    my ( $class, %args ) = @_;

    my $doc_context = new XML::ExtOn::Context::;
    my $self =
      $class->SUPER::new( context => $doc_context, name => $args{name} );

    #save orig context
    $self->{__context}    = $args{context} || die 'need context !';
    $self->{_pod_options} = $args{options} || '';

    #handle class options, if defined when Module load ( =use )
    $self->{_class_options} = $args{class_options};

    #make local context

    $self->{__context} =
      new Perl6::Pod::Parser::Context:: %{ $self->{__context} }
      unless exists $args{parent_context};
    $self->context->custom->{_check_allow_parent_on_} = 1
      if exists VERBATIMS->{ $args{name} };
    $self;
}
=cut
1;
__END__

=head1 SEE ALSO

L<http://zag.ru/perl6-pod/S26.html>,
Perldoc Pod to HTML converter: L<http://zag.ru/perl6-pod/>,
Perl6::Pod::Lib

=head1 AUTHOR

Zahatski Aliaksandr, <zag@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2012 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

