# gdf - Test GD supply a filename write to file
use strict;
our $VERSION = sprintf("%d.%02d", q$Revision: 0.01 $ =~ /(\d+)\.(\d+)/);
use Test;
BEGIN { plan tests => 7 };
use Image::Thumbnail;
print "ok 1\n";

use GD;
print "ok 2\n";
my $t = new Image::Thumbnail(
#	CHAT=>1,
	module => "GD",
	inputpath => "t/test.jpg",
	size=>55,
	create=>1,
	outputpath=>'t/test_t.jpg',
);
print "ok 3\n";
print $t->{x}==55? "ok" : "not ok"; print " 4\n";
print $t->{y}==49? "ok" : "not ok"; print " 5\n";
unlink("t/test_t.jpg") and print "ok 6\n" or print "not ok 6\n";
print "ok 7\n";

exit;


