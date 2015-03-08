#!/bin/sh

for file in *.mp3
do
    #echo $file
    base=`basename "$file" .mp3`
    #echo $base.wav
    lame --decode "$file" "wav/$base.wav"
done
