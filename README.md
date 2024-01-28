# Joust
A source code rewrite to the 1982 arcade game

****

Game Designer: John Newcomer

Main Programmer: Bill Pfutzenreuter

Other Programmers: Cary Kolker and Ken Lantz

Sound ROM (VSNDRM4) main programmers: John Kotlarik and Tim Murphy

Source code rewrite by SynaMax, started January 25th, 2024

****
## Important milestones

* 01/27/2024 - The rewritten code now assembles up to address $5ED0 and matches up perfectly with the first six ROMs for the game.  This includes all the sprite images for every game object, the message display routines, font sprites, and all the strings.   The game program itself is up next and exists entirely in one file that's over 8000 lines of code.  This is going to take a while to rewrite.  It's going to be a bit of a challenge without any pre-existing equates listing but I have a disassembly of the    game to help out.
* 01/25/2024 - Starting rewriting Joust's code today.  Already got all the sprites to assemble with Macroassembler {AS}...that's almost the first four ROMs!


## Overview

Following Defender, Robotron, and Sinistar, Joust is the latest Williams Electronics arcade game to have its source code retargeted for a newer assembler.  Because Sinistar and Joust's codebases contain a lot of similarities, I am reusing Macroassembler {AS} as the new assembler to build this game.

Sinistar's codebase - while more complex and featuring way more source files - also came with ```EQU``` and ```SET``` files that were extremely helpful in mapping out all the symbols and their addresses.  We don't have this luxury with Joust's code unfortunately.
