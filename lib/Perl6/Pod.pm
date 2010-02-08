package Perl6::Pod;

#$Id$

=pod

=head1 NAME

Perl6::Pod - use Perl6's pod in perl5 programms

=head1 SYNOPSIS

    use Perl6::Pod;

    =comment
    Some text

    =head1 Head title
    =para
    Some text of para

Delimited style, paragraph style, or abbreviated style of blocks

    =begin para :formatted<B I>
    Perl is a stable, cross platform programming language. 
    =end para

    =for para :formatted<B I>
    Perl is a stable, cross platform programming language. 

    =para
    Perl is a stable, cross platform programming language. 

Unordered lists 

    =item FreeBSD
    =item Linux
    =item Windows
    =item MacOS

Definition lists 

    =for item :term<XML>
    Extensible Markup Language
    =for item :term<HTML>
    Hyper Text Markup Language


=head1 DESCRIPTION


Perl6::Pod - in general, a set of classes, scripts and modules for maintance Perl6's pod documentation using perl5.

The suite contain the following classes:

=over

=item * L<Perl6::Pod::Parser> - base class for perl6's pod parsers

=item * L<Perl6::Pod::Block> - base class for Perldoc blocks

=item * L<Perl6::Pod::FormattingCode> - base class for formatting code

=item * L<Perl6::Pod::To> - base class for output formatters

=back

DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !DOCUMENTING !

=cut

$Perl6::Pod::VERSION = '0.14';

use warnings;
use strict;
use re 'eval';

use Filter::Simple;

my $IDENT            = qr{ (?> [^\W\d] \w* )            }xms;
my $QUAL_IDENT       = qr{ $IDENT (?: :: $IDENT)*       }xms;
my $TO_EOL           = qr{ (?> [^\n]* ) (?:\Z|\n)       }xms;
my $HWS              = qr{ (?> [^\S\n]+ )               }xms;
my $OHWS             = qr{ (?> [^\S\n]* )               }xms;
my $BLANK_LINE       = qr{ ^ $OHWS $ | (?= ^ =)         }xms;
my $DIRECTIVE        = qr{ config | encoding | use      }xms;
my $OPT_EXTRA_CONFIG = qr{ (?> (?: ^ = $HWS $TO_EOL)* ) }xms;


# Recursive matcher for =DATA sections...

my $DATA_PAT = qr{
    ^ = 
    (?:
        begin $HWS DATA $TO_EOL
        $OPT_EXTRA_CONFIG
            (.*?)
        ^ =end $HWS DATA
    |
        for $HWS DATA $TO_EOL
        $OPT_EXTRA_CONFIG
            (.*?)
        $BLANK_LINE
    |
        DATA \s
            (.*?)
        $BLANK_LINE
    )
}xms;


# Recursive matcher for all other Perldoc sections...

my $POD_PAT; $POD_PAT = qr{
    ^ =
    (?:
        (?:(?:begin|for) $HWS)? END
        (?> .*) \z
    |
        begin $HWS ($IDENT) (?{ local $type = $^N}) $TO_EOL
        $OPT_EXTRA_CONFIG
            (?: ^ (??{$POD_PAT}) | . )*?
        ^ =end $HWS (??{$type}) $TO_EOL
    |
        for $HWS $TO_EOL
        $OPT_EXTRA_CONFIG
            .*?
        $BLANK_LINE
    |
        ^ $DIRECTIVE $HWS $TO_EOL
        $OPT_EXTRA_CONFIG
    |
        ^ (?! =end) =$IDENT $HWS $TO_EOL
            .*?
        $BLANK_LINE
    |
        $IDENT $TO_EOL
            .*?
        $BLANK_LINE
    )
}xms;

FILTER {
    my @DATA;

    # Extract DATA sections, deleting them but preserving line numbering...
    s{ ($DATA_PAT) }{
        my ($data_block, $contents) = ($1,$+);

        # Special newline handling required under Windows...
        if ($^O =~ /MSWin/) {
            $contents =~ s{ \r\n }{\n}gxms;
        }

        # Save the data...
        push @DATA, $contents;

        # Delete it from the source code, but leave the newlines...
        $data_block =~ tr[\n\0-\377][\n]d;

        $data_block;
    }gxmse;

    # Collect all declared package names...
    my %packages = (main=>1);
    s{ (\s* package \s+ ($QUAL_IDENT)) }{
        my ($package_decl, $package_name) = ($1,$2);
        $packages{$package_name} = 1;
        $package_decl;
    }gxmse;

    # Delete all other pod sections, preserving newlines...
    s{ ($POD_PAT) }{ my $text = $1; $text =~ tr[\n\0-\377][\n]d; $text }gxmse;

    # Consolidate data and open a filehandle to it...
    local *DATA_glob;
    my $DATA_as_str = join q{}, @DATA;
    *DATA_glob = \$DATA_as_str;
    *DATA_glob = \@DATA;
    open *DATA_glob, '<', \$DATA_as_str
        or require Carp
        and croak( "Can't set up *DATA handle ($!)" );

    # Alias each package's *DATA, @DATA, and $DATA...
    for my $package (keys %packages) {
        no strict 'refs'; 
        *{$package.'::DATA'} = *DATA_glob;
    }
#    warn "OUTPUT:". $_ ."<<<";

}


1;
__END__


=head1 SEE ALSO

L<http://perlcabal.org/syn/S26.html>

=head1 AUTHOR

Zahatski Aliaksandr, <zag@cpan.org>

(Perl6::Pod derived from Perl6::Perldoc by Damian Conway  C<< <DCONWAY@CPAN.org> >>)


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

