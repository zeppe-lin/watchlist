#!/usr/bin/env perl
# check-dups.pl - check for duplicated urls

use strict;
use warnings;
use File::Basename;

my %seen = ();

sub process {
	my $file = shift;
	my $collection = fileparse($file, qw(.txt .lst));

	open my $fh, '<', $file
		or die "$0: error: cannot open '$file': $!\n";

	local $/ = '';
	while (<$fh>) {
		s/^\s+|\s+$//g; # strip leading/trailing whitespaces

		my ($tag, $url) = (split /\n/, $_);

		die "$0: error: missing url in $file:$.: $tag\n"
			unless $url;

		$url =~ s/^\s+|\s+$//g;

		$seen{ $url }{count}++;
		push @{ $seen{ $url }{collections} }, $collection;
	}
	close $fh;
}

die "Usage: $0 collection.txt ...\n"
	unless scalar @ARGV;

for my $file (@ARGV) {
	process($file);
}

for my $url (keys %seen) {
	if ($seen{ $url }{count} > 1) {
		for my $collection (@{$seen{ $url }{collections}}) {
			print "$collection: $url\n";
		}
	}
}

# End of file.
