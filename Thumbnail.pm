package Image::Thumbnail;

use Carp;
use strict;
use warnings;
our $VERSION = '0.03';

=head1 NAME

Image::Thumbnail - GD/ImageMagick thumbnail images.

=head1 SYNOPSIS

	use Image::Thumbnail;

	# Create a thumbnail from 'test.jpg' as 'test_t.jpg'
	# using ImageMagick, or GD.
	my $t = new Image::Thumbnail(
		size       => 55,
		create     => 1,
		inputpath  => 'test.jpg',
		outputpath => 'test_t.jpg',
    );

	# Create a thumbnail from 'test.jpg' as 'test_t.jpg'
	# using GD.
	my $t = new Image::Thumbnail(
		module     => 'GD',
		size       => 55,
		create     => 1,
		inputpath  => 'test.jpg',
		outputpath => 'test_t.jpg',
    );

	# Create a thumbnail as 'test_t.jpg' from an ImageMagick object
	# using ImageMagick, or GD.
	my $t = new Image::Thumbnail(
		size       => 55,
		create     => 1,
		object     => $my_image_magick_object,
		outputpath => 'test_t.jpg',
    );

	# Create four more of ever-larger sizes
	for (1..4){
		$t->{size} = 55+(10*$_);
		$t->create;
	}

	__END__

=head1 DESCRIPTION

This module uses the ImageMagick or GD libraries to easily make thumbnail images from
files or objects from the specified library.

I made C<Image::GD::Thumbnail> a while ago for myself, put on CPAN because I need
to get to it elsewhere and it's cheap FTP. A few people asked for a ImageMagick
version, so I made that, and then put them together in this.

=cut

=head1 PREREQUISITES

C<Image::Magick> or C<GD>.

=cut

=head1 CONSTRUCTOR new

Parameters are supplied as a hash or hash-like structure of pairs:
See the L</SYNOPSIS>.

=head2 REQUIRED PARAMETERS

=over 4

=item size

The size you with the longest side of the thumbnail to be.

=back

=head2 PARAMETERS TO CHOOSE FROM

You must supply one of either:

=over 4

=item object

An object-reference created by your chosen package.
Naturally you can't supply this field if you haven't
specified a C<module> field (see above).

=item inputpath

Path to an image to use as the source file.

=back

=head2 OPTIONAL PARAMETERS

=over 4

=item module ( GD | ImageMagick )

If you wish to use a specific module, place its name here.
You must have the module you require already installed!

Supplying no name will allow ImageMagick to be tried before GD.

=item create

Put any value in this field if you wish the constructor to
call the C<create> method automatically before returning.

=item inputtype, outputtype

If you are using C<GD>, you can explicitly set the input
and output formats for the image file, provided you use
a string that can be evaluated to a C<GD>-supported image
format (see L<GD>).

Default behaviour is to attempt to ascertin the file type
and to create the thumbnail in the same format. If the
type cannot be defined (you are using C<GD>, have supplied
the C<object> field and not the C<outputtype> field) then
the output file format defaults to C<jpeg>.

=item depth

Sets colour depth in ImageMagick - GD only supports 8-bit.

The ImageMagick manpage (see L<http://www.imagemagick.org/www/ImageMagick.html#opti>).
says:

=item attr

If you are using ImageMagick, this field should contain
a hash of ImageMagick attributes to pass to the ImageMagick
C<set> command when the thumbnail is created. Any errors these
may generate are not yet caught.

=cut

# If you are using GD, this field should contain a hash where
# keys are GD method names, and values are the arrays of
# paramters for those methods (naturally excluding the object
# reference).

=over 4

This is the number of bits in a color sample within
a pixel. The only acceptable values are 8 or 16. Use this
option to specify the depth of raw images whose depth is
unknown such as GRAY, RGB, or CMYK, or to change the
depth of any image after it has been read.

=back

=item CHAT

Put any value in this field for real-time process info.

=back

=head2 ERRORS

Any errors will be printed to C<STDOUT>. If they completely
prevent processing, they will be fatal (C<croak>ed). If
partial processing has taken place by the explicit or implicit
calling of the C<create> method, then the field of the same
name will have value.

Depending on how far processing has proceded, other fields may have useful values:
the C<module> field will contain the name of the module used;
the C<object> field may contain an object of the module used;
the C<thumb> field may contain a thumbnail image.

=cut

sub new { my $class = shift;
    unless (defined $class) {
    	carp "Usage: ".__PACKAGE__."->new( {key=>value} )\n";
    	return undef;
	}
	my %args;

	# Take parameters and place in object slots/set as instance variables
	if (ref $_[0] eq 'HASH'){	%args = %{$_[0]} }
	elsif (not ref $_[0]){		%args = @_ }
	else {
		carp "Usage: $class->new( { key=>values, } )";
		return undef;
	}
	my $self = bless {}, $class;

	# Fields that have default values which can be over-written:

	# Set/overwrite default fields with user's values:
	foreach (keys %args) {
		$self->{$_} = $args{$_};
	}

	# Fill slots the user may have filled but should not:
	$self->{img}	= '';
	$self->{thumb}	= '';

	# Croak on user errors
	croak "No 'size' paramter" if not $self->{size};
	if ( $self->{object} and $self->{inputpath} ){
		croak "You cannot supply both an 'object' field and a 'inputpath' field"
	}
	if ( not $self->{object} and not $self->{inputpath} ){
		croak "You must supply either an 'object' field or a 'inputpath' field"
	}
	# Try not to limit Image::Magick...
	if ($self->{inputpath} and $self->{module}  and $self->{module} =~ /^(GD|GD::Image)$/
	and not -e $self->{inputpath}){
		croak "The supplied inputpath '$self->{inputpath}' does not exist:\n$!"
	}

	# Correct common user errors
	if ($self->{module} and $self->{module} =~ /^ImageMagick$/i){
		$self->{module} = 'Image::Magick';
		warn "Corrected parameter 'module' from 'ImaegMagick' to 'Image::Magick'" if $self->{CHAT};
	}

	# Sort out the Thumbnail module
	if (not $self->set_mod){
		warn "No module";
		return undef;
	}

	# Call 'create' if requested
	$self->create if $self->{create};

	return $self;
}

#
# Sometimes self-recursive
#
sub set_mod { my ($self,$try) = (shift,shift);
	warn "Set module...".(defined $try? $try : "(not trying)") if $self->{CHAT};
	if (not $self->{module} and $self->{object}){
		$self->{module} = ref $self->{object};
		warn "Set module to match the supplied object: $self->{module}" if $self->{CHAT};
	}
	elsif ($try){
		$self->{module} = $try;
	}
	elsif (not $self->{module} and not $try){
		for ('Image::Magick','GD'){
			if (not $self->set_mod($_)){
				return undef;
			} else {
				last;
			}
		}
		return $self->{module};
	}

	if ($self->{module} =~ /^GD/){
		warn "Requiring GD" if $self->{CHAT};
		eval ('use GD;');
		if ($@){
			warn "Error requring GD:\n".@$;
			return undef;
		}
		warn "GD OK" if $self->{CHAT};
	}
	elsif ($self->{module} eq 'Image::Magick'){
		warn "Requiring Image::Magick" if $self->{CHAT};
		eval ('use Image::Magick');
		if ($@){
			warn "Error requring Image::Magick:\n".@$;
			return undef;
		}
		warn "Image::Magick OK" if $self->{CHAT};
	}
	else {
		warn "Unsupported module $self->{module}" if $self->{CHAT};
		return undef;
	}

	return $self->{module};
}

=head1 METHOD create

Creates a thumbnail using the supplied object.
Called automatically if you construct with the
C<create> field flagged.

=cut

sub create { my $self = shift;
	warn "Creating thumbnail" if $self->{CHAT};
	if ($self->{module} eq 'Image::Magick'){
		$_ = $self->create_imagemagick;
	} elsif ($self->{module} =~ /^(GD|GD::Image)$/){
		$_ = $self->create_gd;
	} else {
		warn "Unknown module $self->{module}";
		$_ = undef;
	}
	return $_;
}

#
# METHOD create_imagemagick
#
sub create_imagemagick { my $self=shift;
	warn "...with Image::Magick" if $self->{CHAT};
	if (not $self->{object} or ref $self->{object} ne 'Image::Magick'){
		warn "...from file $self->{inputpath}" if $self->{CHAT};
		$self->{object} = Image::Magick->new;
		$self->{img} = $self->{object}->Read($self->{inputpath});
	}

	# Set depth
	if ($self->{depth}){
		$self->{object}->Set('depth'=>$self->{depth});
	}
	# Other attributes
	if ($self->{attr}){
		foreach my $key (keys %{$self->{attr}}){
			$self->{object}->Set($key=>$self->{attr}->{$key});
			# Catch errors?
		}
	}

	($self->{thumb},$self->{x},$self->{y}) = $self->imagemagick_thumb;
	if ($self->{outputpath}){
		warn "Writing to $self->{outputpath}" if $self->{CHAT};
		$self->{object}->Write($self->{outputpath});
	}
	warn "Done Image::Magick: ",$self->{x}," ",$self->{y} if $self->{CHAT};
	return 1;
}

#
# METHOD create_gd
#
sub create_gd { my $self=shift;
	local (*IN, *OUT);
	warn "... with GD" if $self->{CHAT};

	# Load the source image
	if ($self->{inputpath}){
		if (not open IN, $self->{inputpath}){
			warn "Could not open source ",$self->{inputpath};
			return undef;
		}
		binmode IN;

		# Ascertain image type:
		$self->{intputtype} = $self->get_img_type(*IN);
		if (not $self->{inputtype}){
			warn "Could not ascertain image type for $self->{inputpath}";
			return undef;
		}
		# Make the object
		$self->{object} = eval ( 'GD::Image->newFrom'.ucfirst($self->{inputtype}).'(*IN)');
		if ($@){
			warn "Error in outputting: $@";
			return undef;
		}
		close IN;
	}

	# Set output type to input type if not defined already
	$self->{outputtype}=$self->{inputtype} if not $self->{outputtype};
	if (not $self->{inputtype}){
		$self->{outputtype} = 'jpeg';
	}

	# Call attr: eg. $im->fill(50,50,$red);
#	if ($self->{attr}){
#		foreach my $key (keys %{$self->{attr}}){
#			eval ($self->{object}."->".$key."(@{$self->{attr}->{$key}})");
#			# Catch errors?
#		}
#	}

	# Make thumbnail
	($self->{thumb},$self->{x},$self->{y}) = $self->gd_thumb;

	if ($self->{outputpath}){
		# Save your thumbnail
		if (not open OUT, ">".$self->{outputpath}){
			warn "Could not save thumbnail image to $self->{outputpath}:\n$!";
			return undef;
		}
		binmode OUT;
		warn "Saving as $self->{outputpath}, type $self->{outputtype}" if $self->{CHAT};
		print OUT eval ( '$self->{thumb}->'.lc $self->{outputtype} );
		if ($@){
			warn "Error in outputting: $@";
			return undef;
		}
		close OUT;
	}
	warn "Done GD; ",$self->{x}," ",$self->{y} if $self->{CHAT};
	return 1;
}





#
# Sets our inputtype field to the file type (jpeg, etc)
# Includes unsupported image types.
#
sub get_img_type { my ($self,$handle)=(shift,shift);
	my $id;
	warn "Ascertaining file type" if $self->{CHAT};
	if ($handle){
		my $header;			# The first 256 of image
		binmode $handle;
		read IN, $header, 256;
		seek IN,0,0;

		my %type_map = (	# Map lifted straight from Image::Size (C) Randy J. Ray, 2002
			'^GIF8[7,9]a'              => "gif",
			"^\xFF\xD8"                => "jpeg",
			"^\x89PNG\x0d\x0a\x1a\x0a" => "png",
			"^P[1-7]"                  => "ppm", # also XVpics
			'\#define\s+\S+\s+\d+'     => "xbm",
			'\/\* XPM \*\/'            => "xpm",
			'^MM\x00\x2a'              => "tiff",
			'^II\x2a\x00'              => "tiff",
			'^BM'                      => "bmp",
			'^8BPS'                    => "psd",
			'^PCD_OPA'                 => "pcd",
			'^FWS'                     => "swf",
			"^\x8aMNG\x0d\x0a\x1a\x0a" => "mng",
		);
		grep {$id=$type_map{$_} if $header=~/$_/  } keys %type_map;
	}
	$self->{inputtype} = $id;
}


sub gd_thumb { my $self=shift;
	my ($ox,$oy) = $self->{object}->getBounds();
	my $r = $ox>$oy ? $ox / $self->{size} : $oy / $self->{size};
	my $thumb = GD::Image->new($ox/$r,$oy/$r);
	$thumb->copyResized($self->{object},0,0,0,0,$ox/$r,$oy/$r,$ox,$oy);
	return $thumb, sprintf("%.0f",$ox/$r), sprintf("%.0f",$oy/$r);
}

sub imagemagick_thumb { my $self=shift;
	my ($ox,$oy) = $self->{object}->Get('width','height');
	warn "Error getting width/height!" and return undef if not $ox or not $oy;
	my $r = $ox>$oy ? $ox / $self->{size} : $oy / $self->{size};
	$self->{object}->Resize(width=>$ox/$r,height=>$oy/$r);
	return $self->{object}, sprintf("%.0f",$ox/$r), sprintf("%.0f",$oy/$r);
}

1; # Satisfy 'require'
__END__



=head1 EXPORT

None by default.

=head1 CHANGES

Version 0.02 (10 June 2002): added C<attr> and C<depth> fields.

Version 0.03 (10 June 2002): tardist bug fixed.

=head1 SEE ALSO

L<perl>,
L<Image::Magick>, L<Image::Magick::Thumbnail>,
L<GD>, L<Image::GD::Thumbnail>.

=head1 AUTHOR

Lee Goddard <LGoddard@CPAN.org>

=head1 COPYRIGT

Copyright (C) Lee Godadrd 2001 all rights reserved.
Available under the same terms as Perl itself.

=cut

End of File
