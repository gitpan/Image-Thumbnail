#! perl
our $VERSION = sprintf("%d.%02d", q$Revision: 0.1 $ =~ /(\d+)\.(\d+)/);
use strict;
use Test::Harness;
$Test::Harness::verbose = '';
$Test::Harness::switches = '';

exit;

__END__

runtests();
	't/imf.t',		# image magick file
	't/imo.t',		# image magick object
	't/imfa.t',	# image magick file with attributes
	't/gdo.t',		# gd from gd object
	't/gdf.t',		# gd from file
);


