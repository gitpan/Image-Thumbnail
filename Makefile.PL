use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

foreach ('Image::Magick','GD'){
	print "Looking for $_ ... ";
	eval "require "."$_";
	if ($@){
		print "not found\n";
	} else {
		print "ok\n";
		$ok = 1;
		last;
	}
}


if (not $ok){
	print <<_STOP_

This module requires you have installed on your system
either the GD or Image::Magick Perl modules.

Please install one or the other, and try again.

If you feel this message to be in error, please contact
Lee at LGoddard -at- CPAN -dot- org.

_STOP_

} else {
	WriteMakefile(
		'NAME'		=> 'Image::Thumbnail',
		'VERSION_FROM'	=> 'Thumbnail.pm', # finds $VERSION
		'PREREQ_PM'		=> {Test::Harness=>0.1,}, # e.g., Module::Name => 1.1
		($] >= 5.005 ?    ## Add these new keywords supported since 5.005
		  (ABSTRACT_FROM => 'Thumbnail.pm', # retrieve abstract from module
		   AUTHOR     => 'Lee Goddard <lgoddard -at- cpan -dot- org>') : ()),
	);
}
exit;
