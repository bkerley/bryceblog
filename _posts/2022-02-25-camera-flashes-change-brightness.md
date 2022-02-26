---
layout: post
title: "Camera Flashes Change Brightness"
tags:
    - camera
    - experiment
    - since-2021
kind: regular
css_id: camera-flashes
date: '2022-02-25T23:45:00-05:00'
---

<style type="text/css">
#camera-flashes div.two-figures {
    display: grid;
    grid-template-columns: 1fr 1fr;
}

#camera-flashes div.two-figures img {
    aspect-ratio: auto;
    width: auto;
    height: auto;
}
</style>

Someone posted two near-identical pictures in a chat, 
one darker than the other, but the darker one was shot
with a higher "ISO" sensitivity[^iso].
I got confused and found out it was because the flash fired,
but that confused me a bit more because I didn't know that
camera flashes could change brightness.

[^iso]: There's a lot of history here but the quick version is
    that there are ISO standards for photographic media sensitivity.
    The less-quick version is
    <https://en.wikipedia.org/wiki/Film_speed>

> &lt;bryce&gt; oh god i am coming up with an absolutely perverted way to 
> figure out if the flash is going to a different brightness
>
> &lt;bryce&gt; fire a long exposure on the rebel [cheap DSLR camera] 
> pointed at a wall in the closed and dark bathroom, 
> and shoot the flash on the r [less-cheap mirrorless camera]
> from outside the bathroom

# Hypothesis

Camera settings can cause the flash to fire at different brightnesses.
Specifically, taking a picture in the same lighting conditions with
different ISO settings will cause the flash to fire brighter with the
less-sensitive settings.

# Materials

* Digital camera with flash "flashing camera"
* Digital camera "capturing camera". 
    If this camera is relatively loud (SLR, not mirrorless) that's a plus.
* Tripods
* Two rooms with at least one door between them, one should have light-colored surfaces opposite the door

# Procedure

<div class="two-figures" markdown="0">
<figure>
<img alt="an interchangeable lens camera on a short tripod on a bathroom floor" src="/assets/post_images/camera-flash/IMG_3745-1008x1344.jpeg" width="504" height="672">
<figcaption>The capturing camera</figcaption>
</figure>

<figure>
<img alt="a camera in a dark room pointing at a door, beyond which is a brightly lit room; on the camera's rear LCD is the door" src="/assets/post_images/camera-flash/IMG_3746-1008x1344.jpeg" width="504" height="672">
<figcaption>The flashing camera</figcaption>
</figure>
</div>

0. Configure the capturing camera to
    * manual mode
    * manual focus
    * 10-second self-timer
    * the highest sensitivity it has
    * the widest aperture
    * a 10-second shutter speed
    * do not fire a flash
1. Configure the flashing camera to
    * aperture priority
    * single shot, no timer
    * ISO 100 sensitivity
    * fire that flash
1. Set up the capturing camera in one room, 
    pointing away from the door and towards a light surface.
2. Set up the flashing camera in another room, 
    pointing towards the capturing camera.
3. Turn off all the lights you don't absolutely need to 
    navigate between and take pictures on both cameras.
4. Start the timer on the capturing camera
5. Close the door
6. Wait for the shot to start and finish. 
    This is the control shot (no flash).
5. Start the timer on the capturing camera
6. Close the door
7. Half-push the shutter on the flashing camera to arm it
8. Wait for the capturing camera's shutter to open
9. Fire the flashing camera
9. Wait for the capturing camera's shot to finish.
10. Crank the ISO on the flashing camera up.
5. Start the timer on the capturing camera
6. Close the door
7. Half-push the shutter on the flashing camera to arm it
8. Wait for the capturing camera's shutter to open
9. Fire the flashing camera
9. Wait for the capturing camera's shot to finish.

# Results

<table>
    <thead>
        <tr>
            <th>Description</th>
            <th>Flashing camera saw</th>
            <th>Capturing camera saw</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Lights on, aperture priority</td>
            <td>no picture taken</td>
            <td><img alt="cabinets, a toilet, and a bathtub with glass door, lit by white light" src="/assets/post_images/camera-flash/IMG_5218-343x228.jpg"></td>
        </tr>
        <tr>
            <td>Control shot</td>
            <td>no picture taken</td>
            <td><img alt="a camera on a tripod, backlit in red, reflected in a shower door beyond a toilet; a dim red glow is visible from under the door behind the camera" src="/assets/post_images/camera-flash/IMG_5215-343x228.jpg"></td>
        </tr>
        <tr>
            <td>ISO 100</td>
            <td><img alt="blinds, an open doorway, and a closed door" src="/assets/post_images/camera-flash/IBR_5724-343x228.jpg"></td>
            <td><img alt="a camera on a tripod, backlit in red, reflected in a shower door beyond a toilet; a whitish-red glow is visible from under the door behind the camera" src="/assets/post_images/camera-flash/IMG_5216-343x228.jpg"></td>
        </tr>
        <tr>
            <td>ISO 1600</td>
            <td><img alt="blinds, an open doorway, and a closed door; it's somewhat brighter than the previous image" src="/assets/post_images/camera-flash/IBR_5725-343x228.jpg"></td>
            <td><img alt="a camera on a tripod, backlit in red, reflected in a shower door beyond a toilet; a red glow with a hint of white is visible from under the door behind the camera" src="/assets/post_images/camera-flash/IMG_5217-343x228.jpg"></td>
        </tr>
    </tbody>
</table>

# Conclusion

The capturing camera saw more white light when 
the flashing camera was set to ISO 100 than ISO 1600,
therefore the brightness of the camera flash is affected
by camera settings.

# Thanks

Thanks to the gang in the CRD discord for making me do this.