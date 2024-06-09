Advent Of Code 2022
===================

I've become obsessed with Day 09... The Rope Bridge.

After getting the answer right I wanted to see it. I initially wrote it in Odin,
then for the visualization I wrote it again in Rust doing the WASM thing and
animating it with Unicode emoji which was neat, but then I wanted to do more Odin.

So back to this place, back to this time, again and again...

What? Nevermind. I wanted to learn Raylib in Odin. It was easier, this time, at
least in the beginning.

At the moment, my goal is a texture atlas for the instanced rendering which was
the last thing I got working.

Until next time...

Usage:
======
Specifically with Day 09 as the primary example...
```
$ odin run . -- day09
```

DevLog:
===========
0001: I thought the "Player" wasn't being drawn, but it is! Not rotated how I
expected... And smaller... The cubes I'm using for the "rope" are double the size
of my "Player". At the moment you can move the camera around but I broke "Player"
movement. If you want to watch the whole show you have to move the camera to follow
the rope. I can draw something on ever new space links 1 and 9 touch, link 0 being 
the head, but the way I was doing it slows the whole thing down and then it crashes
after a while. I could maybe draw and update a big texture, or several, underneath
the rope... But what I want to achieve is instanced rendering. I got instanced
rendering working in a Kotlin project a long time ago, but the codebase became such
a mess and I couldn't seem to clean it up without breaking it. Since then,
instanced rendering has been my white whale. Gotta get over that hurdle. And it
needs to be readable and understandable. Kotlin let me get away with too much.
I like the way Odin makes me feel, UwU. Until it segfaults and I don't know why.

0002: When you load a model it has a materials array attached to it. It appears
that each Material needs to have a Shader attached to it. So THAT's how you use
a shader! I've been going up and down
[this](https://github.com/ChrisDill/raylib-instancing/blob/master/src/instancing/asteroids_instanced.c)
instanced rendering example in C (in which I'm not even sure what version of Raylib
is being targeted), attempting to work backwards to identify the minimum requirements
for accomplishing instanced rendering (in my spare time between depression's lethargy
and work hence the slow progress), and I finally noticed that they were assigning
the shader they had loaded to the material of the model. At this point I'm not sure
what all is contained in a Material. I'll look into it one day. Next goal is to have
each instance access it's own texture from an atlas, specifically so that locations
touched only by link 1 have a different texture from those touched only by link 9, which
is different from links touched by both.

0003: This last commit involved staying up too late when I have to be up early. That's
the only way to get real work done. When you *should not* be doing what you're doing,
you'll do your *best* work. 6 hours. I made a new cube in blender with the goal of being
able to shift texture coordinates down by around 170px to get to the next texture in
my roll-your-own atlas texture, and probably spent too long on that bc I didn't start with
the code until I should have been in bed, I think. So, in the code, an array of floats was
needed for per instance y offsets and luckily I had the information about each instance I
needed already ready already with the DrawMe enum. Past me DID think about these things!
The rest of the time was spent figuring out how to pass the data to the shader in a way
that C understands. I'm finishing this entry days later so the details have become a bit
muddy, but I had to use the rl.SetShaderValueV function to get my offsets loaded and by
only several hours after bedtime I had tiny instanced squares in 3 colors! And that uses
only half the atlas! I could add details to those cubes of I wanted to. Stupid, meaningless
details for a "rope simulation" from Advent Of Code 2022, Day 09. I could... And I might...
