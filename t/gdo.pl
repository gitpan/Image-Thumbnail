# imf - Test GD supply an object write to file
use strict;
our $VERSION = sprintf("%d.%02d", q$Revision: 0.01 $ =~ /(\d+)\.(\d+)/);
use Test;
BEGIN { plan tests => 5 };
use GD;

use Image::Thumbnail;
print "ok 1\n";

open IN, 't/test.jpg'  or print "not ok 2\n" and die;
my $img = GD::Image->newFromJpeg(*IN);
close IN;

my $t = new Image::Thumbnail(
#	CHAT =>1,
	object=>$img,
	module => "GD",
	size=>55,
	create=>1,
	outputpath=>'test_t.jpg',
);
print "ok 2\n";
print $t->{x}==55? "ok 3\n" : "not ok 3\n";
print $t->{y}==49? "ok 4\n" : "not ok 4\n";
unlink("test_t.jpg") or print "not ok 5\n";
print "ok 5\n";
exit;


