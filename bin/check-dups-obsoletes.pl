#!/usr/bin/env perl
# check-obsoletes.pl - check obsoletes for duplicates
use strict;
use warnings;
use diagnostics;

use File::Basename;

my %obsoletes;

sub load_obsoletes {
	my $file = shift;

	open my $fh, '<', $file
		or die "$0: error: cannot open '$file': $!\n";

	while (<$fh>) {
		s/^\s+|\s+$//g; # strip leading/trailing whitespaces

		next if /^$/ or /^#/;

		$obsoletes{$_}++;
	}

	close $fh;
}

die "Usage: $0 obsoletes.txt ...\n"
	unless scalar @ARGV;

for my $file (@ARGV) {
	load_obsoletes $file;
}

for (keys %obsoletes) {
	print "$0: warning: duplicate in obsoletes.txt: $obsoletes{$_}\n"
		if $obsoletes{$_} > 1;
}

# End of file.
