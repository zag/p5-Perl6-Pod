package Perl6::Pod::To;

#$Id$

=pod

=head1 NAME

Perl6::Pod::To - base class for output formatters

=head1 SYNOPSIS


=head1 DESCRIPTION

Perl6::Pod::To - base class for output formatters

=cut

use Carp;
use Perl6::Pod::Autoactions;
use Perl6::Pod::Utl::AbstractVisiter;
use base 'Perl6::Pod::Utl::AbstractVisiter';

=pod
        use     => 'Perl6::Pod::Directive::use',
        config  => 'Perl6::Pod::Directive::config',
        comment => 'Perl6::Pod::Block::comment',
        alias   => 'Perl6::Pod::Directive::alias',
        code    => 'Perl6::Pod::Block::code',
        pod     => 'Perl6::Pod::Block::pod',
        para    => 'Perl6::Pod::Block::para',
        table   => 'Perl6::Pod::Block::table',
        output  => 'Perl6::Pod::Block::output',
        input   => 'Perl6::Pod::Block::input',
        nested  => 'Perl6::Pod::Block::nested',
        item    => 'Perl6::Pod::Block::item',
        defn    => 'Perl6::Pod::Block::item',
        '_NOTES_'   => 'Perl6::Pod::Parser::NOTES',
        'C<>'   => 'Perl6::Pod::FormattingCode::C',
        'D<>'   => 'Perl6::Pod::FormattingCode::D',
        'K<>'   => 'Perl6::Pod::FormattingCode::K',
        'M<>'   => 'Perl6::Pod::FormattingCode::M',
        'L<>'   => 'Perl6::Pod::FormattingCode::L',
        'B<>'   => 'Perl6::Pod::FormattingCode::B',
        'I<>'   => 'Perl6::Pod::FormattingCode::I',
        'X<>'   => 'Perl6::Pod::FormattingCode::X',

        #        'P<>'   => 'Perl6::Pod::FormattingCode::P',
        'U<>' => 'Perl6::Pod::FormattingCode::U',
        'E<>' => 'Perl6::Pod::FormattingCode::E',
        'N<>' => 'Perl6::Pod::FormattingCode::N',
        'A<>' => 'Perl6::Pod::FormattingCode::A',
        'R<>' => 'Perl6::Pod::FormattingCode::R',
        'S<>' => 'Perl6::Pod::FormattingCode::S',
        'T<>' => 'Perl6::Pod::FormattingCode::T',
        'V<>' => 'Perl6::Pod::FormattingCode::C', #V like C
        'Z<>' => 'Perl6::Pod::FormattingCode::Z',
=cut

use constant {
    DEFAULT_USE => {
        'File' => '-',
        'para' => 'Perl6::Pod::Block::para',
        '*'    => 'Perl6::Pod::Block',
        '*<>'  => 'Perl6::Pod::FormattingCode',
    }
};

sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
    # check if exists context
    # create them instead
    unless ( $self->context ) {
        use Perl6::Pod::Utl::Context;
        $self->context( new Perl6::Pod::Utl::Context:: )
    }
    $self;
}

sub writer {
    return $_[0]->{writer};
}

sub w {
    return $_[0]->writer;
}

sub context {
    my $self = shift;
    if ($#_ > 0) {
        $self->{context} = shift;
    }
    return $self->{context}
}
#TODO then visit to child -> create new context !
sub visit_childs {
    my $self = shift;
    foreach my $n (@_) {
        die "Unknow type $n (not isa Perl6::Pod::Block)"
          unless UNIVERSAL::isa( $n, 'Perl6::Pod::Block' )
              || UNIVERSAL::isa( $n, 'Perl6::Pod::Lex::Block' );
        foreach my $ch ( @{ $n->childs } ) {
            $self->visit($ch);
        }
    }
}

sub visit {
    my $self = shift;
    my $n    = shift;

    if ( ref($n) eq 'ARRAY' ) {
        $self->visit($_) for @$n;
        return;
    }

    # if string -> paragraph
    unless ( ref($n) ) {
            return $self->w->print($n)
    }

    die "Unknown node type $n (not isa Perl6::Pod::Lex::Block)"
      unless UNIVERSAL::isa( $n, 'Perl6::Pod::Lex::Block' );

    # here convert lexer base block to
    # instance of DOM class
    my $name = $n->name;
    my $map  = DEFAULT_USE;
    my $class;

    #convert lexer blocks
    unless ( UNIVERSAL::isa( $n, 'Perl6::Pod::Block' ) ) {

        my %additional_attr = ();
        if ( UNIVERSAL::isa( $n, 'Perl6::Pod::Lex::FormattingCode' ) ) {
            $class = $map->{ $name . '<>' } || $map->{'*<>'};
        }

        # UNIVERSAL::isa( $n, 'Perl6::Pod::Lex::Block' )
        else {

            # convert item1, head1 -> item, head
            if ( $name =~ /(item|head)(\d+)/ ) {
                $name = $1;
                $additional_attr{level} = $2;
            }
            elsif ( $name =~ /(para|code)/ ) {

                # add { name=>$name }
                # for text and code blocks
#                use Data::Dumper;
#                warn Dumper $n;
                $additional_attr{name} = $name;
            }

            $class = $map->{$name} || $map->{'*'};
        }

        #create instance
        my $el =
            $class eq '-'
          ? $n
          : $class->new( %$n, %additional_attr, context => $self->context );

        #if no instanse -> skip this element
        return undef unless ($el);
        $n = $el;
    }
    my $method = $self->__get_method_name($n);
    #make method name
    $self->$method($n);
}

sub __get_method_name {
    my $self = shift;
    my $el = shift || croak "empty object !";
    my $method;
    use Data::Dumper;
    my $name = $el->name || die "Can't get element name for " . Dumper($el);
    if ( UNIVERSAL::isa( $el, 'Perl6::Pod::FormattingCode' ) ) {
        $method = "code_$name";
    }
    else {
        $method = "block_$name";
    }
    return $method;
}

sub block_File {
    my $self = shift;
    return $self->visit_childs(@_);
}

sub block_pod {
    my $self = shift;
    return $self->visit_childs(@_);
}

sub parse_blocks {
    my $self = shift;
    my $text = shift;
    my $r    = do {
        use Regexp::Grammars;
        use Perl6::Pod::Grammars;
        qr{
       <extends: Perl6::Pod::Grammar::Blocks>
       <matchline>
        \A <File> \Z
    }xms;
    };
    if ( $text =~ $r->with_actions( Perl6::Pod::Autoactions->new ) ) {
        return {%/}->{File};
    }
    else {

        #    die "Can't parse";
        undef;
    }
}

sub __default_method {
    my $self   = shift;
    my $n      = shift;
    warn "get default name for $n";
    my $method = $self->__get_method_name($n);
    die ref($self)
      . ": Method '$method' for class "
      . ref($n)
      . " not implemented at ";
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


