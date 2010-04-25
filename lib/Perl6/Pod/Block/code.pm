package Perl6::Pod::Block::code;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Block::code - Verbatim pre-formatted sample source code

=head1 SYNOPSIS

     =begin code
      print "Ok";
     =end code

=head1 DESCRIPTION

Code blocks are used to specify pre-formatted text (typically source code), which should be rendered without rejustification, without whitespace-squeezing, and without recognizing any inline formatting codes. Code blocks also have an implicit nesting associated with them. Typically these blocks are used to show examples of code, mark-up, or other textual specifications, and are rendered using a fixed-width font.

A code block may be implicitly specified as one or more lines of text, each of which starts with a whitespace character. The block is terminated by a blank line. For example:

    This ordinary paragraph introduces a code block:
    
            $this = 1 * code('block');
            $which.is_specified(:by<indenting>);


Implicit code blocks may only be used within =pod, =item, =nested, =END, or semantic blocks.

=cut

use warnings;
use strict;
use Data::Dumper;
use Test::More;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';

sub to_xml { 
    my $self = shift;
    my $parser = shift;
    return $parser->_make_xml_element($self)->add_content($parser->mk_cdata(@_));
}

=head2 to_xhtml

    =code
    test code

Render to:

    <pre><code>
        test code
    </code></pre>
=cut

sub to_xhtml { 
    my $self = shift;
    my $parser = shift;
    my $el = $parser->mk_element('code')->insert_to( $parser->mk_element('pre') );
    $el->add_content( $parser->mk_characters( @_));
}

=head2 to_docbook

    =code
    test code

Render to:

     <chapter><programlisting><![CDATA[    test code
     ]]></programlisting></chapter>

=cut
sub to_docbook {
    my $self = shift;
    my $parser = shift;
    my $el = $parser->mk_element('programlisting');
    $el->add_content( $parser->mk_cdata( @_));
}

sub on_para {
    my ($self , $parser, $txt)  = @_;
    return  $txt;
}

sub on_child {
    my ($self ,$parser, $child )= @_;
    diag "got child!";
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

