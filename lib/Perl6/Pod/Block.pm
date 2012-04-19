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
use base 'Perl6::Pod::Lex::Block';


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


sub context {
    $_[0]->{__context};
}

sub get_class_options {
    my $self       = shift;
    my $_class_opt = $self->{_class_options} || return {};
    my $hash       = $self->context->_opt2hash($_class_opt);
    my %res;
    while ( my ( $key, $val ) = each %$hash ) {
        $res{$key} = $val->{value};
    }
    \%res

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

