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
my %titles;
while (my $dir = readdir $dh) {
  next if $dir =~ /^[.]/;
  next unless $whitelist{$dir};
 
  my $index_html_path = "/home/$dir/public_html/index.html";

  if (-e $index_html_path) {
    $dirs{$dir} = (stat $index_html_path)[9]; # mtime
    $titles{$dir} = get_title_from_file($index_html_path);
  }
}
close $dh;

sub sort_by_time {
   $dirs{$b} <=> $dirs{$a};
}

my $list = "<table>\n";
foreach my $key (sort sort_by_time (keys(%dirs))) {
   $list .= '  <tr>'
          . '<td><a href="/~' . $key . '/">~' . $key . '</a></td>'
          . '<td>' . $titles{$key} . '</td>'
          . '<td class=tiny>' . $dirs{$key} . '</td>'
          . "</tr>\n";
}

$list .= "</table>";

say $list;

sub get_title_from_file {
  my ($filespec) = @_;
  my $html = slurp($filespec);

  if ($html =~ m{<title>(.*?)</title>}is) {
    return $1;
  }
  return '';
}

sub slurp {
  my ($file) = @_;
  my $everything;

  open my $fh, '<', $file
    or die "Couldn't open $file: $!\n";

  # line separator:
  local $/ = undef;
  $everything = <$fh>;

  close $fh
    or die "Couldn't close $file: $!";

  return $everything;
}
