package Perl6::Pod::Parser::Context;
use warnings;
use strict;
use Perl6::Pod::Directive::use;
use Perl6::Pod::Directive::config;
use Perl6::Pod::Block::comment;
use Perl6::Pod::Block::code;
use Perl6::Pod::Block::pod;
use Perl6::Pod::Block::para;
use Perl6::Pod::Block::table;
use Perl6::Pod::FormattingCode::M;
use Perl6::Pod::FormattingCode::L;

use Tie::UnionHash;
use Data::Dumper;
our $IDENT = qr{ [^\W\d]\w* }xms;
our $BALANCED_BRACKETS;
$BALANCED_BRACKETS = qr{  <   (?: (??{$BALANCED_BRACKETS}) | . )*?  >
                           | \[   (?: (??{$BALANCED_BRACKETS}) | . )*? \]
                           | \{   (?: (??{$BALANCED_BRACKETS}) | . )*? \}
                           | \(   (?: (??{$BALANCED_BRACKETS}) | . )*? \)
                           | \xAB (?: (??{$BALANCED_BRACKETS}) | . )*? \xBB
                           }xms;

my $OPTION_EXTRACT = qr{ :()($IDENT)($BALANCED_BRACKETS?) | :(!)($IDENT)() }xms;

use constant {
    DEFAULT_USE => {
        use     => 'Perl6::Pod::Directive::use',
        config  => 'Perl6::Pod::Directive::config',
        comment => 'Perl6::Pod::Block::comment',
        code    => 'Perl6::Pod::Block::code',
        pod     => 'Perl6::Pod::Block::pod',
        para    => 'Perl6::Pod::Block::para',
        table   => 'Perl6::Pod::Block::table',
        'M<>'   => 'Perl6::Pod::FormattingCode::M',
        'L<>'   => 'Perl6::Pod::FormattingCode::L'
    }
};

=head2 new [ <parent context ref>]

=cut

sub new {
    my $class = shift;
    $class = ref $class if ref $class;

    #set default contexts
    my %args = (
        _usef     => {},
        _use      => DEFAULT_USE,
        _config   => {},
        _encoding => 'UTF-8',
        _custom   => {},
        @_
    );

    #create union hashes
    while ( my ( $key, $val ) = each %args ) {
        next unless ( ref($val) || ref($val) eq 'HASH' );
        my %new_map = ();
        tie %new_map, 'Tie::UnionHash', $val, {};
        $args{$key} = \%new_map;

    }
    my $self = bless( \%args, $class );
    return $self;
}

=head2 sub_context

create sub_context

=cut

sub sub_context {
    my $self = shift;
    return __PACKAGE__->new(%$self);
}

=head2 config

return ref to hash of pod options per blockname

=cut

sub config {
    return $_[0]->{_config};
}

=head2 usef

return ref to hash of plugin  per formatcode name

=cut

sub usef {
    return $_[0]->{_usef};
}

=head2 use

return ref to hash of perl module per blockname

=cut

sub use {
    return $_[0]->{_use};
}

=head2 custom

return ref to hash of user defined keys,vals

=cut

sub custom {
    return $_[0]->{_custom};
}



=head2 set_use <module_name>, ':config_options'

=cut

sub set_use {
    my $self = shift;
    my ( $name, $opt ) = @_;

    #now cut block_name
    my ( $b1, @bn ) = @{ $self->_opt2array($opt) };
    my $key = $b1->{name};
    my $block_opt = join " " => map { $_->{pod} } @bn;
    $self->use->{$key} = $name;
    $self->{_use_init}->{$name} = $block_opt;
    return { $key => $block_opt };
}

=head2 encoding

return ref to hash of pod options per blockname

=cut

sub encoding {
    return $_[0]->{_encoding};
}

sub _opt2array {
    my $self = shift;
    my $str  = shift;
    return {} if $str !~ /\S/;

    my @opts =
      grep { defined } $str =~ m/$OPTION_EXTRACT/xgm;
    my @options = ();
    while ( my ( $neg, $key, $val ) = splice @opts, 0, 3 ) {
        my $type = undef;
        my $eval = '';

        #determine type of attr
        if ($neg) {
            $type = 'Boolean';
            $eval = 0;
        }
        else {
            if ( !length $val ) {
                $type = 'Boolean';
                $eval = 1;
            }
            else {
                for ($val) {
                    /^ \((.*)\) $/xms
                      && do { $type = 'String'; $eval = eval($1) }
                      || /^(\[ .* \])$/xms
                      && do { $type = 'List'; $eval = eval($1) }
                      || /^(\{ .* \})$/xms
                      && do { $type = 'Hash'; $eval = eval($1) }
                      || /^ \<\s*(.*?)\s*\> $/xms
                      && do { $eval = [ split /\s+/, $1 ] }
                }

            }

        }
        warn "$!" if $!;
        push @options,
          {
            name  => $key,
            value => $eval,
            pod   => ":${neg}${key}${val}",
            src   => $val,
            type  => $type
          };
    }
    return \@options;
}

=head2 _opt2hash <pod opt string>

Convert pod opt string to hash

=cut

sub _opt2hash {
    my $self = shift;
    my $str  = shift;
    return {} if $str !~ /\S/;

    my @opts =
      grep { defined } $str =~ m/$OPTION_EXTRACT/xgm;
    my %options = ();
    while ( my ( $neg, $key, $val ) = splice @opts, 0, 3 ) {
        my $type = undef;
        my $eval = '';
        local $!;

        #determine type of attr
        if ($neg) {
            $type = 'Boolean';
            $eval = 0;
        }
        else {
            if ( !length $val ) {
                $type = 'Boolean';
                $eval = 1;
            }
            else {
                for ($val) {
                    /^ \((.*)\) $/xms
                      && do { $type = 'String'; $eval = eval($1) }
                      || /^(\[ .* \])$/xms
                      && do { $type = 'List'; $eval = eval($1) }
                      || /^(\{ .* \})$/xms
                      && do { $type = 'Hash'; $eval = eval($1) }
                      || /^ \<\s*(.*?)\s*\> $/xms
                      && do { $eval = [ split /\s+/, $1 ] }
                }

            }

        }
        warn "$! for >$1<" if $!;
        $options{$key} = { value => $eval, src => $val, type => $type };
    }
    return \%options;
}

=head2 _hash2opt 

Convert hash to opt string


    'we' => {
        'value' => '12 3 asdas a',
      'type'  => 'String'
    }



=cut

sub _hash2opt {
    my $self  = shift;
    my %attrs = @_;
    my @strs  = ();
    while ( my ( $key, $val ) = each %attrs ) {
        my $value   = $val->{value};
        my $ref     = ref $value;
        my $pod_str = '';
        if ( $ref eq 'ARRAY' ) {
            $pod_str = ":${key}[" . join( ",", map { "'$_'" } @$value ) . "]";
        }
        elsif ( $ref eq 'HASH' ) {
            $pod_str = ":${key}{"
              . join( ",", map { "'$_'=>'$$value{$_}'" } keys %$value ) . "}";
        }
        else {
            if ( exists $val->{type} ) {
                for ( $val->{type} ) {
                    /Boolean/
                      && do { $pod_str = $value ? ":${key}" : ':!' . $key }
                      || /List/ && do {
                        $pod_str =
                          $self->_hash2opt(
                            $key => { type => 'List', value => [$value] } );
                      }
                      || /String/ && do {
                        $pod_str = ":${key}('$value')";
                      }
                      || /Hash/ && do { die "Not valide Hash for key: $key" }
                }
            }
            else {
                if ( !defined($value) ) {
                    $pod_str =
                      $self->_hash2opt(
                        $key => { type => 'Boolean', value => 0 } );
                }
                elsif ( $value =~ /^0|1$/ ) {
                    $pod_str =
                      $self->_hash2opt(
                        $key => { type => 'Boolean', value => $value } );
                }
                else {

                    $pod_str =
                      $self->_hash2opt(
                        $key => { type => 'String', value => $value } );
                }
            }
        }

        push @strs, $pod_str;
    }
    return join " " => @strs;
}

=head2 get_attr <block_type>

Get options for B<block_type> in current context

    $c1->get_attr('item1');
=cut

sub get_attr {
    my $self  = shift;
    my $btype = shift;
    return {} unless exists $self->config->{$btype};
    my $hash = $self->_opt2hash( $self->config->{$btype} );
    my %res  = ();
    while ( my ( $key, $val ) = each %$hash ) {
        $res{$key} = $val->{value};
    }
    return \%res;
}

=head2 set_attr <block_type>, { attr1 =>1[, attr2=>2]}

Set  options for B<block_type> in current context

    $c1->set_attr('item1', { w=>[12] } );
=cut

#got array of attrs
sub set_attr {
    my $self  = shift;
    my $btype = shift;

    #get current state
    my $attr = shift;
    my %par  = ();
    while ( my ( $key, $val ) = each %$attr ) {
        $par{$key} = { value => $val };
    }
    my $opt = $self->_hash2opt(%par);
    $self->config->{$btype} = $opt;
    return $opt;
}

1;

