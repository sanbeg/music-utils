#! /usr/bin/perl -w

use strict;
use MP3::Tag;
use Getopt::Long;

# cdda2wav -J -B -L0
# cdrecord -dao -text -useinfo *.wav

my $outdir = 'wav';
my $do_inf = 1;
my $do_wav = 1;

GetOptions('inf!' => \$do_inf, 'wav!' => \$do_wav, 'outdir=s' => \$outdir)
  or die;

unless (-d $outdir) {
    mkdir $outdir or die "$outdir: $!";
}

for my $mp3 (<*.mp3>) {
    my $file = $mp3;
    $file =~ s/\.mp3$//;

    if ($do_inf) {
	die "bad name: $file" unless $file =~ m/^([0-9]{2})/;

	warn "$file.mp3";

	my $mp3 = MP3::Tag->new("$file.mp3");
	
	# get some information about the file in the easiest way (ignoring some)
	my ($title, $track, $artist, $album) = $mp3->autoinfo();
	my $tracknumber = $mp3->track1;

	open OUT, ">$outdir/$file.inf" or die "$file.inf: $!";
    
	print OUT "Albumperformer= '${artist}'\n";
	print OUT "Performer= '${artist}'\n";
    
	print OUT "Albumtitle= '${album}'\n";
	print OUT "Tracktitle= '${title}'\n";
	print OUT "Tracknumber= ${tracknumber}\n";

	close OUT;
    }

    system 'lame', '--decode', "$mp3", "$outdir/$file.wav" if $do_wav;
}
