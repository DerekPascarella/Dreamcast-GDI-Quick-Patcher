#!/usr/bin/perl
#
# Dreamcast GDI Quick Patcher v1.1
# A utility for easily applying region-free and VGA patches to a Dreamcast GDI.
#
# Written by Derek Pascarella (ateam)

# Our modules.
use strict;
use File::Basename;
use Fcntl qw(SEEK_CUR);

# Set version number.
my $version = "1.1";

# Set header used in CLI messages.
my $cli_header = "\nDreamcast GDI Quick Patcher v" . $version . "\nA utility for easily applying region-free and VGA patches to a Dreamcast GDI.\n\nWritten by Derek Pascarella (ateam)\n\n";

# Set input file.
my $gdi_input = $ARGV[0];

# Store base folder for input file.
my $base_folder = dirname($gdi_input);

# If specified GDI file doesn't exist, throw an error.
if(!-e $gdi_input)
{
	print $cli_header;
	print STDERR "Input file not found: " . $gdi_input;
	print "\n\nPress Enter to exit.\n";
	
	<STDIN>;
	
	exit;
}

# If specified GDI file is unreadable, throw an error.
if(!-r $gdi_input)
{
	print $cli_header;
	print STDERR "Input file unreadable: " . $gdi_input;
	print "\n\nPress Enter to exit.\n";
	
	<STDIN>;
	
	exit;
}

# If input file is not a GDI, throw an error.
if($gdi_input !~ /\.gdi$/i)
{
	print $cli_header;
	print STDERR "Input file is not a GDI: " . $gdi_input;
	print "\n\nPress Enter to exit.\n";
	
	<STDIN>;
	
	exit;
}

# Store array of all data track files found in GDI.
my @data_tracks = &find_data_tracks($gdi_input);

# If no data tracks were found, throw an error.
if(scalar(@data_tracks) < 1)
{
	print $cli_header;
	print STDERR "No BIN or ISO data tracks found in GDI: " . $gdi_input;
	print "\n\nPress Enter to exit.\n";
	
	<STDIN>;
	
	exit;
}

# Status message.
print $cli_header;

# Prompt for region-free patching.
my $response_region;

while($response_region !~ /^[YN]$/i)
{
	print "Apply region-free patch? (Y/N) ";
	chop($response_region = lc(<STDIN>));
}

# Prompt for VGA patching.
my $response_vga;

while($response_vga !~ /^[YN]$/i)
{
	print "Apply VGA patch? (Y/N) ";
	chop($response_vga = lc(<STDIN>));
}

# Initialize patch count to zero.
my $patch_count = 0;

# Status message.
print "\nProcessing \"" . $gdi_input . "\"...\n\n";

# Iterate through and process each data track.
foreach my $track (@data_tracks)
{
	# Status message.
	print "-> Found data track \"" . $track . "\"...\n";

	# Apply region-free patching if permitted.
	if($response_region eq "y")
	{
		# Define search byte array for locating region strings.
		my @byte_array_region_string = (
			0x00, 0x38, 0x00, 0x70, 0x00, 0xE0, 0x01, 0xC0, 
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
			0x0E, 0xA0, 0x09, 0x00
		);

		# Store location of IP.BIN's region string start.
		my @region_string_locations = &find_ip_locations($base_folder . "\\" . $track, @byte_array_region_string);

		# IP.BIN region strings not found.
		if(scalar(@region_string_locations) > 0)
		{
			# Status message.
			print "    - Patching IP.BIN's region strings...\n";
			
			# Apply region string patch to each instance of IP.BIN.
			foreach my $region_string_location (@region_string_locations)
			{
				# Status message.
				print "       > Patched at decimal offset " . ($region_string_location + 20) . ".\n";

				# Patch data.
				&patch_bytes($base_folder . "\\" . $track, "466F72204A4150414E2C54414957414E2C5048494C4950494E45532E0EA00900466F722055534120616E642043414E4144412E2020202020202020200EA00900466F72204555524F50452E2020202020202020202020202020202020", $region_string_location + 20);
			
				# Increase patch count by one.
				$patch_count ++;
			}
		}
		# No IP.BIN header found, skip track file.
		else
		{
			# Stats message.
			print "    - No IP.BIN region strings found, skipping.\n";
		}

		# Define search byte array for locating region flag.
		my @byte_array_region_flag = (
			0x53, 0x45, 0x47, 0x41, 0x20, 0x53, 0x45, 0x47,
			0x41, 0x4B, 0x41, 0x54, 0x41, 0x4E, 0x41, 0x20
		);

		# Store location of IP.BIN header start.
		my @region_flag_locations = &find_ip_locations($base_folder . "\\" . $track, @byte_array_region_flag);

		# IP.BIN header found.
		if(scalar(@region_flag_locations) > 0)
		{
			# Status message.
			print "    - Patching IP.BIN headers for region flags...\n";
			
			# Apply region-free patch to each instance of IP.BIN header.
			foreach my $region_flag_location (@region_flag_locations)
			{
				# Status message.
				print "       > Patched at decimal offset " . ($region_flag_location + 48) . ".\n";

				# Patch data.
				&patch_bytes($base_folder . "\\" . $track, "4A5545", $region_flag_location + 48);

				# Increase patch count by one.
				$patch_count ++;
			}
		}
		# No IP.BIN header found, skip track file.
		else
		{
			# Stats message.
			print "    - No IP.BIN header with region flags found, skipping.\n";
		}
	}

	# Apply VGA patching if permitted.
	if($response_vga eq "y")
	{
		# Define search byte array for locating VGA flag.
		my @byte_array_vga = (
			0x53, 0x45, 0x47, 0x41, 0x20, 0x53, 0x45, 0x47,
			0x41, 0x4B, 0x41, 0x54, 0x41, 0x4E, 0x41, 0x20
		);

		# Store location of IP.BIN header start.
		my @vga_flag_locations = &find_ip_locations($base_folder . "\\" . $track, @byte_array_vga);

		# IP.BIN header found.
		if(scalar(@vga_flag_locations) > 0)
		{
			# Status message.
			print "    - Patching IP.BIN headers for VGA flag...\n";
			
			# Apply region-free and VGA patch to each instance of IP.BIN header.
			foreach my $vga_flag_location (@vga_flag_locations)
			{
				# Status message.
				print "       > Patched at decimal offset " . ($vga_flag_location + 61) . ".\n";

				# Patch data.
				&patch_bytes($base_folder . "\\" . $track, "31", $vga_flag_location + 61);

				# Increase patch count by one.
				$patch_count ++;
			}
		}
		# No IP.BIN header found, skip track file.
		else
		{
			# Stats message.
			print "    - No IP.BIN header with VGA flag found, skipping.\n";
		}
	}
}

# Status message.
print "\nA total of " . $patch_count . " patch";

if($patch_count > 1 || $patch_count == 0)
{
	print "es";
}

print " applied to GDI.\n\n";
print "Press Enter to exit.\n";

<STDIN>;

# Subroutine to return an array of data tracks found in a GDI.
sub find_data_tracks
{
	# Initialize input parameter.
	my $file_name = $_[0];

	# Declare variables.
	my @data_tracks;

	# Open the file for reading.
	open(my $fh, '<', $file_name) or die "Could not open file \"$file_name\": $!";

	# Process each line in the file.
	while(my $line = <$fh>)
	{
		# Remove new-line.
		chomp($line);
		
		# Match lines referencing BIN or ISO data tracks.
		if($line =~ /\b(\S+\.(?:bin|iso))\b/i)
		{
			# Store the file name in the array.
			push(@data_tracks, $1);
		}
	}

	# Close file.
	close($fh);

	# Return array.
	return @data_tracks;
}

# Subroutine to return the location of IP.BIN's region strings in a given GDI data track.
sub find_ip_locations
{
	# Initialize input parameters.
	my ($file_name, @byte_array) = @_;
	
	# Declare and initialize variables.
	my $buffer;
	my $offset = 0;
	my $chunk_size = 1024 * 1024;
	my @found_offsets;
	
	my $byte_string = pack("C*", @byte_array);
	my $overlap_size = length($byte_string) - 1;
	my $prev_chunk_tail = '';

	# Open the binary file for reading.
	open(my $fh, '<:raw', $file_name) or die "Can't open file \"$file_name\": $!";

	# Read the file in chunks.
	while(read($fh, $buffer, $chunk_size))
	{
		# Append the overlap from the previous chunk to handle cross-chunk matches.
		$buffer = $prev_chunk_tail . $buffer;
		
		# Start index at zero.
		my $index = 0;

		# Search for all occurrences of the byte array in the current chunk.
		while(($index = index($buffer, $byte_string, $index)) != -1)
		{
			# Calculate the absolute offset of the byte array found.
			my $found_offset = $offset + $index - length($prev_chunk_tail);
			
			# Add offset to array.
			push(@found_offsets, $found_offset);

			# Move the index past the current match for further searching.
			$index += length($byte_string);
		}

		# Update the current offset by adding the chunk size (excluding the overlap from the previous
		# chunk).
		$offset += $chunk_size;

		# Store the last few bytes of this chunk for overlap in the next chunk.
		$prev_chunk_tail = substr($buffer, -$overlap_size);
	}

	# Close file.
	close($fh);
	
	# Return an array of all found offsets.
	return @found_offsets;
}

# Subroutine to write a sequence of hexadecimal values at a specified offset (in decimal format) into
# a specified file, as to patch the existing data at that offset.
sub patch_bytes
{
	my $output_file = $_[0];
	(my $hex_data = $_[1]) =~ s/\s+//g;
	my @hex_data_array = split(//, $hex_data);
	my $patch_offset = $_[2];

	if((stat $output_file)[7] < $patch_offset + (scalar(@hex_data_array) / 2))
	{
		die "Offset for patch_bytes is outside of valid range.\n";
	}

	open my $filehandle, '+<:raw', $output_file or die $!;
	binmode $filehandle;
	seek $filehandle, $patch_offset, 0;

	for(my $i = 0; $i < scalar(@hex_data_array); $i += 2)
	{
		my($high, $low) = @hex_data_array[$i, $i + 1];
		print $filehandle pack "H*", $high . $low;
	}

	close $filehandle;
}