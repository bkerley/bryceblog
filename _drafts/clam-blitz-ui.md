---
layout: post
title: "Indicators in Splatoon 3 Clam Blitz"
tags:
    - since-2021
    - game
    - interface
kind: regular
css_id: splatoon
---

<link rel="stylesheet" href="{{"/assets/splatoon.css" | relative_url }}">

[Codl](https://chitter.xyz/@codl), an e-friend on Mastodon,
had a question about how clam count indicators
worked in Splatoon 3 Clam Blitz:

<div class="social mastodon">

<div class="avatar round">
<a href="https://chitter.xyz/@codl">
<img alt="a painting of a bee from neck up, with eyes closed, wearing flowers on their head" src="/assets/post_images/clam-blitz-ui/codl-av.png">
</a>
</div>

<div class="screenname">

[codl 🐝](https://chitter.xyz/@codl)

</div>

<div class="username">

[@codl@chitter.xyz](https://chitter.xyz/@codl)

</div>

<div class="content">

<p class="content-note">splat 3</p>

<p>there&#39;s two different treatments for those clam count indicators and I don&#39;t understand what they mean exactly</p><p>like at first glance it seems like the coloured indicator goes to whomever has most clams, but i have seen counterexamples</p>
</div>

<ul class="attachments">
<li>
<img alt="a white '2' in a red colored disc with a light grey outline" src="/assets/post_images/clam-blitz-ui/codl-colored-disc.png">
</li>

<li>
<img alt="a red '3' in a dark-red disc with no outline" src="/assets/post_images/clam-blitz-ui/codl-dark-disc.png">
</li>
</ul>

<div class="timestamp">

[December 23, 2022 at 7:51 PM](https://chitter.xyz/@codl/109565909095519973)

</div>

<div class="credit">

from <https://chitter.xyz/@codl/109565909095519973>

</div>

</div>

There's some important context for 
why I found this question really interesting.

# What is Splatoon?

Splatoon is a series of third-person shooters from Nintendo.
You play a kid, sometimes a squid[^octo],
rendered with considerable artistic license,
either locked in a solo or 
player-vs-enemy (PvE) existential
struggle of some sort,
or a player-vs-player contest for fun and in-game prizes.
Players can walk 
and shoot ink out of cartoonish weapons
(many like repurposed real-world gadgets)
XXXX ballpoint splatling goes here XXXX
in kid form,
swim and re-up on ink in squid form,
and return to the spawn point after being
blasted with too much opponent ink 
("splatted," not killed) in ghost form.

[^octo]: or an octopus

In each stage (map), most floors and some walls accept ink.
On un-inked ground, you can walk as a kid or
slowly push yourself in squid form.
You can walk fast and swim even faster in
friendly ink.
You take damage in opponents' ink, 
but can still move.
It's always valuable to spread ink
(from a gun, grenade, or special weapon)
where you or a teammate might want to move,
and your opponents are trying to do the same.

If you get too much opponents' ink on you
(either from their attacks or 
just from spending too much time in their ink)
you get "splatted" with a big pop, 
a surprised exclamation,
and a corona of their ink.
Outside of the PvE Salmon Run mode,
your ghost makes it back to your team's
end of the stage to respawn in a few seconds.

[^brushfast]: brushes let you run at 

Splatoon doesn't look like other 
big multiplayer shooters.
The inks are bright and vivid, splashy and wet.
Once you're in the thick of a
match,
an incredible amount of activity to keep track of,
because matches only last a few minutes and
even when you're passing through uncontested territory
you have to pay attention to the goal of the current game mode.

The unranked[^unranked] "Turf War" mode is straightforward: 
the team that's got more of the floor in their ink 
at the end of three minutes wins.

[^unranked]: it's absolutely tracking how good you are,
    just not giving you a visible rank to fret about

There are four ranked[^anarchy] modes too.
"Splat Zones" require teams to keep one or more
of the z0nes on the map in their color for a period of time.
"Tower Control" require teams to stand on a mobile tower 
to move it into the opponents' base to win.
"Rainmaker" is football (either kind) but the football is
a slow-charging bazooka you deliver to the opponents'
goal to win.

XXXX is there an official clam blitz explainer? XXXX

And finally, "Clam Blitz" is complicated.
Teams gather clams from around the stage.
When a player has enough 
(ten in Splatoon 2, eight in Splatoon 3)
they form a "power clam."
Once a power clam is in play, 
the goal is to put it in the opponents'
basket, breaking the barrier.
With the barrier down, 
attackers can throw
any clams (including power clams) in for points.
After a while, the barrier goes back up,
and the team defending it gets a free power clam.
There's a complex 
[ebb and flow](https://splatoonwiki.org/wiki/Ebb_%26_Flow)
to it, an extra layer of chaos to an already frantic game.

[^anarchy]: in Splatoon 3 the battles that establish a
    meritocratic hierarchy among players 
    are called "Anarchy Battles"
    
# Interface Design and Human Factors


XXXX ink tank images XXXX

You can categorize the way action games
communicate state to the player based on diegesis.
Seeing your ink tank empty on your octolings' back
is as diegetic as
[The Dude's Credence tapes](https://www.youtube.com/watch?v=SjBBDJ5OiT0).
It's part of the same world the characters inhabit.
Watching it refill as a UI element vaguely tethered
to your swimming form is non-diegetic,
much as
["The Blue Danube"](https://www.youtube.com/watch?v=0ZoSYsNADtY)
isn't actually playing among spaceships in hard vacuum.

Splatoon uses both of these.
When it's viable to do so, 
state's diegetic.
Splat zones get highlighting around the edges 
XXXX do they?
when they change control,
the tower and the rainmaker are both physical objects
(and they can hurt you),
and once you've picked up clams they follow you around in a little line.
However, it's not always viable, 
and some parts of the game rate non-diegetic UI.
The tower, rainmaker, and power clams get 
a permanent overlaid icon on your screen
no matter how far away they are.

XXXX talk about the sheer amount of stuff happening in 720p

XXXX you can't communicate everything, gotta prioritize

https://youtu.be/4FwwBYzU2gE

# Clam Discs

XXXX original thread 

experiment design

wild hypotheses

hypothetical implementation

`FollowIcon` abstract class

subclasses implement `u8 priority()`; 
persistent stuff returns u8_max,
players with clams have to query game state, 
other players with clams,
doesn't necessarily update each frame

soft budgets for `FollowIcon`s,
low-priority ones may disappear,
high-priority ones may stick around,
hysteresis to keep them from flickering

# Conclusion

not a data miner but might be interesting to a
bored data miner that's also in UI design?

Thanks codl 
for nerd sniping me with this,
and ctrl-alt-dog/cinnamon
for helping out with the experiment.

