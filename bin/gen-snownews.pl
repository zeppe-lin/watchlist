#!/usr/bin/env perl
# gen-snownews.pl - generate snownews OPML file
use strict;
use warnings;
use File::Basename;
#use Data::Dumper;

sub process {
	my $file = shift;
	my $collection = fileparse($file, qw(.txt .lst));

	open my $fh, '<', $file
		or die "$0: error: cannot open '$file': $!\n";

	print "<!--\n=== $collection ===\n-->\n";

	local $/ = '';
	while (<$fh>) {
		s/^\s+|\s+$//g; # strip leading/trailing spaces

		my ($tag, $url) = (split /\n/);

		die "$0: error: missing url in $file:$.: $tag\n"
			unless $url;

		$url =~ s/^\s+|\s+$//g;

		# Hack for GitHub
		if ($url =~ m|^https?://github.com/.*\.atom|) {
			my $gh_url = "exec:curl -H 'Accept: application/atom+xml' $url";
			$url = $gh_url;
		}

		print "<outline text=\"$tag\" xmlUrl=\"$url\" category=\"$collection\"/>\n";
	}
	close $fh;
}

die "Usage: $0 collection.txt ..." unless scalar(@ARGV);

print <<'EOF';
<?xml version="1.0"?>
<opml version="2.0">
<head>
<title>snownews subscriptions</title>
</head>
<body>
EOF

for my $file (@ARGV) {
	process($file);
}

print <<'EOF';
<!--
=== New Items ===
-->
<outline text="(New headlines)" xmlUrl="smartfeed:/newitems"/>
EOF

print <<'EOF';
</body>
</opml>
EOF

# End of file.
