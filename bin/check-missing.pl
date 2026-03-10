#!/usr/bin/env perl
# check-missing.pl - check for missing feeds
use strict;
use warnings;
#use diagnostics;
use Data::Dumper;

use File::Basename;
use Term::ANSIColor qw(:constants);
use Getopt::Long qw(:config gnu_compat no_ignore_case bundling);

my $obsoletes_file = 'obsoletes.txt';
my %obsoletes;
my %feeds;

sub load_obsoletes {
	my $file = shift;

	open my $fh, '<', $file
		or die "$0: error: cannot open '$file': $!\n";

	while (<$fh>) {
		s/^\s+|\s+$//g;
		next if /^$/ or /^#/;

		$obsoletes{$_}++;
	}

	close $fh;
}

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

		my ($names, $meta) = (split /@/, $tag);
		$names =~ s/^\s+|\s+$//g;

		for my $pkgname (split (/\//, $names)) {
			$feeds{ $pkgname }++;
		}
	}

	close $fh;
}

sub check_missing_feeds {
	my $file = shift;

	my $collection = $file =~ s/(.*)\..*/$1/r;

	my %repo = map {
		chomp;
		$_ => 1;
	} qx(pkgman --no-std-config --config-set='pkgsrcdir /usr/src/$collection' printf "%n\n");

	for (sort keys %repo) {
		next if exists $feeds{ $_ };

		my $pkgsrc_path = qx(pkgman path $_);
		chomp $pkgsrc_path;

		if ($obsoletes{ $_ }) {
			print "[x] \e[9m$pkgsrc_path\e[0m \e[3m(obsolete)\e[0m\n";
		} else {
			print "[ ] $pkgsrc_path\n";
		}
	}
}

die "Usage: $0 pkgsrc-collection.txt ...\n"
	unless scalar @ARGV;

load_obsoletes($_) for $obsoletes_file;
for (keys %obsoletes) {
	print "$0: warning: duplicate in $obsoletes_file: $obsoletes{$_}\n"
		if $obsoletes{$_} > 1;
}

for my $file (@ARGV) {
	load_feeds($file);

	print <<EOF;
The following repository package sources has no RSS/Atom feeds:
===============================================================
EOF
	check_missing_feeds($file);
}

# End of file.
