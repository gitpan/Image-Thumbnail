# gdf - Test GD supply a filename write to file
use strict;
our $VERSION = sprintf("%d.%02d", q$Revision: 0.01 $ =~ /(\d+)\.(\d+)/);
use Test;
BEGIN { plan tests => 5 };
use Image::Thumbnail;
print "ok 1\n";

my $t = new Image::Thumbnail(
#	CHAT=>1,
	module => "GD",
	inputpath => "t/test.jpg",
	size=>55,
	create=>1,
	outputpath=>'t/test_t.jpg',
);
print "ok 2\n";
print $t->{x}==55? "ok" : "not ok"; print " 3\n";
print $t->{y}==49? "ok" : "not ok"; print " 4\n";
unlink("t/test_t.jpg") or print "not ok 5\n";
print "ok 5\n";
exit;


