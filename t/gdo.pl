# imf - Test GD supply an object write to file
our $VERSION = sprintf("%d.%02d", q$Revision: 0.02 $ =~ /(\d+)\.(\d+)/);
use lib "..";
use strict;
use Test::More;

use Cwd;
my $cwd = cwd;
$cwd .= '/t/' if $cwd !~ /[\\\/]t[\\\/]?$/;

eval'use GD';
if ( $@) {
	 plan skip_all => "Skip GD tests - GD not installed";
} else {
	plan tests => 6;
}
use_ok ("Image::Thumbnail");
use_ok( 'GD');

SKIP: {
	skip "No test file at ${cwd}/test.jpg", 4 unless open IN, $cwd.'/test.jpg';
	my $img = GD::Image->newFromJpeg(*IN);
	close IN;
	isa_ok ($img, "GD::Image");
	my $t = new Image::Thumbnail(
	#	CHAT =>1,
		object=>$img,
		module => "GD",
		size=>55,
		create=>1,
		outputpath=>'test_t.jpg',
	);
	isa_ok ($img, "GD::Image");
	ok( $t->{x}==55,"x");
	ok( $t->{y}==49,"y");
	unlink("test_t.jpg");
};

