package Perl6::Pod::To::DocBook::ProcessHeads;

#$Id$

=pod

=head1 NAME

Perl6::Pod::To::DocBook::ProcessHeads - convert heads to sections

=head1 SYNOPSIS

    use Perl6::Pod::To::DocBook::ProcessHeads;
    $self->{out_put} =
    create_pipe( 'Perl6::Pod::To::DocBook::ProcessHeads', $self->{out_put});


=head1 DESCRIPTION

Perl6::Pod::To::DocBook::ProcessHeads - convert heads to sections

=cut

use warnings;
use strict;
use XML::ExtOn;
use base 'XML::ExtOn';

sub on_start_element {
    my ($self, $el ) = @_;
    my $lname = $el->local_name;
    if ($lname eq 'headlevel') {
        %{ $el->attrs_by_name  } = ();
        $el->local_name('section');
    } elsif ($lname =~ /^head/) {
        $el->local_name('title');
    }
    $el;
}
1;
