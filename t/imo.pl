# imf - Test ImageMagick from object
use strict;
our $VERSION = sprintf("%d.%02d", q$Revision: 0.02 $ =~ /(\d+)\.(\d+)/);
use Test::More;

eval'require Image::Magick';
if ( $@) {
	 plan skip_all => "Skip Image Magick tests - IM not installed";
} else {
	plan tests => 6;
}

use lib "..";
use_ok("Image::Thumbnail");

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

ok( defined $t->{x}, "Defined X");

ok ( $t->{x}==55, "x");
ok ( $t->{y}==49, "y");
unlink("test_t.jpg");
