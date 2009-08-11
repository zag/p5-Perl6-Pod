package Perl6::Pod::To::XHTML::MakeBody;

#$Id$

=pod

=head1 NAME

Perl6::Pod::To::XHTML::MakeBody - add body section

=head1 SYNOPSIS

    use Perl6::Pod::To::XHTML::MakeBody;
    my $x         = '';
    my $xml_writer = new XML::SAX::Writer:: Output => \$x;
    my $body_filter = new Perl6::Pod::To::XHTML::MakeBody::;
    my $out_filter = create_pipe($body_filter,  $xml_writer);
    my $to_parser = new Perl6::Pod::To::XHTML::
      out_put => $out_filter,
      header  => 0,
      head    => [
        link => {
            rel  => "stylesheet",
            href => "/styles/main.1232622176.css"
        }
      ];
  

=head1 DESCRIPTION

Perl6::Pod::To::XHTML::MakeBody - add body section

=cut

use warnings;
use strict;
use XML::ExtOn;
use base 'XML::ExtOn';

sub on_start_element {
    my ( $self, $el ) = @_;
    return $el unless $self->{SKIP_ROOT}++;
    return $el if $self->{OK} or $self->{HEADMODE};
    #if start head set flag
    if ( $el->local_name eq 'head') {
        $self->{HEADMODE}++;
    } else {
        my $start = $self->mk_start_element($self->mk_element('body'));
        $self->{OK}++;
        return [ $start, $el]
    }
    $el;
}
sub on_end_element {
    my ($self, $el) = @_;
    if ($el->local_name eq 'head' ) {
        delete $self->{HEADMODE};
    }
    return $el;
}

sub end_document {
    my $self = shift;
    if ( $self->{OK} ) {
        $self->_process_comm($self->mk_end_element( $self->mk_element('body')))
    }
    return $self->SUPER::end_document(@_);
}
1;
