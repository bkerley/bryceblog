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

<aside>

# This is a very technical post about something I don't really know!

Please email me (<mailto:bkerley@brycekerley.net>)
if there are inaccuracies!

</aside>

I used this `ffmpeg` command to remove HDR from an iPhone 13 Pro
video.

`time ffmpeg -i IMG_5744.MOV   -c:v h264_videotoolbox  -maxrate 2600K -bufsize 2600K -vf "zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,scale='trunc(iw/2):trunc(ih/2)',format=yuv420p" -c:a aac -pix_fmt yuv420p aperture2.mp4`

This uses the
[zscale](https://ffmpeg.org/ffmpeg-filters.html#zscale-1) filter
that I'm not super familiar with,
and manipulates the
[colorspace](https://trac.ffmpeg.org/wiki/colorspace)
of the images, a process I'm also not super familiar with.

The `format` stuff mentions three colon-separated numbers,
like "4:4:4" and "4:2:0". 
This is
[chroma subsampling](https://en.wikipedia.org/wiki/Chroma_subsampling)
where for multiple pixels,
you store different amounts of luminance (like brightness)
and color channels to save space.
"4:4:4" stores everything, 
"4:2:0" saves a ton of space/bandwidth and 
is basically the standard for final playback.

Annotated:

1. `time` i want to see how long it takes 
2. `ffmpeg` i'm running it; 
    i'm pretty sure i did `brew install ffmpeg` to get it
3. `-i IMG_5744.MOV` this is the video file;
    i dragged it out of `Photos.app` into 
    [Yoink](https://eternalstorms.at/yoink/mac/)
    and then from yoink into Finder
4. `-c:v h264_videotoolbox` 
    i generally want to use the hardware encoder on this machine
    (m1 pro) because it's fast
5. `-maxrate 2600K -bufsize 2600K`
    these settings match what my mastodon server expects;
    i think `maxrate` controls how many bytes/sec it'll output
    (2.6mb in this case), 
    and `bufsize` is a rolling buffer that can allow the maxrate to be
    deviated from?
6. `-vf` the next command is a video filter 
    (which i'll annotate the comma-delimited parts separately)
7. `zscale=t=linear:npl=100` Transfer the images to a linear 
    brightness scale, 
    with a Nominal Peak Luminance of 100
8. `format=gbrpf32le`
    change the pixel format to something presumably easier 
    or more accurate to work with,
    "IEEE-754 single precision planar GBR 4:4:4, 96bpp, little-endian"
9. `zscale=p=bt709`
    set the color Primaries to
    [BT.709](https://en.wikipedia.org/wiki/Rec._709)
10. `tonemap=tonemap=hable:desat=0`
    use the "Hable" tonemapping algorithm to
    scoot all the colors into the correct range,
    and don't desaturate anything that would be blown out
    towards white
11. `zscale=t=bt709:m=bt709:r=tv`
    Transfer the images to BT.709,
    set the color matrix to BT.709,
    and set the color range to a standard
    TV range
    (yeah television, as opposed to Personal Computer)
    of 16-235 instead of 0-255
12. `scale='trunc(iw/2):trunc(ih/2)'`
    size the image down to half of each dimension,
    `trunc` rounds the "Input Width / 2" (and Input Height)
    towards zero
13. `format=yuv420p`
    change the pixel format to YUV 4:2:0
14. `-c:a aac` compress the audio with AAC
15. `-pix_fmt yuv420p` save it as YUV 4:2:0
16 `aperture2.mp4` the output filename