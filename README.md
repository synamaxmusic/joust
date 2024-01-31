# Joust
A source code rewrite to the 1982 arcade game

Source code rewrite by SynaMax, started January 25th, 2024; complete ROM set rebuilt for the first time on January 29, 2024

****

Game Designer: John Newcomer

Main Programmer: Bill Pfutzenreuter

Other Programmers: Cary Kolker and Ken Lantz

Sound ROM (VSNDRM4) main programmers: John Kotlarik and Tim Murphy

****

The original source code for the game can be found at https://github.com/historicalsource/joust/

For the first time ever, the source code for the sound ROM is included with the game code.  The original sound ROM source can be found here: https://github.com/historicalsource/williams-soundroms/blob/main/VSNDRM4.SRC

****

<!-- vim-markdown-toc GFM -->

* [Important Milestones](#important-milestones)
* [Build Instructions](#build-instructions)
  	* [Game code](#game-code)
  	* [Sound ROM](#sound-rom)
  	* [Decoder ROMs 4 & 6](#decoder-roms-4--6)
* [Overview](#overview)
* [Rewriting the source code](#rewriting-the-source-code)
 	* [Local labels](#local-labels)
  * [Invalid symbols](#invalid-symbols)
  * [BSO Syntax](#bso-syntax)
  * [Common fixes](#common-fixes)
  * [Inconsistent label names](#inconsistent-label-names)
<!-- vim-markdown-toc -->

****


## Important milestones

* 01/30/2024 - After MONTHS of trying to figure out how to get Tim Murphy's Walsh Function Sound Machine macros to work, I finally succeeded in producing the correct binary data that matches up with the sound ROM.  This is huge as this also applies to Sinistar's sound ROM as well.  In layman's terms, this means we can accurately rebuild the data for the "Pterodactyl Scream" and "Ostrich Skid" sound effects ***exactly*** as how it was done in 1982!  
* 01/29/2024 (Cont'd) - ROM 12 and Video Sound ROM 4 are complete!  The entire game is completely rebuildable now!
* 01/29/2024 - ROMs 1 through 11 ($0000-$EFFF) for Joust now match up perfectly!  All that remains is the sound rom and Test ROM ($F000).
* 01/27/2024 - The rewritten code now assembles up to address $5ED0 and matches up perfectly with the first six ROMs for the game.  This includes all the sprite images for every game object, the message display routines, font sprites, and all the strings.   The game program itself is up next and exists entirely in one file that's over 8000 lines of code.  This is going to take a while to rewrite.  It's going to be a bit of a challenge without any pre-existing equates listing but I have a disassembly of the    game to help out.
* 01/25/2024 - Starting rewriting Joust's code today.  Already got all the sprites to assemble with Macroassembler {AS}...that's almost the first four ROMs!

## Build Instructions

This source code was rewritten to target [Macro Assembler {AS}](http://john.ccac.rwth-aachen.de:8000/as/index.html).  

### Game code

To build Joust, place the ASL and P2BIN executables in the same directory with all the source files from the repository.

Then, open a command prompt and type in:

```sh
asl make.asm -o joust.p
```
Once the ```joust.p``` file is generated, we can use the ```BURN.BAT``` file to create the 12 separate ROM files that make up Joust.

Address|ROM #|MAME ROM set Filename
| --- | --- | --- |
0000-0FFF|ROM 1|joust_rom_1b_3006-13.e4
1000-1FFF|ROM 2|joust_rom_2b_3006-14.c4
2000-2FFF|ROM 3|joust_rom_3b_3006-15.a4
3000-3FFF|ROM 4|joust_rom_4b_3006-16.e5
4000-4FFF|ROM 5|joust_rom_5b_3006-17.c5
5000-5FFF|ROM 6|joust_rom_6b_3006-18.a5
6000-6FFF|ROM 7|joust_rom_7b_3006-19.e6
7000-7FFF|ROM 8|joust_rom_8b_3006-20.c6
8000-8FFF|ROM 9|joust_rom_9b_3006-21.a6
9000-CFFF| |(SPACE RESERVED FOR RAM)
D000-DFFF|ROM 10|joust_rom_10b_3006-22.a7
E000-EFFF|ROM 11|joust_rom_11b_3006-23.c7
F000-FFFF|ROM 12|joust_rom_12b_3006-24.e7

If it's not possible to use ```BURN.BAT```, this can be typed into a command prompt instead:

```sh
p2bin joust.p joust_rom_1b_3006-13.e4 -l 00 -r $0000-$0FFF
p2bin joust.p joust_rom_2b_3006-14.c4 -l 00 -r $1000-$1FFF
p2bin joust.p joust_rom_3b_3006-15.a4 -l 00 -r $2000-$2FFF
p2bin joust.p joust_rom_4b_3006-16.e5 -l 00 -r $3000-$3FFF
p2bin joust.p joust_rom_5b_3006-17.c5 -l 00 -r $4000-$4FFF
p2bin joust.p joust_rom_6b_3006-18.a5 -l 00 -r $5000-$5FFF
p2bin joust.p joust_rom_7b_3006-19.e6 -l 00 -r $6000-$6FFF
p2bin joust.p joust_rom_8b_3006-20.c6 -l 00 -r $7000-$7FFF
p2bin joust.p joust_rom_9b_3006-21.a6 -l 00 -r $8000-$8FFF
p2bin joust.p joust_rom_10b_3006-22.a7 -l 00 -r $D000-$DFFF
p2bin joust.p joust_rom_11b_3006-23.c7 -l 00 -r $E000-$EFFF
p2bin joust.p joust_rom_12b_3006-24.e7 -l 00 -r $F000-$FFFF
```

### Sound ROM

Building Video Sound Rom 4 (VSNDRM4) just requires two commands:

```sh
asl VSNDRM4.ASM -o vsndrm4.p
```
Then use P2BIN to generate the binary ROM file:

```sh
p2bin vsndrm4.p video_sound_rom_4_std_780.ic12 -l 00 -r $F000-$FFFF
```

### Decoder ROMs 4 & 6

This is probably a little bit overkill but I also included code that builds the required decoder ROMs needed for the game to run.  MAME will refuse to launch the game if these files are not included so I added a [new source file](decoder_roms.asm), even though it's fairly easy to find these files online.  Regardless, I added them for completeness sake.

## Overview

Following [Defender](https://github.com/mwenge/defender), [Robotron](https://github.com/mwenge/robotron), and [Sinistar](https://github.com/synamaxmusic/sinistar), Joust is the latest Williams Electronics arcade game to have its source code retargeted for a newer assembler.  Because Sinistar and Joust's codebases contain a lot of similarities, I am reusing Macroassembler {AS} as the new assembler to build this game.  It appears that the same Boston System Office (BSO) assembler used for Sinistar, was previously utilized for Joust as well.

Sinistar's codebase - while more complex and featuring way more source files - also came with ```EQU``` and ```SET``` files that were extremely helpful in mapping out all the symbols and their addresses.  We don't have this luxury with Joust's code unfortunately.  To get around this, a disassembly of the game was generated from MAME and used whenever I was stuck.

Fortunately, the code for the game is fairly straight-forward as it doesn't heavily rely on macros (unlike Sinistar) and required much less rewriting.  For example, Sinistar took a little over 3 months to figure out, while rewriting Joust took just 4 days (though a lot of that time during the Sinistar rewrite was attributed to figuring out how to change the old syntax and expressions over to the newer assembler).

I also chose not to rewrite the original three previous versions of Joust, even though they are included in the original codebase.  Maybe I'll get to them one day, but for now it's not as important as getting the final version of the game up and running.

## Rewriting the source code

Whenever possible, any changes to the code are marked by comments to the right that say ```;;Fixme was:``` followed by the original instructions.

```
    IF PNBR-* > 0			      ;;Fixme was: IFGT  PNBR-*
```

### Local labels

{AS}  has some quirks with local labels so I had to redo them.  For example, here's what local labels look like for the BSO assembler:

```
1$	lda	lol
	jmp	2$
2$	lda	lmao
```

This is what this code would look like rewritten for {AS}:

```
.1S	lda	lol
	jmp	.2S
.2S	lda	lmao
```

Not all local label changes have been marked with ```;;Fixme was:``` comments as it would be too many to add and can clutter up the code.

### Invalid symbols

There are several symbols in both Sinistar and Joust that use dollar signs.  ```$``` are reserved for hex numbers only in {AS} so these labels/symbols have been renamed, by replacing the ```$``` with an ```S```.  

### BSO Syntax

Thankfully, I found some [documentation](https://www.pagetable.com/docs/cbmasm/cy6502.txt) for another [missing BSO assembler](https://www.pagetable.com/?p=1538#fn:1) that explains some of the syntax and expressions used in the original source code.  Here are some important ones to point out:

```

        UNARY:  +       Identity
                -       Negation
                >       High byte
                <       Low byte
                !N      Logical one's complement

        BINARY: +       Addition
                -       Subtraction
                *       Multiplication
                /       Division.  Any remainder is discarded.
                !.      Logical AND
                !+      Logical OR
                !X      Logical Exclusive OR

     Expressions will be evaluated according to the following operator
     precedence, and from left to right when of equal precedence:


                1)  Unary +, unary -, !N, <, >
                2)  *, /, !., !+, !X
                3)  Binary +, binary -
```

```

          Pseudo-     Syntax                Condition tested
            op

          .IF       .IF logical expr      true 
          .IF       .IF expr              expr <> 0
          .IFE      .IFE expr             expr = 0
          .IFN      .IFN expr             expr <> 0
          .IFLT     .IFLT expr            expr < 0
          .IFGT     .IFGT expr            expr > 0
          .IFLE     .IFLE expr            expr <= 0
          .IFGE     .IFGE expr            expr >= 0
          .IFDEF    .IFDEF sym            sym is a defined symbol
          .IFNDEF   .IFNDEF sym           sym is an undefined symbol
          .IFB      .IFB <string>         string is blank
          .IFNB     .IFNB <string>        string is not blank
          .IFIDN    .IFIDN <str1>,<str2>  str1 and str2 are identical
                                          character strings
          .IFNIDN   .IFNIDN <str1>,<str2> str1 and str2 are not 
                                          identical
```
These conditional pseudo-ops get used a lot so having this guide was extremely important for getting macros to work with Macroassembler {AS}. 

Interestingly, there are a couple of new expressions that don't appear here that do show up in the codebase:

```
FCB  WAIT,!HCALL,!WCALL,MINUS-*,ZERO-*,PLUS-*,FLYVEL
```

```!H``` was used for separating the high byte of a word, while ```!W``` is used for the lower byte of a word.  The first one does show up occasionally in Sinistar's codebase but ```!W``` is a new one that I haven't encountered before.

### Common fixes

* Exclusive OR ```!X``` are now just ```!```.
* Bit shift operators ```!<``` and ```!>``` are now ```<<``` and ```>>```.
* ```#!N4``` is a value used a lot for fixing a DMA bug for the blitter graphic chip.  This value has been replaced with ```#~$4```.
* Binary AND ```!.``` are now just ```&```
* Binary OR ```!+``` are now ```|```
* ```*``` asterisks were used to denote comments at the start of a new line.  These have now have semi-colons in front of them (```;*``` ) to tell the assembler this is a comment.  ```*``` is now exclusively used as the current value of the program counter.

### Inconsistent label names

Sinistar's codebase contains a plethora of inconsistent label names thanks to the small symbol table size of the BSO assembler.  Fortunately, there is only one occurrence of this issue, where ```TBRIDGE``` was truncated to ```TBRIDG```.  The original define in JOUSTRV4.ASM now reflects the full name.
