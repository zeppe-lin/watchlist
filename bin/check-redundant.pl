#!/usr/bin/env perl
# check-redundant.pl - check for redundant feeds

use strict;
use warnings;
use File::Basename;

my %feeds;

sub load_feeds {
	my $file = shift;

	open my $fh, '<', $file
		or die "$0: error: cannot open '$file': $!\n";

	local $/ = '';

	while (<$fh>) {
		s/^\s+|\s+$//g;
		next if /^$/;

		my ($tag, $url) = (split /\n/);

		die "$0: error: missing url in $file:$.: $tag\n"
			unless $url;

		my ($pkg_names, $meta) = (split /@/, $tag);
		$pkg_names =~ s/^\s+|\s+$//g;

		$feeds{ $pkg_names }++;
	}

	close $fh;
}

sub check_redundant_feeds {
	my $file = shift;
	my $collection = fileparse($file, qw(.txt .lst));

	my %repo = map {
		chomp;
		$_ => 1;
	} qx(pkgman --no-std-config --config-set='pkgsrcdir /usr/src/$collection' printf "%n\n");

	for my $pkg_names (sort keys %feeds) {
		if ($pkg_names =~ m/\//) {
			my $found = 0;
			my $name = '';

			for $name ((split /\//, $pkg_names)) {
				$name =~ s/^\s+|\s+$//g;
				next unless length $name;

				$found = 1 if exists $repo{ $name };
			}

			print "$collection: $name\n"
				unless $found;
		} else {
			print "$collection: $pkg_names\n"
				unless exists $repo{ $pkg_names };
		}
	}
}

die "Usage: $0 collection.txt ...\n"
	unless scalar @ARGV;

print <<EOF;
The following RSS/Atom feeds are redundant:
===========================================
EOF

for my $file (@ARGV) {
	load_feeds($file);
	check_redundant_feeds($file);
	%feeds = ();
}

# End of file.
