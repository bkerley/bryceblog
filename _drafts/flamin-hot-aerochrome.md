---
layout: post
title: Flamin' Hot Aerochrome
tags: photography art
---

Aerochrome was a Kodak film
used to assess the health of vegetation
and discern vegetation
from things camouflaged like vegetation.
Shot with a yellow filter (that removes blue),
red in the scene becomes green,
green in the scene becomes blue,
and infrared in the scene becomes a vivid red.
It's a cool effect,
but since the film got discontinued over fifteen years ago,
it's not ten bucks a shot cool.

<aside>

Yeah we're talkin' film photography.
In 2025 I internalize it as being about $1 a shot,
although some film stocks are more expensive,
and some are less.

Film is more expensive than shooting on a Rebel
or other used entry-level DSLR.
Film has a lot of character,
but to me what's just as interesting is how
the perceived cost and actual inconvenience
make it a more deliberate experience than
taking out a modern mirrorless and shooting
3000 shots in an afternoon like at the
Kentucky 3 Day Event.

This article discusses photography as an
artistic pursuit,
and a particular process in digital photography
to recreate an analog process that is no longer
accessible to the vast majority of people.
It's not about "better," merely "possible."

</aside>

[Jason "grainydays" Kummerfeldt](https://www.youtube.com/@grainydaysss)
produces documentaries about photography,
primarily film in the western US,
and has on many occasions showcased the Aerochrome look.
He sometimes opens or closes videos by
chugging a can of 
Flamin' Hot Cheetos Mountain Dew
(I do not want this in my life,
please do not 
bring some to Toorcamp or DEF CON and 
do not let me have any)
as a protest to get Kodak to restart manufacturing of
this specialized industrial film that is
entirely superseded by digital technology.

About two years ago,
he released a video
["How I Fake Kodak Aerochrome"](https://www.youtube.com/watch?v=v5KBQd_DkQw)
that demonstrates his "Flamin' Hot Aerochrome"
technique to recreate the look on film.

# Shooting Infrared on Digital

People can't see infrared[^infrared],
people mostly expect cameras to photograph something
akin to what they see,
so digital cameras ship with a "hot mirror"
that reflects infrared away from the sensor.

[^infrared]: people in the proximity of
    infrared georg who shorted out the resistor
    on their DEF CON 16 badge to make the infrared LED
    so strong it could turn HP laptops on while in a bag
    are outliers and should not be counted

If you remove this hot mirror
(or pay a professional to remove it)
all the channels on the sensor will receive infrared.
This is what we're interested in, but it has caveats.

Different wavelengths of light 
go through lenses differently.
This is what makes rainbows and the
cover art of "Dark Side of the Moon" that way.
Lens designers put in a ton of effort to make
lenses that handle the visible spectrum in a sensible way,
but often infrared gets sidelined.

Some lenses will have indications 
for how to focus for infrared.
The manual for my
Canon EF50mm f/1.4 USM says:

> The infrared index corrects the focus setting when using monochrome infrared film. 
> Focus on the subject in MF, then adjust the distance setting by moving the focusing ring to the corresponding infrared index mark.

That's a lens for Canon EF, a system for
Single Lens Reflex (SLR) cameras.
SLRs with autofocus
generally have autofocus sensors in the viewfinder path,
so you can focus while you look through the lens
and then have the sensor flip out of the way of the
medium (whether it's film or an electronic sensor) to shoot.
If you put an infrared sensitive medium in these cameras,
it won't affect the focus sensor, 
so it makes sense to require a manual step.

I got a mirrorless body modified[^mirrorless], which is
*so* much better in this regard.
It can mount any EF lens with an adapter,
and the focus sensor is the image medium,
so no correction for IR is needed.

[^mirrorless]: a Canon EOS R, their first full-frame
    mirrorless.

The technique in this article relies on being able to
have infrared coming in on only one channel,
and not mixed in to every channel.
To achieve this,
we use a yellow filter that blocks
blue light,
and then subtract the blue channel
from the red and green channels.

# Jason's Technique

I really recommend watching the video
(and all of Jason's videos tbh),
but the technique is:

1. Shoot with a yellow filter and UV filter on a
   full-spectrum modified digital camera,
   producing an image with the channels:
   * red = red + ir
   * green = green + ir
   * blue = ir
2. Open the image in Photoshop.
3. Duplicate the original image into three new layers,
   labeled "red", "green", and "blue".
4. Attach a channel mixer adjustment layer 
   to the red base image
   that routes 100% of the red channel of that layer
   to the red, green, and blue channels.
5. Group the red base and its channel mixer into a layer group.
6. Repeat the channel mixer and group stages
   for the green and blue bases.
   You should now have "red," "green," and "blue" groups
   that each make a black and white image 
   out of one of the channels of the base image.
8. Grab the blue layer group, 
   duplicate it,
   and merge it into a new layer labeled "infrared".
9. Move the "infrared" layer above the channel mixer in the
   "red" group.
   Change the blend mode to "subtract"
   and set the opacity to "around 50%, for starters."
10. Add a "curves" adjustment layer 
    above the infrared layer,
    and pull the center of that down a bit.
11. Duplicate the "infrared" layer and 
    put it on top in the "green" group.
12. Set the green group's infrared layer 
    to subtract 80% instead of 50%.
13. Put a curves adjustment layer
    *below* the green group's infrared layer,
    and boost its center ("gamma") "just a little bit."
14. Back in the "blue" group,
    add a curves adjustment layer to the top, 
    and "heave" the center of that down just a bit.
15. Add a channel mixer to the top of the "red" group
    and zero out its red and blue outputs,
    only outputting green.
16. Add a channel mixer to the top of the "green" group
    and zero out its red and green outputs,
    only outputting blue.
17. Add a channel mixer to the top of the "blue" group
    and zero out its green and blue outputs,
    only outputting red.
18. Set the top two groups' blend modes to
    "screen".
19. Add a curves adjustment layer above all three groups,
    and fix the exposure of the image with it.
20. Finally, go in and make tweaks to the various adjustment
    layers and blend opacities to fit your artistic goals.

Once he's happy with the image,
Jason then points a film SLR at it,
photographs it on to slide film,
and has it printed.

# My Lightroom & Photoshop Workflow

I use Lightroom
(the cloud one, not classic)
for most of my non-phone photography. 
It syncs well between phone, tablet, laptop, and desktop.
For more storage space I just throw money at Adobe
instead of figuring out how to juggle additional
disks between the computers I want to use.

This workflow only works on computers though,
because it needs the channel mixer layer,
which as far as I can tell hasn't made it to
Photoshop on my phone.

1. Import into Lightroom.
1. Remove any dust, trash, [Yezhovs][yezhov], bugs,
   etc. 
   using the removal tools.
3. Open the image in Photoshop.
   On Mac it's ⌘⇧E, 
   or you can right-click the thumbnail in the tray.
2. Add a channel mixer above the
   background layer,
   set:
    * red output = red 0%, green 0%, blue +100%
    * green output = red +100%, green 0%, blue -50%
    * blue output = red 0%, green +100%, blue -80%
3. Between the channel mixer and background layer,
  add a curves layer.
  I typically pull the blue down a bit,
  and mess with red and green's centerpoints
  until I'm either mostly happy with the result
  or decide I hate it.
4. Save it, close it,
  watch it get imported into Lightroom as
  a new image.
7. Make any geometry or other changes in Lightroom.

The channel mixer part I have a macro of,
but I should probably just cut a macro
of the entirety of Jason's process.

On the other hand,
since mine is just adjustment layers,
it's expressible as a look-up table
("LUT" file, `.cube` is a common file extension).

## Lightroom and a Flamin' Hot Look-Up Table

XXXX TODO 4I5A8038.CR3

I started with this picture from the beach at sunrise,
twisted[^twisted] it in Photoshop, 
and made a few tweaks to get it to look good.
Before bringing it back into Lightroom,
I hit "save as copy" 
(so I could keep the PSD hanging around),
and exported the grouped 
channel mixer and curves adjustment layers as a LUT.

[^twisted]: I often use "twisted" or "spun" or other rotational
    terms when talking about this process.
    Hue is a circle and often expressed as a number
    `0º ≤ H < 360º`, 
    wrapping around 
    from just barely purpley-red at 359.9º 
    to red at 0º.
    The channel mixer setting to send
    blue to red, red to green, and green to blue
    is basically the same as adding 120º to the hue
    of every pixel all at once.

Once I was done in Photoshop, 
I duplicated the original image in Lightroom
so I could have three different versions:

* original without any IR specific stuff
* Flamin' Hot process done in PS, 
  tweaks and tune-ups in LR
* LUT applied as a "Profile" in LR

Sadly, I found that the LUT via Profile happens last in LR, 
which means the tweaks after applying
the channel mixing can't be made.
These edits aren't commutative,
and LR simply[^ordering] won't let you do things out of order.

[^ordering]: "simply" here basically means 
  "correctly for most workflows."
  There's a processing order that makes sense
  artistically and works numerically
  for most photos,
  and making it the only thing that LR provides
  is good for the majority of users that just want to
  develop a photo normal style.
  "Edit in Photoshop" is a good escape hatch
  for the weird stuff.

# Acorn

I've played around with this in [Acorn][acorn].
Acorn is great, if you're on Mac you should
just have this, it launches real fast
and does like 90% of what I want to do with
images.

[acorn]: https://flyingmeat.com/acorn/

It works! 
It uses Apple's built-in raw image loading,
You can import a LUT as an effect layer,
and resequence it with other layers.
Last time I emailed the developers,
there wasn't a channel mixer, but whatever.


# Da Vinci Resolve

My friend Josef put together something in
Da Vinci Resolve that worked,
although I don't know what the story is there
with importing a camera raw or exporting to
something for web or print.

# GNU Image Manipulation Program

This refused to open a camera raw,
which kinda understandable.
Giving it a tiff I exported from Acorn,
it was pretty easy to remix the channels,
and it keeps the mixer and curves as layers
instead of just baking the pixels.

That said,
the UI on Mac is somehow 
more frustrating than both Photoshop and Lightroom,
and isn't even in the same reality as Acorn's.
It doesn't feel fast or reactive at all,
updating previews in tiles from the top-left instead of doing a low-resolution proxy while it figures out the whole image.

# Closing Thoughts

Infrared has been a ton of fun
to shoot with,
whether or not I run the resulting image
through the Flamin' Hot Aerochrome
process or not.
I can't see it being something I use
all the time,
but it's been super neat to see
how the world looks through that
particular electric eye.

This technique has opened up
a bunch of new possibilities for
how to create art for me.
I hope this post has been some kind
of inspiration for you,
and that you can use it to find a
new vision for yourself too.
