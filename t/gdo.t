# imf - Test GD supply an object write to file
use strict;
our $VERSION = sprintf("%d.%02d", q$Revision: 0.01 $ =~ /(\d+)\.(\d+)/);
use Test;
BEGIN { plan tests => 6 };
use GD;

use Image::Thumbnail;
print "ok 1\n";

eval "require GD";
if (!$@){
	open IN, 't/test.jpg'  or print "not ok 2\n" and die;
	print "ok 2\n";
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
	print "ok 3\n";
	print $t->{x}==55? "ok 4\n" : "not ok 4\n";
	print $t->{y}==49? "ok 5\n" : "not ok 5\n";
	unlink("test_t.jpg") and print "ok 6\n" or print "not ok 6\n";
} else {
	for (2..6){
		print "skip $_ (No GD)\n";
	}
}
exit;


