package Perl6::Pod::Directive::use;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Directive::use - handle =use directive

=head1 SYNOPSIS


=head1 DESCRIPTION

Perl6::Pod::Directive::use - handle =use directive

=cut

use warnings;
use strict;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';

sub start {
    my $self = shift;
    my ( $parser, $attr ) = @_;
    $self->delete_element->skip_content;
    #handle
    #=use Module::Name block_name :config_attr
    my $opt = $self->{_pod_options};
    my ( $class, $name, @params ) = split( /\s+/, $opt );
    $self->{_pod_options} = join " ", @params;

    #try to load class
    #    eval "use $class";
    #check non loaded mods

    #check non loaded mods
    my ( $main, $module ) = $class =~ m/(.*\:\:)?(\S+)$/;
    $main ||= 'main::';
    $module .= '::';
    no strict 'refs';
    unless ( exists $$main{$module} ) {
        eval "use $class";
        if ($@) {
            warn "Error register class :$class with $@ ";
            return "Error register class :$class with $@ ";
            next;
        }
    }
    use strict 'refs';
    $parser->current_context->use->{$name} = $class;
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

