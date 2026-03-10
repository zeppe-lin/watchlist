#!/usr/bin/env perl
# chk-dups.pl - check pkgsrc-collections.txt for duplicate urls

use strict;
use warnings;
use diagnostics;
#use autodie;

my %seen = ();

sub process
{
	my $file = shift;
	my $collection = $file =~ s/(.*)\..*/$1/r;

	open my $fh, '<', $file
		or die "$0: error: cannot open '$file': $!\n";

	# Set record separator to "paragraph mode" (handles multiple newlines)
	local $/ = '';

	while (<$fh>) {
		# Remove leading trailing whitespace
		s/^\s+|\s+$//g;

		my ($tag, $url) = (split /\n/, $_);

		#die "$0: error: missing tag in $file:$.\n" unless $tag;
		die "$0: error: missing url in $file:$.: $tag\n" unless $url;

		# Remove leading/trailing whitespace in url
		$url =~ s/^\s+|\s+$//g;

		$seen{ $url }++;
	}

	close $fh;
}

die "Usage: $0 [pkgsrc-xyz.txt ...]\n" unless scalar @ARGV;
process($_) for @ARGV;

for (keys %seen) {
	print "$_\n" if $seen{ $_ } > 1;
}

# End of file.
