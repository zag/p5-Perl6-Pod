use Module::Build;
use 5.8.0;
Module::Build->new
    ( module_name => 'Perl6::Pod',
    license => 'perl',
   prereq => {
	'XML::Parser'=>'0',
	'XML::Writer'=>'0',
	'XML::ExtOn'=>'0',
	'XML::Flow'=>'0',
	'XML::SAX::Writer' => 0,
	'Encode'=>0,
	'Pod::Usage'=>0,
	'Getopt::Long'=>0,
	     },
    script_files=>[qw!
	scripts/pod6xml
    !],
   dist_version_from=>'lib/Perl6/Pod.pm',
   dist_author=>'Zahatski Aliaksandr zag@cpan.org',
    create_makefile_pl=>$ENV{DO_OUTCPAN} ? 'traditional':'passthrough'
    )->create_build_script;
