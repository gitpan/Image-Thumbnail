#! perl
our $VERSION = sprintf("%d.%02d", q$Revision: 0.1 $ =~ /(\d+)\.(\d+)/);
use strict;
use Test::Harness;
$Test::Harness::verbose = '';
$Test::Harness::switches = '';

runtests(
	't/imf.pl',		# image magick file
	't/imo.pl',		# image magick object
	't/gdo.pl',		# gd from gd object
	't/gdf.pl',		# gd from file
);

exit;

