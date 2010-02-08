#===============================================================================
#
#  DESCRIPTION:  test for =table 
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
package T::Block::table;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use Perl6::Pod::To::XHTML;
use XML::ExtOn('create_pipe');
use base 'TBase';

sub c01_table_xml : Test {
    my $t = shift;
    my $x = $t->parse_to_xml (<<T);
=begin pod
=begin table
= :w<2>
        Superhero     | Secret          | 
                      | Identity        | Superpower 
        ==============|=================+================================
        The Shoveller | Eddie Stevens   | King Arthur's singing shovel

        Blue Raja     | Geoffrey Smith  | Master of cutlery              
        Mr Furious    | Roy Orson       | Ticking time bomb of fury      
        The Bowler    | Carol Pinnsler     Haunted bowling ball           
=end table
=end pod
T
$t->is_deeply_xml( $x,
q#<?xml version="1.0"?>
<pod xmlns:pod="http://perlcabal.org/syn/S26.html" pod:type="block">
  <table w="2" pod:type="block" pod:table_row_count="3">
    <table pod:type="block" pod:table_type="head_start">
      <table pod:type="block" pod:table_type="head">
        <table pod:type="block" pod:table_type="head_column">Superhero </table>
        <table pod:type="block" pod:table_type="head_column">Secret Identity</table>
        <table pod:type="block" pod:table_type="head_column">Superpower</table>
      </table>
    </table>
    <table pod:type="block" pod:table_type="body_start">
      <table pod:type="block" pod:table_type="row">
        <table pod:type="block" pod:table_type="row_column">The Shoveller</table>
        <table pod:type="block" pod:table_type="row_column">Eddie Stevens</table>
        <table pod:type="block" pod:table_type="row_column">King Arthur's singing shovel</table>
      </table>
      <table pod:type="block" pod:table_type="row">
        <table pod:type="block" pod:table_type="row_column">Blue Raja</table>
        <table pod:type="block" pod:table_type="row_column">Geoffrey Smith</table>
        <table pod:type="block" pod:table_type="row_column">Master of cutlery</table>
      </table>
      <table pod:type="block" pod:table_type="row">
        <table pod:type="block" pod:table_type="row_column">Mr Furious</table>
        <table pod:type="block" pod:table_type="row_column">Roy Orson</table>
        <table pod:type="block" pod:table_type="row_column">Ticking time bomb of fury</table>
      </table>
      <table pod:type="block" pod:table_type="row">
        <table pod:type="block" pod:table_type="row_column">The Bowler</table>
        <table pod:type="block" pod:table_type="row_column">Carol Pinnsler</table>
        <table pod:type="block" pod:table_type="row_column">Haunted bowling ball</table>
      </table>
    </table>
  </table>
</pod>
#)

}

sub c02_table_xhtml:Test {
    my $t = shift;
    my $x = $t->parse_to_xhtml (<<T);
=begin pod
=begin table :caption("a")
= :w<2>
        Superhero     | Secret          
        ==============|=================
        The Shoveller | Eddie Stevens   
=end table
=end pod
T
#diag $x; exit;

$t->is_deeply_xml( $x,
q#<?xml version="1.0"?>
<xhtml xmlns="http://www.w3.org/1999/xhtml">
  <table>
    <caption>a</caption>
    <tr>
      <th>Superhero</th>
      <th>Secret</th>
    </tr>
    <tr>
      <td>The Shoveller</td>
      <td>Eddie Stevens</td>
    </tr>
  </table>
</xhtml>
#)
}

sub c03_table_docbook:Test {
    my $t = shift;
    my $x = $t->parse_to_docbook (<<T);
=begin pod
=begin table :caption("a")
= :w<2>
        Superhero     | Secret          
        ==============|=================
        The Shoveller | Eddie Stevens   
=end table
=end pod
T
$t->is_deeply_xml ($x, q#<?xml version="1.0"?>
<chapter>
  <table>
    <title>a</title>
    <tgroup align='center' cols='2'>
    <thead>
      <row>
        <entry>Superhero</entry>
        <entry>Secret</entry>
      </row>
    </thead>
    <tbody>
      <row>
        <entry>The Shoveller</entry>
        <entry>Eddie Stevens</entry>
      </row>
    </tbody>
    </tgroup>
  </table>
</chapter>#)
}
1;

