# imfa - Test ImageMagick to/from file with attributes
use strict;
our $VERSION = sprintf("%d.%02d", q$Revision: 0.02 $ =~ /(\d+)\.(\d+)/);
use Test;
BEGIN { plan tests => 5 };
use Image::Thumbnail;
print "ok 1\n";
my $t = new Image::Thumbnail(
#	CHAT=>1,
	size=>55,
	create=>1,
	inputpath=>'t/test.jpg',
	outputpath=>'t/test_t.jpg',
	attr=> {
		antialias => 'true',
	}
);
if ($t->{x}){
	print "ok 2\n";
} else {
	print "not ok 2\n";
}
print $t->{x}==55? "ok 3\n" : "not ok 3\n";
print $t->{y}==49? "ok 4\n" : "not ok 4\n";
unlink("t/test_t.jpg") or print "not ok 5\n";
print "ok 5\n";
exit;
