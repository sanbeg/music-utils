#! /usr/bin/perl
use Directory::Iterator;
use File::Copy;

my $old = "$ENV{HOME}/Music";
my $dir = shift;
my $begin = length($dir)+1;

#Google sucks so much!!!  Now it looks like they can't even handle long
#file names!!  It seems like we can trust about the first 29 chars, ie.
# Janis Joplin_ Big Brother And = Janis Joplin_ Big Brother And The Holding Company
# R_E_M_/And I Feel Fine___The Best Of = R_E_M_/And I Feel Fine___The Best Of The IRS Years 82-87

use constant MAX_NAME_LEN => 20;
my %miss;

sub munge_name($) {
    my $name = shift;
    my @path = split '/', $name;
    $_ = substr($_,0,MAX_NAME_LEN) for @path;
    return join '/', @path;
}

sub highlight($$) {
    my ($x,$y) = sort {length($a) <=> length($b)} @_;
    my $ext = '';

    if ($x =~ m/\.mp3$/ and $y =~ m/\.mp3/) {
	$ext = '.mp3';
	$_ = substr($_, 0, -4) for ($x, $y);
    }

    my $rv = $x;
    $rv .= "\e[2m";
    $rv .= substr($y, length($x));
    $rv .= "\e[0m";
    $rv .= $ext;
    return $rv;
}

my $it = Directory::Iterator->new($dir, show_directories=>1);
while (my $path = <$it>) {
    my $file = substr($path,$begin);
    unless ( -e "$old/$file" ) {
	#print "$file\n";
	$it->prune_directory;
	if ($file =~ m/\([0-9]+\).mp3$/) {
	    warn "Skip numbered: $file\n";
	    next;
	}
	$miss{ munge_name $file } = $file;
    }
}

$it = Directory::Iterator->new($old, show_directories=>1);
my $old_begin = length($old)+1;
while (my $path = <$it>) {
    my $file = substr($path,$old_begin);
    my $new_file = $miss{ munge_name $file };
    if (defined $new_file) {
	#print "$new_file = $file\n";
	warn "Skip truncated: ".  highlight($new_file, $file). "\n";
	delete $miss{ munge_name $file };
    }
}

foreach my $file (values %miss) {
    print "Move: $file\n";
    move("$dir/$file", "$old/$file");
}

