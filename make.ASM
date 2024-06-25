;
;		       JJJJ   OOO   U   U   SSSS  TTTTT
;       	          J  O   O  U   U  S        T  
;       	          J  O   O  U   U   SSS     T  
;       	      J   J  O   O  U   U      S    T  
;       	       JJJ    OOO    UUU   SSSS     T  
;
;	GAME DESIGNER; JOHN NEWCOMER
;	MAIN PROGRAMMER; BILL PFUTZENREUTER
;	OTHER PROGRAMMERS; CARY KOLKER
;			   KEN LANTZ
;	STARTED PROGRAMMING; FEB 10, 1982
;
;	Source code rewrite by SynaMax, started 01/25/2024
;       Complete ROM set built for the first time on 01/29/2024.
;
;===============================================================================
;  Macro Assembler AS Instructions
	CPU 6809
	PLAINBASE ON		; AS [1.42 Bld 262] no longer allows omission of an
				; empty index argument on 6809. This breaks many instructions
				; that do not use commas before registers (like LDA  U+ or CMPX  S)
				; A lot of code changes would be needed so "plainbase" is now enabled to fix this.
;===============================================================================
;  Order of files taken from Pfutz's "DOWNLDS.COM" 
	
	INCLUDE JOUSTI.ASM	;;Sprite Images
	INCLUDE TB12REV3.ASM	;;CMOS and High score routines
	INCLUDE MESSAGE.ASM	;;Message display routines and phrase strings
	INCLUDE ATT.ASM		;;Ken Lantz's attract screen
	INCLUDE SYSTEM.ASM	
	INCLUDE JOUSTRV4.ASM	;;Game program (version 4 - final release)
	INCLUDE T12REV3.ASM	;;Test Rom
	
;===============================================================================
;  Mods
;
;  To enable mods for Joust, simply remove the semi-colon in front of
;  any define listed below:
;
;PauseMod EQU	1
;
;  Originally written in 2008 by Chris Brooks @ Coinoplove.com, this allows the
;  ability to pause the game by hitting the Player 1 button during gameplay.
;  Very useful, especially if you're playing on hardware!
;
;===============================================================================
	
	INCLUDE joust_mods.asm
	
	
	END
