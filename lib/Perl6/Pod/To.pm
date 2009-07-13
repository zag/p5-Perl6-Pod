package Perl6::Pod::To;

#$Id$

=pod

=head1 NAME

Perl6::Pod::To - base class for output formatters

=head1 SYNOPSIS


=head1 DESCRIPTION

Perl6::Pod::To - base class for output formatters

=cut

use strict;
use warnings;
use Perl6::Pod::Parser;
use Test::More;
use Data::Dumper;
use XML::ExtOn ('create_pipe');
use base qw/Perl6::Pod::Parser/;

################# FUNCTION
sub to_abstract {
    my $class = shift;
    my $out   = shift;
    my %arg   = @_;
    $arg{out_put} = $out if defined($out);
    my $out_formatter = $class->new(%arg);
    my $p = create_pipe( 'Perl6::Pod::Parser', $out_formatter );
    return wantarray ? ( $p, $out_formatter ) : $p;
}

=head1 METHODS

=cut

sub on_start_block {
    my $self = shift;
    my $el   = shift;
    return $el unless $el->isa('Perl6::Pod::Block');
    $el->delete_element;
    return $el;
}

sub export_block {
    my ( $self, $elem, $text ) = @_;
    my $lname = $elem->local_name;
    warn ref($self)."->export_block_$lname() not found. And not overriden export_block method ";
}

sub export_code {
    my ( $self, $elem, $text ) = @_;
    my $lname = $elem->local_name;
    warn ref($self)."->export_code_$lname() not found. And not overriden export_code method ";
}

sub on_para {
    my $self = shift;
    my ( $element, $text ) = @_;
    return $text unless $element->isa('Perl6::Pod::Block');
    $element->{_CONTENT_} .= $text;
    return;
}

#internal methods
# $self->__handle_export( $element, @params)
# return export data of $element

sub __handle_export {
    my $self   = shift;
    my $el     = shift || return;
    my $e_name = $el->local_name;
    my $e_type = $el->isa('Perl6::Pod::FormattingCode') ? 'code' : 'block';
    my $export_method = "export_${e_type}_${e_name}";
    return
        $self->can($export_method) ? $self->$export_method( $el, @_ )
      : $e_type eq "code" ? $self->export_code( $el, @_ )
      :                     $self->export_block( $el, @_ );
}

=head2 print_export

Method for handle print out exported data

=cut

sub print_export {
    my $self = shift;
    my @data = @_;

    #get out unless not out_put defined
    return unless exists $self->{out_put};
    my $out_put = $self->{out_put};
    return unless ref($out_put);    #skip bad out
    if ( ref($out_put) eq 'SCALAR' ) {
        $$out_put .= join "" => @data;
    }
    elsif (
        (
            UNIVERSAL::isa( $out_put, 'IO::Handle' )
            or ( ref $out_put ) eq 'GLOB'
        )
        or UNIVERSAL::isa( $out_put, 'Tie::Handle' )
      )
    {
        print $out_put join "" => @data;
    }
}

sub on_end_block {
    my $self = shift;
    my $el   = shift;
    return $el unless $el->isa('Perl6::Pod::Block');

    my $text = exists $el->{_CONTENT_} ? $el->{_CONTENT_} : undef;
    my $data = $self->__handle_export( $el, $text );
    my $cel = $self->current_element;
    if ($cel) {
        $cel->{_CONTENT_} .= $data;
        return;
    }
    else {
        $self->print_export($data);
    }
    return $el;
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


