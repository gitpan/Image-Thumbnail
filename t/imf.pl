# imf - Test ImageMagick to/from file
our $VERSION = sprintf("%d.%02d", q$Revision: 0.02 $ =~ /(\d+)\.(\d+)/);

use lib "..";
use strict;
use Test::More;

use Cwd;
my $cwd = cwd."/";

eval'use Image::Magick';
if ( $@) {
	 plan skip_all => "Skip IM tests - IM not installed";
} else {
	plan tests => 6;
}
use_ok ("Image::Thumbnail");

my $t = new Image::Thumbnail(
	CHAT=>1,
	size=>55,
	create=>1,
	inputpath => $cwd.'t/test.jpg',
	outputpath => $cwd.'t/test_t.jpg',
);

warn "# ".$t->{error} if $t->{error};

isa_ok($t, "Image::Thumbnail");
isa_ok($t->{object}, "Image::Magick");

ok ( defined $t->{x}, "x defined");
ok ( $t->{x}==55, "correct x");
ok ( $t->{y}==49, "correct y");
unlink($cwd."t/test_t.jpg");
