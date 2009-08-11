package Perl6::Pod::To::XHTML::ProcessHeadings;

#$Id$

=pod

=head1 NAME

Perl6::Pod::To::XHTML::ProcessHeadings - convert  headings to tags

=head1 SYNOPSIS

    use Perl6::Pod::To::XHTML::ProcessHeadings;
    $self->{out_put} =
    create_pipe( 'Perl6::Pod::To::XHTML::ProcessHeadings', $self->{out_put});


=head1 DESCRIPTION

Perl6::Pod::To::XHTML::ProcessHeadings - convert headings to tags

=cut

use warnings;
use strict;
use XML::ExtOn;
use base 'XML::ExtOn';

sub on_start_element {
    my ($self, $el ) = @_;
    my $lname = $el->local_name;
    return $el if exists $el->{XHTML_HEAD};
    if ($lname eq 'headlevel') {
        #save current level
        $self->{CURRENT_LEVEL} = $el->attrs_by_name->{level};
        %{ $el->attrs_by_name  } = ();
        $el->delete_element;
    } elsif ($lname =~ /^head/) {
        #set h to current level
        $el->local_name('h'.$self->{CURRENT_LEVEL});
    }
    $el;
}
1;
