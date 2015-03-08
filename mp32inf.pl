#! /usr/bin/perl -w

# cdda2wav -J -B -L0
# cdrecord -dao -text -useinfo *.wav

use MP3::Tag;

for my $file (<*.mp3>) {
    $file =~ s/\.mp3$//;
    die "bad name: $file" unless $file =~ m/^([0-9]{2})/;

    warn "$file.mp3";

	my $mp3 = MP3::Tag->new("$file.mp3");
	
	# get some information about the file in the easiest way (ignoring some)
	my ($title, $track, $artist, $album) = $mp3->autoinfo();
	my $tracknumber = $mp3->track1;

    open OUT, ">$file.inf" or die "$file.inf: $!";
    
    print OUT "Albumperformer= '${artist}'\n";
    print OUT "Performer= '${artist}'\n";

    print OUT "Albumtitle= '${album}'\n";
    print OUT "Tracktitle= '${title}'\n";
    print OUT "Tracknumber= ${tracknumber}\n";

    close OUT;
}
