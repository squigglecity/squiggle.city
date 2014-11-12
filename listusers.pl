#!/usr/bin/perl

use strict;
use warnings;
use 5.10.0;

# we'll use this to filter out people who haven't logged in.
# pretty silly!
my %whitelist;
my (@lastlog) = split /\n/, `lastlog | grep -v Never | awk '{ print \$1; }'`;
foreach my $user (@lastlog) {
  $whitelist{$user} = 1;
}

opendir(my $dh, '/home/')
  or die "could not open /home/: $!";

my %dirs;
while (my $dir = readdir $dh) {
  next if $dir =~ /^[.]/;
  next unless $whitelist{$dir};
  $dirs{$dir} = (stat "/home/$dir/public_html/index.html")[9]; # mtime
}
close $dh;

sub sort_by_time {
   $dirs{$b} <=> $dirs{$a};
}

my $list = "<ul>\n";
foreach my $key (sort sort_by_time (keys(%dirs))) {
   $list .= '  <li><a href="/~' . $key . '/">~' . $key . '</a> (' . $dirs{$key} . ')</li>' . "\n";
}

$list .= "</ul>";

say $list;
