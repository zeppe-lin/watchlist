#!/usr/bin/env perl

use strict;
use warnings;
use diagnostics;
use autodie;
use File::Basename;
use Term::ANSIColor qw(:constants);
use Getopt::Long qw(:config gnu_compat no_ignore_case bundling);

my $PROGRAM = basename $0;
my $VERSION = '0.1';

######################################################################

my @obsolete_packages = qw(
    adwaita-gtk-theme
    autoconf-2.13
    avidemux276-appimage
    fuse2
    gnome-icon-theme
    gtk-engine-bluecurve
    gtk-engine-clearlooks
    gtk-engine-crux
    gtk-engine-hc
    gtk-engine-murrine
    gtk-engine-redmond95
    gtk-engines
    hcxtools3
    ktsuss
    librsvg-compat
    libwnck
    libxcrypt2.4
    mdk3
    moc-eqsets
    newsboat213
    notification-daemon
    p5-gnome2-wnck
    p5-gtk2-notify
    pango-compat
    pm-utils
    py-cairo
    py-gobject-compat
    python
    shared-mime-info
    smtp-user-enum
    tnscmd10g
    xorg-libxfont
    xorg-xf86-input-keyboard
    );
my @internal_packages = qw(
    c17
    c89
    c99
    filesystem
    mksslcert
    usbids
    xorg
    );
my @repos = qw(
    core
    system
    xorg
    desktop
    wmaker
    games
    stuff
    );

######################################################################

my %feed;
my %internal = map { $_ => 1 } @internal_packages;
my %obsolete = map { $_ => 1 } @obsolete_packages;
my %repo     = map { chomp; $_ => 1 } qx(pkgman printf "%n\n");

######################################################################

sub load_feeds {
    open my $fh, 'newsraft';
    while (<$fh>) {
        next unless /^(?:.*?)\s+"(.*?)\s+@\s+.*"$/;
        for my $pkg (split /\//, $1) {
            $feed{ $pkg }++;
        }
    }
    close $fh;
}

#sub load_feeds {
#    my $categories = join '|', @repos;
#    open my $fh, 'urls.opml';
#    while (<$fh>) {
#        next unless m{
#            \s*
#            <outline\s+
#                text="(?<title>.*?)\s+@.*?"\s+
#                xmlUrl=".*"\s+
#                category="(?:$categories)"/>
#        }xsm;
#        for my $pkg (split /\//, $+{title}) {
#            $feed{ $pkg }++;
#        }
#    }
#    close $fh;
#}

sub print_missing {
    print <<EOF;

The following repo packages have no RSS/Atom feeds:
===================================================

EOF
    for (sort keys %repo) {
        next if exists $feed{ $_ };

        my $pkgsrcpath = qx(pkgman path $_);
        chomp $pkgsrcpath;

        if ($obsolete{ $_ }) {
            print "[x] \e[9m$pkgsrcpath\e[0m \e[3m(obsolete)\e[0m\n";
        } elsif ($internal{ $_ }) {
            print "[v] \e[9m$pkgsrcpath\e[0m \e[3m(internal)\e[0m\n";
        } else {
            print "[ ] $pkgsrcpath\n";
        }
    }
}

sub print_redundant {
    print <<EOF;

The following RSS/Atom feeds in newsraft are redundant:
=======================================================

EOF
    for (sort keys %feed) {
        print "$_\n" unless exists $repo{ $_ };
    }
}

sub print_typos {
    print <<EOF;
The following typos was found in newsraft:
==========================================

EOF
    open my $fh, 'newsraft';
    my $pkg_re = '[a-z0-9\-\.\/]+';
    my $lineno = 0;
    while (<$fh>) {
        $lineno++;

        # skip sections, comments, and empty lines
        next if /^@(?:core|system|xorg|desktop|wmaker|games|stuff|dev)$/;
        next if /^#.*$/;
        next if /^$/;

        # skip feed
        next if m!^https?://.*? "$pkg_re @ .*?"$!;
        next if m!^\$\(curl -H 'Accept: application/atom\+xml' https?://.*?\) "$pkg_re @.*?"$!;

        print "malformed line at $lineno: $_\n";
    }
    close $fh;
}

#sub print_typos {
#    my $categories = join('|', @repos) . '|dev';
#    print <<EOF;
#The following typos was found in urls.opml:
#===========================================
#
#EOF
#    open my $fh, '<', 'urls.opml';
#    my $lineno = 0;
#    for (<$fh>) {
#        $lineno++;
#        next unless /^\s*<outline/;
#        next if /^\s*<outline text="\(New headlines\)" xmlUrl="smartfeed:\/newitems"\/>$/;
#
#        print "malformed line at $lineno: $_\n"
#            unless m/^\s*<outline text=".*?" xmlUrl=".*?" category="(?:$categories)"\/>$/;
#
#        print "wrong github fetching (use curl) at $lineno: $_\n"
#            if m/xmlUrl="https:\/\/github.com\/.*.atom"/;
#
#        print "malformed curl request qt $lineno: $_\n"
#            if m/xmlUrl="exec:\s*curl/ && !m/xmlUrl="exec:curl -H 'Accept: application\/atom\+xml' https?:\/\/.*?"/;
#    }
#    close $fh;
#}

# ====================================================================

sub print_version {
    print "$PROGRAM $VERSION\n";
}

sub print_help {
    print <<EOF;
Usage: $PROGRAM [OPTION...]
Lint RSS/Atom feeds.

  -m, --missing    check for packages that have no feeds in newsraft
  -r, --redundant  check for redundant feeds in newsraft
  -t, --typos      check newsraft for typos
  -v, --version    print version and exit
  -h, --help       print help and exit
EOF
}

# ====================================================================

sub main {
    GetOptions(
        "m|missing"   => \my $opt_missing,
        "r|redundant" => \my $opt_redundant,
        "t|typos"     => \my $opt_typos,
        "v|version"   => \my $opt_version,
        "h|help"      => \my $opt_help,
    ) or die "Try '$PROGRAM --help' for more information.\n";

    print_version() and exit if $opt_version;
    print_help()    and exit if $opt_help;
    print_help()    and exit
        unless $opt_missing or $opt_redundant or $opt_typos;

    print_typos()     if $opt_typos;

    load_feeds();
    print_missing()   if $opt_missing;
    print_redundant() if $opt_redundant;
}

main() if not caller();
1;

# vim: sw=4 ts=4 sts=4 et cc=72 tw=70
# End of file.
