# imf - Test ImageMagick from object
use strict;
our $VERSION = sprintf("%d.%02d", q$Revision: 0.02 $ =~ /(\d+)\.(\d+)/);
use Test;
use Image::Magick;
BEGIN { plan tests => 6 };
use Image::Thumbnail;
print "ok 1\n";

my $img = new Image::Magick;
$img->Read('t/test.jpg');
print "ok 2\n";

my $t = new Image::Thumbnail(
#	CHAT=>1,
	object=>$img,
	size=>55,
	create=>1,
	outputpath=>'test_t.jpg',
);
print "ok 3\n";
print $t->{x}==55? "ok 4\n" : "not ok 4\n";
print $t->{y}==49? "ok 5\n" : "not ok 5\n";
unlink("test_t.jpg") or print "not ok 6\n";
print "ok 6\n";
exit;
