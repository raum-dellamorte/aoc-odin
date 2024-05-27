Advent Of Code 2022
===================

I've become obsessed with Day 09... The Rope Bridge.

After getting the answer right I wanted to see it. I initially wrote it in Odin,
then for the visualization I wrote it again in Rust doing the WASM thing and
animating it with Unicode emoji which was neat, but then I wanted to do more Odin.

So back to this place, back to this time, again and again...

What? Nevermind. I wanted to learn Raylib in Odin. It was easier, this time, at
least in the beginning. At the moment, I'm trying to get textured rendering going,
which means shaders and whatnot, and I will have to come back to that.

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
