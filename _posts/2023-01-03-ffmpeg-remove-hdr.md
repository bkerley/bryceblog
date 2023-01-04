---
layout: post
title: ffmpeg command to remove HDR
tags:
    - ffmpeg
    - ffmpreg
    - video
    - since 2021
kind: regular
date: '2023-01-03T00:00:00-05:00'
---

<style type="text/css">
p code {
    overflow-wrap: anywhere;
}
li code {
    background-color: #fefcff;
    padding: 0.05em;
}
</style>

<aside>

# This is a very technical post about something I don't know super-well

Please email me (<mailto:bkerley@brycekerley.net>)
if there are inaccuracies.

</aside>

I used this `ffmpeg` command to remove HDR from an iPhone 13 Pro
video.

`time ffmpeg -i /private/tmp/lightroom/IMG_5744.MOV   -c:v h264_videotoolbox  -maxrate 2600K -bufsize 2600K -vf "zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,scale='trunc(iw/2):trunc(ih/2)',format=yuv420p" -c:a aac -pix_fmt yuv420p aperture2.mp4`

Sorry that command's so unwieldy. 
If you're going to run it, 
I'd recommend copying it into your code editor
instead of trying to bash it into shape at the terminal,
especially if you don't have mouse support in your shell.

Why though? I transcoded a video from my phone using ffmpreg
to post on Discord and it looked like shit, 
so I did some research.

# Notes on the Command

This uses the
[zscale](https://ffmpeg.org/ffmpeg-filters.html#zscale-1) filter
that I'm not super familiar with,
and manipulates the
[colorspace](https://trac.ffmpeg.org/wiki/colorspace)
of the images, a process I'm also not super familiar with.

The `format` stuff below mentions three colon-separated numbers,
like "4:4:4" and "4:2:0". 
This is
[chroma subsampling](https://en.wikipedia.org/wiki/Chroma_subsampling)
where for multiple pixels,
you store different amounts of luminance (like brightness)
and color channels to save space.
"4:4:4" stores everything, 
"4:2:0" saves a ton of space/bandwidth and 
is basically the standard for final playback.

There's a lot of stuff below about color spaces
and matrices and ranges and whatnot.
The quick version is that you 
gotta do it because
[HDR is necessarily complicated](https://en.wikipedia.org/wiki/High-dynamic-range_television#Technical_details)
because image processing in 2023 is complicated
because the human vision system is complicated.

# The Annotated Command

1. `time` - I want to see how long it takes 
2. `ffmpeg` - I'm running it; 
    pretty sure I did `brew install ffmpeg` to get it
3. `-i /private/tmp/lightroom/IMG_5744.MOV` - this is the video file;
    I dragged it out of `Photos.app` into 
    [Yoink](https://eternalstorms.at/yoink/mac/)
    then from Yoink into Finder,
    and finally from Finder into Terminal, 
    which inserts the correctly-escaped path
4. `-c:v h264_videotoolbox` -
    I generally want to use the hardware encoder on this machine
    (m1 pro) because it's fast;
    if you're not on macOS with hardware accelerated video encoding
    you'll have to use a different
    [ffmpeg video encoder](https://ffmpeg.org/ffmpeg-codecs.html#Video-Encoders)
5. `-maxrate 2600K -bufsize 2600K` -
    these settings match what my mastodon server expects;
    `maxrate` controls the maximum number of bytes/sec it'll output
    (2.6mb in this case), 
    and `bufsize` is the size of a buffer to enforce that rate over.
    A bigger `bufsize` gives the encoder more flexibility in
    adjusting per-frame sizes, 
    but may affect playability with small buffers 
    (i.e. on a small device or 
    when a connection is just barely fast enough).
    Some more information about
    [ffmpeg bitrates](https://trac.ffmpeg.org/wiki/Encode/H.264#AdditionalInformationTips) is available.
6. `-vf` - the next command is a video filter 
    (which I'll annotate the comma-delimited parts separately)
7. `zscale=t=linear:npl=100` -
    [Transfer the images](https://en.wikipedia.org/wiki/Transfer_functions_in_imaging)
    to a linear brightness scale, 
    with a Nominal Peak Luminance of 100
8. `format=gbrpf32le` -
    change the pixel format to something presumably easier 
    or more accurate to work with,
    "IEEE-754 single precision planar GBR 4:4:4, 96bpp, little-endian"
9. `zscale=p=bt709` -
    set the color Primaries to
    [BT.709](https://en.wikipedia.org/wiki/Rec._709)
10. `tonemap=tonemap=hable:desat=0` -
    use the 
    [Hable tonemapping algorithm](http://filmicworlds.com/blog/filmic-tonemapping-with-piecewise-power-curves/)
    to scoot all the colors into the a useful range,
    and don't desaturate anything that would be blown out
    towards white
11. `zscale=t=bt709:m=bt709:r=tv` -
    Transfer the images to BT.709,
    set the color matrix to BT.709,
    and set the color range to a standard
    TV range
    (yeah television, as opposed to Personal Computer)
    of 16-235 instead of 0-255
12. `scale='trunc(iw/2):trunc(ih/2)'` -
    size the image down to half of each dimension,
    `trunc` rounds the "Input Width / 2" (and Input Height)
    towards zero so weird stuff with half-pixels doesn't happen
    if the original has an odd dimension
13. `format=yuv420p` -
    change the pixel format to YUV 4:2:0
14. `-c:a aac` - compress the audio with AAC
15. `-pix_fmt yuv420p` - save it as YUV 4:2:0
16. `aperture2.mp4` - the output filename

# Conclusion

ffmpeg is really powerful and useful,
but frustratingly it seems like one of those tools
where everyone's learned it from lore and rumors
than the documentation.

Hopefully by writing this I help solve the problem
for myself,
and incidentally I hope you've found it useful too.

