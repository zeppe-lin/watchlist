#!/usr/bin/env perl
# gen-newsraft.pl - generate newsraft feeds file

use strict;
use warnings;
use File::Basename;

sub process {
	my $file = shift;
	my $collection = fileparse($file, qw(.txt .lst));

	open my $fh, '<', $file
		or die "$0: error: cannot open '$file': $!\n";

	print "# ===\n\@$collection\n# ===\n";

	local $/ = ""; 
	while (<$fh>) {
		s/^\s+|\s+$//g; # strip leading/trailing spaces

		my ($tag, $url) = (split /\n/, $_);

		die "$0: error: missing url in $file:$.: $tag\n"
			unless $url;

		$url =~ s/^\s+|\s+$//g;

		# Hack for GitHub
		if ($url =~ m|^https?://github\.com/.*\.atom|) {
			my $gh_url = "\$(curl -H 'Accept: application/atom+xml' $url)";
			$url = $gh_url;
		}

		print "$url \"$tag\"\n";
	}

	close $fh;
}

die "Usage: $0 collection.txt ..."
	unless scalar @ARGV;

print "# newsraft subscriptions\n";

for my $file (@ARGV) {
	process($file);
}

# End of file.
