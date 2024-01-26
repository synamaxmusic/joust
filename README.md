# Joust
A source code rewrite to the 1982 arcade game

****

Game Designer: John Newcomer

Main Programmer: Bill Pfutzenreuter

Other Programmers: Cary Kolker and Ken Lantz

Sound ROM (VSNDRM4) main programmers: John Kotlarik and Tim Murphy

Source code rewrite by SynaMax, started January 25th, 2024

****

Following Defender, Robotron, and Sinistar, Joust is the latest Williams Electronics arcade game to have its source code retargeted for a newer assembler.  Because Sinistar and Joust's codebases contain a lot of similarities, I am reusing Macroassembler {AS} as the new assembler to build this game.

Sinistar's codebase - while more complex and featuring way more source files - also came with ```EQU``` and ```SET``` files that were extremely helpful in mapping out all the symbols and their addresses.  We don't have this luxury with Joust's code unfortunately.
