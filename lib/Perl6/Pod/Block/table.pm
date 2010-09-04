package Perl6::Pod::Block::table;

#$Id$

=pod

=head1 NAME

Perl6::Pod::Block::table  - Simple tables

=head1 SYNOPSIS

    =table
        The Shoveller   Eddie Stevens     King Arthur's singing shovel   
        Blue Raja       Geoffrey Smith    Master of cutlery              
        Mr Furious      Roy Orson         Ticking time bomb of fury      
        The Bowler      Carol Pinnsler    Haunted bowling ball           


    =for table :caption('Tales in verse')
     Year  |                Name
     ======+==========================================
     1830  | The Tale of the Priest and of His Workman Balda
     1830  | The Tale of the Female Bear 
     1831  | The Tale of Tsar Saltan
     1833  | The Tale of the Fisherman and the Fish
     1833  | The Tale of the Dead Princess
     1834  | The Tale of the Golden Cockerel

=head1 DESCRIPTION

Simple tables can be specified in Perldoc using a =table block. The table may be given an associated description or title using the :caption option. 

Each individual table cell is separately formatted, as if it were a nested =para.

Columns are separated by whitespace (by regex {2,}), vertical lines (|), or border intersections (+). Rows can be specified in one of two ways: either one row per line, with no separators; or multiple lines per row with explicit horizontal separators (whitespace, intersections (+), or horizontal lines: -, =, _) between every row. Either style can also have an explicitly separated header row at the top. 

Each individual table cell is separately formatted, as if it were a nested =para.

This means you can create tables compactly, line-by-line:

    =table
        The Shoveller   Eddie Stevens     King Arthur's singing shovel   
        Blue Raja       Geoffrey Smith    Master of cutlery              
        Mr Furious      Roy Orson         Ticking time bomb of fury      
        The Bowler      Carol Pinnsler    Haunted bowling ball           


or line-by-line with multi-line headers:

    =table
        Superhero     | Secret          | 
                      | Identity        | Superpower 
        ==============|=================+================================
        The Shoveller | Eddie Stevens   | King Arthur's singing shovel   
        Blue Raja     | Geoffrey Smith  | Master of cutlery              
        Mr Furious    | Roy Orson       | Ticking time bomb of fury      
        The Bowler    | Carol Pinnsler  | Haunted bowling ball           
=cut

use warnings;
use strict;
use Data::Dumper;
use Test::More;
use Perl6::Pod::Block;
use base 'Perl6::Pod::Block';
use constant {
    NEW_LINE           => qr/^ \s* $/xms,
    COLUMNS_SEPARATE   => qr/\s*\|\s*|[\ ]{2,}/xms,
    COLUMNS_FORMAT_ROW => qr/(\s+)?[\=\-]+[\=\-\+\n]+(\s+)?/xms,
    COLUMNS_FORMAT_ROW_SEPARATE   => qr/\s*\|\s*|\+|[\ ]{2,}/xms,
};

sub end {
    my ( $self, $parser, $attr ) = @_;
    return;
}

sub _get_count_cols {
    my $self      = shift;
    my $txt       = shift;
    my $row_count = 1;

    # calculate count of fields
    foreach my $line ( split /\n/, $txt ) {

        # clean begin and end of line
        $line =~ s/^\s*//;
        $line =~ s/\s*$//;
        my @columns = split( /${\( COLUMNS_SEPARATE )}/, $line );

        #try find format line
        # ---------|-----------, =====+=======
        if ( $line =~ /${\( COLUMNS_FORMAT_ROW )}/ ) {
            @columns = split( /${\( COLUMNS_FORMAT_ROW_SEPARATE )}/, $line );
            $row_count = scalar(@columns);
            $self->{NEED_NEAD}++;
            last;
        }

        #update max row_column
        $row_count =
          scalar(@columns) > $row_count ? scalar(@columns) : $row_count;
    }
    return $row_count;
}

sub _make_row {
    my $self = shift;
    my $rows = shift;
    for (@$rows) { $_ = join " ", @{ $_ || [] } }
    return { data => [@$rows], type => 'row' };

}

sub _make_head_row {
    my $self = shift;
    my $res  = $self->_make_row(@_);
    $res->{type} = 'head';
    delete $self->{NEED_NEAD};
    return $res;
}

sub _make_events {
    my $self         = shift;
    my $parser       = shift;
    my $table_rows   = shift;
    my @res          = ();
    my $current_type = "";

    #make head
    if ( $table_rows->[0]->{type} eq 'head' ) {

        # get head row
        my $row         = shift @$table_rows;
        my $type        = $row->{type};
        my $start_thead = $self->mk_block("table");
        $start_thead->attrs_by_name->{table_type} = "${type}_start";
        $parser->start_block( $start_thead, '', 0 );

        my $thead = $self->mk_block("table");
        $thead->attrs_by_name->{table_type} = $type;

        #make rows
        $parser->start_block( $thead, '', 0 );
        foreach my $column ( @{ $row->{data} } ) {
            my $col = $self->mk_block("table");
            $col->attrs_by_name->{table_type} = "${type}_column";
            $parser->start_block( $col, '', 0 );
            $parser->para($column);
            $parser->end_block( $col, '', 0 );
        }
        $parser->end_block( $thead, '', 0 );

        $parser->end_block( $start_thead, '', 0 );
    }
    my $start_body = $self->mk_block("table");
    $start_body->attrs_by_name->{table_type} = "body_start";
    $parser->start_block( $start_body, '', 0 );

    foreach my $row (@$table_rows) {
        my $type  = $row->{type};
        my $thead = $self->mk_block("table");
        $thead->attrs_by_name->{table_type} = $type;

        #make rows
        $parser->start_block( $thead, '', 0 );
        foreach my $column ( @{ $row->{data} } ) {
            my $col = $self->mk_block("table");
            $col->attrs_by_name->{table_type} = "${type}_column";
            $parser->start_block( $col, '', 0 );
            $parser->para($column);
            $parser->end_block( $col, '', 0 );
        }
        $parser->end_block( $thead, '', 0 );
    }
    $parser->end_block( $start_body, '', 0 );
    return \@res;
}

sub on_para {
    my ( $self, $parser, $txt ) = @_;
    if ( exists $self->attrs_by_name->{table_type} ) {
        return $self->SUPER::on_para( $parser, $txt );
    }

    #$self->{TABLE} .= $txt."\n";
    my $i++;
    my @res_rows  = ();
    my @rows      = ();
    my $col_count = $self->_get_count_cols($txt);
    $self->attrs_by_name->{table_row_count} = $col_count;
    foreach my $line ( split /\n/, $txt ) {

        # clean begin and end of line
        $line =~ s/^\s*//;
        $line =~ s/\s*$//;

        #if row separate line ?
        if ( $line =~ /${\( COLUMNS_FORMAT_ROW )}$|^\s*$/ ) {

            #skip duble row delim
            next if scalar(@rows) == 0;
            push @res_rows,
              $line =~ /${\( COLUMNS_FORMAT_ROW )}$/
              ? $self->_make_head_row( \@rows )
              : $self->_make_row( \@rows );
            @rows = ();
        }
        else {
            my @colums = split( /${\( COLUMNS_SEPARATE )}/, $line );
            $i++;
            for ( my $n = 0 ; $n <= $#colums ; $n++ ) {
                push @{ $rows[$n] }, defined ($colums[$n]) ? $colums[$n] : '';
            }
            if ( @colums == $col_count and !$self->{NEED_NEAD} ) {
                push @res_rows, $self->_make_row( \@rows );
                @rows = ();
            }
        }
    }
    return $self->_make_events( $parser, \@res_rows );
}

sub to_xhtml {
    my $self    = shift;
    my $parser  = shift;
    my $type    = $self->attrs_by_name->{table_type} || '';
    my @content = $parser->_make_events(@_);
    my @res;
    for ($type) {
        /(row|head)$/ && do {
            push @res, $parser->mk_element('tr')->add_content(@content);
          }
          || /head_column/ && do {
            push @res, $parser->mk_element('th')->add_content(@content);
          }
          || /row_column/ && do {
            push @res, $parser->mk_element('td')->add_content(@content);
          }
          || /head_start|body_start/ && do {    #nothing
            push @res,
              $parser->mk_element('table')->add_content(@content)
              ->delete_element;
          }
          || do {

            #make caption table element
            if ( my $caption = $self->get_attr->{caption} ) {
                unshift @content,
                  $parser->mk_element('caption')
                  ->add_content( $parser->mk_characters($caption) );
            }
            push @res, $parser->mk_element('table')->add_content(@content);
          }
    }
    return \@res;
}

sub to_docbook {
    my $self    = shift;
    my $parser  = shift;
    my $type    = $self->attrs_by_name->{table_type} || '';
    my @content = $parser->_make_events(@_);
    my @res;
    for ($type) {
        /(head)$/ && do {
            push @res, $parser->mk_element('row')->add_content(@content);
          }
          || /head_column/ && do {
            push @res, $parser->mk_element('entry')->add_content(@content);
          }
          || /(row)$/ && do {
            push @res, $parser->mk_element('row')->add_content(@content);
          }
          || /row_column/ && do {
            push @res, $parser->mk_element('entry')->add_content(@content);
          }
          || /body_start/ && do {    #nothing
            push @res,
              $parser->mk_element('tbody')->add_content(@content)
          }
          || /head_start/ && do {    #nothing
            push @res,
              $parser->mk_element('thead')->add_content(@content)
          }
          || do {

            
            my $table = $parser->mk_element('table'); 
            #make caption table element
            if ( my $caption = $self->get_attr->{caption} ) {
            $table->add_content(
                  $parser->mk_element('title')
                  ->add_content( $parser->mk_characters($caption) ) );
            }
            #add tgroup
            my $tgroup = $parser->mk_element('tgroup')->add_content(@content);
            my $count_col = $self->attrs_by_name->{table_row_count};

            $tgroup->attrs_by_name->{cols} = $count_col;
            $tgroup->attrs_by_name->{align} = 'center';

            push @res, $table->add_content($tgroup);
          }
    }
    return \@res;
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

