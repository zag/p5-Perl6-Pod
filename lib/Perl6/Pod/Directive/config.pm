package Perl6::Pod::Directive::config;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Directive::config - handle =config directive

=head1 SYNOPSIS

Block pre-configuration

  =config head1 :numbered
  =config head2 :like<head1> :formatted<I>

Pre-configuring formatting codes


  =config V<>  :allow<E>
  =config C<>  :formatted<I>


=head1 DESCRIPTION

Perl6::Pod::Directive::config - handle =config directive

The =config directive allows you to prespecify standard configuration information that is applied to every block of a particular type.

    =config BLOCK_TYPE  CONFIG OPTIONS
    =                   OPTIONAL EXTRA CONFIG OPTIONS

=cut

use warnings;
use strict;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';
use Data::Dumper;

sub new {
      my ( $class, %args ) = @_;
      my $self = $class->SUPER::new(%args, parent_context=>1);
}

sub start {
    my $self = shift;
    my ( $parser, $attr ) = @_;
    $self->delete_element->skip_content;

    #handle
    #=config block_name :config_attr
    my $opt = $self->{_pod_options};
    my ( $name, @params ) = split( /\s+/, $opt );
    my $current_opt = $parser->current_context->config->{$name} || '';
    $opt = join " ", $current_opt, @params;
    $parser->current_context->config->{$name} = $opt;
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

