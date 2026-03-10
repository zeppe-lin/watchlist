#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;

sub sort_items {
	my $file = shift;
	my @records = ();

	open my $fh, '<', $file
		or die "$0: error: cannot open '$file': $!\n";

	local $/ = '';
	while (<$fh>) {
		s/^\s+|\s+$//g;

		my ($tag, $url) = (split /\n/, $_);

		die "$0: error: missing url in $file:$.: $tag\n"
			unless $url;

		$url =~ s/^\s*/  /;
		push @records, "$tag\n$url";
	}
	close $fh;

	# Sort and print with a clean double-newline separator
	print join("\n\n", sort @records), "\n";
}

for my $file (@ARGV) {
	sort_items($file);
}

# End of file.
