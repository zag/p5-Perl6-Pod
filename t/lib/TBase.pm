#===============================================================================
#  DESCRIPTION:  Base class for tests
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zahatski@gmail.com>
#===============================================================================
package TBase;
use strict;
use warnings;
use base 'Test::Class';
use Test::More;
use Perl6::Pod::To::Mem;
use XML::ExtOn ('create_pipe');
sub testing_class {
     my $test = shift;
     ( my $class = ref $test ) =~ s/^T[^:]*::/Perl6::Pod::/;
     return $class 
}

sub new_args { ()};


sub _use : Test(startup=>1) {
    my $test = shift;
    use_ok $test->testing_class;
}

=head2 parse_mem \$pod_str, ['filter1']

return out_put from To::Mem formatter

=cut

sub parse_mem {
    my $test = shift;
    my ($text, @filters) = @_;
    my $out = [];
    my $to_mem  = new Perl6::Pod::To::Mem:: out_put=>$out;
    my ( $p, $f ) = $test->make_parser(@filters,$to_mem);
    $p->parse( \$text );
    return wantarray ? ( $p, $f, $out ) : $out;

}


sub make_parser {
    my $test = shift;
    unless (@_) {
    my $class = $test->testing_class;
    my @args = $test->new_args;
    my $obj = $class->new( @args );
    push @_, $obj
    }
    my $out_formatter = $_[-1];
    my $p = create_pipe( 'Perl6::Pod::Parser', @_ );
    return wantarray ? ( $p, $out_formatter ) : $p;

}    

sub startup : Test(startup) {
#    ok (1,'s1')
}


1;

