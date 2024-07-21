---
layout: post
date: '2024-07-20T22:55:00-04:00'
title: "Exporting Images and Videos from a Nintendo Switch to a Mac"
tags:
    - since-2021
    - game
    - nintendo-switch
kind: regular
---

The Nintendo Switch 
saves a screenshot when you press the "capture" button,
and saves a 30-second video when you hold down the "capture button" 
for a couple seconds until it pops up that it's saving a video.
The capture button is the square with a circle, 
[normally on the left Joy-con][joycon], 
[on the bottom-left of the logo][pro] on the Pro controller,
or [at the bottom-left corner of the screen][lite] on the Lite Switch.

[joycon]: https://en-americas-support.nintendo.com/app/answers/detail/a_id/22634
[pro]: https://en-americas-support.nintendo.com/app/answers/detail/a_id/27538
[lite]: https://en-americas-support.nintendo.com/app/answers/detail/a_id/47285

Getting these out sucks.

# The Old Old Way That Some Asshole Broke For Bad Reasons

You used to be able to post images or videos to Twitter, 
and using their streaming API, 
automatically scoop them up.
I liked to use this to have the images automatically post to
[my fediverse account](https://m.bonzoesc.net/@bonzoesc).

Then some guy bought Twitter to ruin it and made this cost
an exorbitant sum.

# The Old Way That The Same Guy Made Untenable for Nintendo

You used to be able to post images or videos to Twitter,
scrape the URLs for images or a video,
and then download them.

However, Twitter's contract with Nintendo ended or something,
and they didn't want to pay the asking price to renew it,
so you can't post images or videos to Twitter from a Switch anymore.

# The New Way that Kinda Sucks but is Completely Local so It'll Keep Working

I guess in some recent update,
the Switch got a
[Media Transfer Protocol (MTP)](https://en.wikipedia.org/wiki/Media_Transfer_Protocol)
server.
MTP isn't super-well supported on Mac, 
but you can get software that works with the Switch's implementation.

These instructions work on a
2021 M1 Pro Mac running macOS 14.5.

These instructions depend on the "Android File Transfer" app,
which Google has made difficult to find because it's useful.
It's in [Homebrew][brew], 
and if you're reasonably code-savvy the Homebrew formula for it
can help you find the URL to download it.

[brew]: https://brew.sh

1. On your Mac, install the "Android File Transfer" app,
   either from [Google](https://dl.google.com/dl/androidjumper/mtp/current/androidfiletransfer.dmg)
   or `brew install android-file-transfer`.
1. On the Switch, hit the home button to go to the home screen
2. Go into "System Settings" 
   (the gear icon in the bottom row of stuff)
3. Scroll the left column to "Data Management" 
   (on my up-to-date Switch it's just below the first screen of options)
   and go into it
4. Scroll and click into "Manage Screenshots and Videos" on the right column, 
   it's second-from-last
5. The last option on the screen that pops up should be
   "Copy to a Computer via USB Connection"; tap on it
6. Plug the Switch into the Mac with a USB-C cable.
   I used a USB-C Thunderbolt cable that came with
   my CFExpress reader and found it to be fussy
   with which side up each end is.
7. Open the "Android File Transfer" app on the Mac
8. You should see folders for each game
   you've captured screenshots or videos in
9. Drag them where you want them

# Other Software I Tried

* Apple-shipped software didn't see media on the Switch. This includes:
  * Preview
  * Image Capture
  * Photos
* Adobe Lightroom (the clod version, not classic) didn't see any media either
* [OpenMTP Version 3.2.25](https://github.com/ganeshrvel/openmtp)
  wouldn't stay connected if I navigated directories.

# Wish List

It would be cool if Nintendo put these
on the Switch but it would also be cool
if someone bought me that new R5 Mk 2 lol.

1. Mastodon client
2. HTTP server I can hit [without having to join a special wifi][common-man]
1. URL field to POST files to
2. S3 credentials to upload images or videos to
4. Discord client

[common-man]: https://en-americas-support.nintendo.com/app/answers/detail/a_id/53138
