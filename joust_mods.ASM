;
;	          JJJJ   OOO   U   U   SSSS  TTTTT    M   M   OOO   DDDD    SSSS
;                    J  O   O  U   U  S        T      MM MM  O   O  D   D  S    
;                    J  O   O  U   U   SSS     T      M M M  O   O  D   D   SSS 
;                J   J  O   O  U   U      S    T      M   M  O   O  D   D      S
;                 JJJ    OOO    UUU   SSSS     T      M   M   OOO   DDDD   SSSS 
;
;;--------------------------------------------------------------------------------------------------
;;
;; This mod from 2008 is by Chris Brooks @ Coinoplove.com
;; (disassembled and rewritten with comments by SynaMax to work with the Joust Source code rewrite)
;;
;;--------------------------------------------------------------------------------------------------

;JOUST PAUSE MODIFICATION (WHITE/GREEN LABEL VERSION)  8/10/08 Ver 2.0
;
;This hack gives previously unimplemented pause mode for Williams Robotron Arcade game.
;It was designed to allow pausing during game play using the "1 player start" button.
;
;History:
;
;vER2:
;Joust seems to use a totally different programming model from Robotron (the first williams mod)
;in that it lacks or doesn’t use a character based printing routine; instead it blits a graphic of
;each character on the screen.  Well, at the very least it does not use ASCII strings, which makes
;it complicated to manually get characters on the screen.  
;
;Joust also contains a little steaming nugget of code at 6AC7 that does a quick checksum on the
;one ROM that has any room to do mods when first starting a game.  If the checksum fails, it merely
;increments a value in page 0 that will corrupt execution later on in the game, in a seemingly
;random way.  So, byte DFF3 is used to reset the checksum to the correct value of A1.  I can't see
;it having any other purpose but to prevent changes by either the suits at Williams, or to would
;be bootleggers.
;
;The silver lining is that ROM12 did not have to be reprogramed (where the checksums are located)
;so that a ROM error would not be triggered.  So while this mod was a pain in the ass to develop,
;its easy in that only 1 EPROM needs to be programmed.
;
;
;
;Ver1:
;
;Basic pause functionality using the 1Player start button.
;
;
;
;To use:
;
;Burn replacement for ROM 10 (3006-22.10b), and install.
;
;While in game, press 1P Start to toggle pause.
;
;
;Downloaded from COINOPLOVE.COM



	IFDEF	PauseMod

	ORG	$D6F0

PauseSTART
	LDA     #$11
	STA     CON		;$CA01
	LDX     #$0703
	STX     WDMA		;$CA06
	LDY     #PauseTbl	;Grab letter pointers
	LDX     #$3463		;screen position 34 = X, 63 = Y
.2S	LDD     ,Y++
	BEQ     .1S		; branch to RTS if we reach zeros at the end of letter pointer table
	STD     ORG		;store letter pointer in ORG ;$CA02	
	STX     DDMA		;store screen location in DDMA ;$CA04
	EXG     X,D
	ADDA    #$08
	EXG     X,D
	LDA     #$1A		;READ SERIAL, WRITE BLOCK, CONSTANT SUBB, ZERO SUPPRESS
	STA     DMA		;$CA00 (draw letter on-screen)
	LDA     #$00
	BEQ     .2S		;go back to grab the next letter
.1S	RTS     
	FDB     $00
	FDB     $00
PauseTbl        
	FDB     LP+2		;"P"	
	FDB     LA+2		;"A"
	FDB     LU+2		;"U"
	FDB     LS+2		;"S"
	FDB     LE+2		;"E"
	FDB     LD+2		;"D"
	FDB     $00		;Table terminator
	FDB     $00
PauseCLR
	LDX     #$0000		;this clears the screen by loading 4 black color nibbles in x register
	LDA     #$34		;load starting horizontal position in A
.1S	LDB     #$63		;load starting vertical position in B
.2S	EXG     X,D		;swap X with D
	STA     ,X		;draw the black pixels over the text here
	EXG     X,D		;swap X with D again so we can clear more pixels
	INCB	 		;keep going down vertically to continue clearing text
	CMPB    #$6B		; until we hit $6B
	BNE     .2S		; loop to clear more pixels please
	INCA	 		;when we finish this pixel column, increase A to move to next pixel horizontal row
	CMPA    #$60		; keep doing this until we reach $60
	BNE     .1S		; go back and grab the start of the next column ($63)
	RTS     
	        
	ORG     $DDC1
	JMP     PauseScan	;instead of reading player 1/2 joystick, we jump to check if pause is enabled

	ORG	$DFA0
	
PauseScan
	PSHS    D 
	LDA     WPIAA		;$C804 (note that WPIAA and PIA2 are the same)
	ANDA    #$20
	BEQ     PauseExit	;if player one button is not pressed, prepare to exit routine
	ORCC    #$10		;set Interrupt mask
	JSR     PauseDelay	;go to delay subroutine
.1S	JSR     .4S		;feed watchdog
	LDA     WPIAA		;did player hit P1 button?
	ANDA    #$20
	BNE     .1S		;no? then go feed watchdog again
	JSR     PauseSTART	;yes? draw "PAUSED" text
.3S	JSR     .4S		;feed watchdog
	LDA     WPIAA		;$C804
	ANDA    #$20
	BEQ     .3S 
	JSR     PauseDelay
.2S	JSR     .4S
	LDA     WPIAA		;$C804
	ANDA    #$20
	BNE     .2S
	JSR     PauseCLR	;player wants to resume play, let's go clear the "PAUSED" text
	JMP     PauseExit
.4S	LDB     #$39		;Watchdog food
	STB     WDOG		;Watchdog
	RTS

PauseDelay
	LDD     #$0200		;let's waste some CPU cycles so we give the player time to react
.1S	DECB    
	BNE     .1S 
	DECA    
	BNE     .1S 
        RTS			;let's go feed the watchdog


PauseExit PULS    D		;grab D from stack 
	ANDCC   #$EF
	LDA     WPIAA		;READ JOYSTICK (restore trashed instruction from $DDC1)
	JMP     $DDC4		;go back to Game Logic
	FDB     $00FA		;$FA = CHECKSUM FIX
	
	ENDIF
	
;;--------------------------------------------------------------------------------------------------
;;
;;  JOUST LIFE NUMBER DISPLAY MOD
;;
;;  Mod for displaying number of lives (up to 255).
;;  Programmed by SynaMax, started 6/29/24
;;  Completed 7/04/2024
;;
;;--------------------------------------------------------------------------------------------------

	IFDEF	DisplayLivesMod

;;
;;  Force Fake Checksums for debugging and disable ZAP routines
;;

;FakeChecksums 	EQU 1		;; Enable FakeChecksums
DisableZAP	EQU 1		;; Disable ZAP routines that corrupt the game on purpose
;SkipRugTest	EQU 1		;; to speed up debugging

;;
;;  Like with Sinistar, we'll need to nuke the CRT tests in the Diagnostic ROM to fit this new code
;;	

	ORG	AUTO4		;;replace "BSR	BARS" with NOPs so Auto cycle doesn't execute mod code
	NOP
	NOP
	
	ORG	TSTPAT		;; make TSTPAT skip color bar and cross hatch tests and go straight to booking
	JMP	BOOK	
	
	ORG	$F43D		;; overwrite JSR instructions for AVWAIT and CRTEST with NOPs
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	
;;
;;  $F4C5-$F6D0 is now free space
;;	
;;  This code was taken from Robotron Tie-Die, but modified to work with Joust.
;;
;;  This routine converts the hex number for player lives into human-readable BCD.
;;  Because we're using the Player Decision Block, this code works for both players.
;;
;;  In Robotron, the resulting BCD number was originally stored in Y and then saved to
;;  the stack.  But for Joust, I changed Y to X and have the BCD number stored in a safe
;;  spot in RAM called XTEMP ($A0D5).  It's only used to display the initials on the
;;  high score screen and doesn't do anything during gameplay. 
;;
	
	ORG	$F4C5
	
HXXBCD	PSHS	X,B		;; save B to stack
	CLRA			;; clear A
	
	STA	XTEMP		;; let's initialize XTEMP to store our temporary data.
	STA	XTEMP+1		;; store a zero here too
	
	LDX	DSCORE,X	;; grab Player RAM area (works for both player 1 AND 2)
	LDB	5,X		;; Player Decision Block in X, lets us grab number of lives
	
HXX0	LDX	#$0000		;; we can use X again
	BRA	HXX1
	
UPDBCD	PSHS	X,B
	CLRA			
	
;; We don't initialize XTEMP here

	LDX	DSCORE,X	;; grab Player RAM area (works for both player 1 AND 2)	
	LDB	5,X
	
	STA	XTEMP		;; we already initialized, so lets store a zero here...
	STB	XTEMP+1		;; and write our current hex number for lives.
	LDX	#$0000
	
HXX1	CMPB	#$0A		;; The actual conversion process starts here
	BCS	HXX2		;; (Thank you Eugene and Larry for this code!)
	ADDA	#$0A
	DAA
	BCC	HXX3
	LEAX	$0100,X
HXX3	SUBB	#$0A
	BRA	HXX1
HXX2	PSHS	B
	ADDA	,S+
	DAA
	BCC	HEXTEST
	LEAX	$0100,X
HEXTEST TSTA
	BPL	HXX4
	LEAX	$0080,X
	SUBA	#$80
HXX4	LEAX	A,X

	STX	XTEMP		;; WRITE FINAL BCD LIFE VALUE HERE
	
BYE255	PULS	X,B,PC
	
;;	
;;  Now that we have our BCD number saved, let's prepare the graphics.
;;
;;  There's space for five 3x7 sprites here.  We need the last three to display
;;  our BCD number.  We'll leave the second life icon untouched.
;;
;;  BYEDUDE erases the first life icon so that there's a space between the
;;  score number and the second life icon.
;;
;;  The next three digits are located at x offsets $6, $9, and $C.
;;
	
BYEDUDE	PSHS	X,CC		;SAVE INTERUPT STATUS

	CLRB
	CLRA			;; clears out X-position offset so we can erase first icon
	ADDD	DSCLOC,X							;;39D9
	ORCC	#$F0		;NO INTERUPTS FOR DMA
	STD	DDMA
	LDD	#$0307!DMAFIX	;CHARACTER SIZE					;;Fixme was: !XDMAFIX
	STD	WDMA
	LDD	DSCPLY,X	;GET PLAYERS SOURCE CHARACTER ADDRESS
	STD	SDMA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; draw DMA
;	LDA	#$0A		;DMA CONTROL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; erase DMA
	LDD	#$1A*256+(DKB*$11)	;DMA CONTROL & ERASE CONSTANT
	STB	KDMA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	STA	DMA
	PULS	X,CC,PC
;;
;;  Drawing the number of lives starts here.  It's based off of Pfutz's score display code.
;;	

HINUMWR	RORB			;HIGH BYTE SHIFT
	RORB
	RORB
	RORB

LONUMWR	ANDB	#$0F		;LOW BYTE SHIFT
	LDA	#3*7+2		;FONT SIZE IS 6X7 PIXELS PLUS 2BYTE SIZE
	MUL
;	PSHS	CC		;; We should already have the correct CC value here
;	ORCC	#$F0		;NO INTERUPTS FOR DMA (TIME FOR INT TO SETTLE)
	ADDD	[FONT5]
	ADDD	#2		;SKIP THE SIZE, IT IS 3X7
	STD	SDMA
	LDD	#$0307!DMAFIX							;;Fixme was: LDD  #$0307!XDMAFIX
	STD	WDMA
;	PSHS	X		;; X should already be the correct value here
	LDD	DSCLOC,X
;	PULS	CC,PC
	RTS
;;
;;  <<< ADDING X-POSITION OFFSET TO D HAPPENS HERE, THEN PROCEED TO FINISH >>>
;;
;;  In the previous LDD instruction, we grab the #$39D9 value known as "DSCLOC",
;;  then add our X position offset ($6, $9, or $C).  $39 is x-pos, $D9 is y-pos.
;;  Then, we go to the FINISH routine and actually draw the number via the DMA.
;;
	
FINISH	ORCC	#$F0		;; we're not done yet
	STD	DDMA		;; store X-pos and Y-pos screen coordinates into Destination DMA
	LDD	#$12*256+(DKB*$11)	;ERASE OLD DIGIT
	STB	KDMA	
	STA	DMA
	LDD	#$1A11		;; $1A = DMA constant, $11 = White color nibbles
	STB	KDMA		;WRITE NEW DIGIT
	STA	DMA
;	PULS	CC		;NAP BEFORE RETURNING TO CALLER
	
DONE255	RTS
	;PULS	X,CC,PC

	
MODSAV	SET	*		;; Saving our spot for more mod code later	

;;
;;  The player is given up to five lives at the start of the game so we need to insert the
;;  the new draw routine AFTER PLYRUP is finished, otherwise we're repeating the HEX to BCD
;;  conversion and update the draw on the screen every time a life is added.  
;;
	
	ORG	$6518
	JSR	LIFEPATCH
	
	ORG	$6545
	JSR	LIFEPATCH
	
;;
;;  Place the new code in MODSAV.
;;	

	ORG	MODSAV
	
LIFEPATCH			;; Patches PLYRUP
	JSR	PLYRUP

	PSHS	D,CC
	JSR	HXXBCD		;; This initializes XTEMP and converts the number
	JSR	BYEDUDE		;; Say goodbye to the little dude on the left
	BRA	WRITE255	;; Immediately start drawing the number of lives
	
UPDATE255			;; Used by both INCLIV and DECLIV
	PSHS	D,CC
	JSR	UPDBCD		;; No XTEMP initialization here, just HEX-2-BCD
		
WRITE255
DIGIT1	ORCC	#$F0		;; we're not done yet
	LDB	XTEMP		;; get first BCD digit in XTEMP
;	CMPB	#$0		;; skip number if it's zero
;	BEQ	DIGIT2
	JSR	LONUMWR		;; Draw low nibble
	
	ORCC	#$F0		;; we're not done yet
	ADDA	#6		;; offset for FIRST digit
	JSR	FINISH

DIGIT2	ORCC	#$F0		;; we're not done yet	
	LDB	XTEMP+1
;	ANDB	#$F0		;; mask high digit
;	CMPB	#$0		;; skip number if it's zero
;	BEQ	DIGIT3
;	LDB	XTEMP+1		;; load original value in B again
	JSR	HINUMWR

	ORCC	#$F0		;; we're not done yet
	ADDA	#9		;; offset for SECOND digit
	JSR	FINISH	

DIGIT3	ORCC	#$F0		;; we're not done yet	
	LDB	XTEMP+1
	JSR	LONUMWR

	ORCC	#$F0		;; we're not done yet	
	ADDA	#$C		;; offset for THIRD AND LAST digit
	JSR	FINISH	
	
	PULS	D,CC,PC
	
;	RTS			;;Remove this to make some funny stuff happen on-screen! :P

MODSAV	SET	*		;;Saving our spot for more mod code
	
;;
;;  Replace the calls to the DECLIV routine and insert patch to update lives display upon losing a life.
;;	

	ORG	$8AAC
	JSR	DECBCD
	
	ORG	$8D2F
	JSR	DECBCD
	
;;
;;  Make INCLIV only draw 2 dudes
;;	
	
	ORG	$872B
	CMPA	#2
	
;;
;;  Disable DECLIV erase instructions so we don't lose our second dude graphic.
;;
	
	ORG	$876A	
	JMP	DCLDON
	
;;
;;  Overwrite JSR to INCLIV so we can also update BCD display when the player is awared.
;;	
	
	ORG	$E70A
	JSR	INCBCD
	
	
;;
;;  Go back to MODSAV for more code to store in ROM 12
;;	
	
	ORG	MODSAV
	
INCBCD	JSR	INCLIV		;AWARD THE PLAYER
	PSHS	X,CC		;SAVE INTERUPT STATUS
	
;;
;;  I tried implementing an optimization check to see if the player already has 255 lives.
;;  If they do, then skip drawing the 255 number since it's already on-screen.
;;
;;  But, I kept running into problems trying to get this to work.  Another idea I had was
;;  to use one byte of XTEMP to write an #$FF as a flag and do a CMP instruction with #$0A
;;  to see if the number is hex or BCD.
;;
;;  Ultimately, I decided that it was best to just leave this as is.  It's really important
;;  that we display the correct number every single time.  The processing time required for
;;  this mod is actually pretty small so it doesn't interfere with feeding the watchdog.
;; 
	
;	LDX	DSCORE,X	;; grab Player RAM area (works for both player 1 AND 2)	
;	LDB	5,X
;	
;	CMPB	#$FF		;; Check if lives = 255
;	BLO	OK255		;; If NOT 255, then proceed to BCD convert
;	
;	LDX	XTEMP		;; Check to see if we already calculated and drawn 255 on-screen.
;	CMPX	#$0255		;; Does the player already have 255 lives?
;	BEQ	NO255		;; yes? then get outta here!
	
	
	
OK255	JSR	UPDATE255	;; update the BCD display
NO255	PULS	X,CC,PC
	
DECBCD	JSR	DECLIV		;; Let the game decrement the life counter first.
	PSHS	X,CC		;SAVE INTERUPT STATUS
	JSR	UPDATE255	;; update the BCD display
	PULS	X,CC,PC
;;
;;  Add 11 $20 for ASCII whitespace 
;;	

	FCB	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	
	FCC	" JOUST LIFE NUM  "
	FCC	"DISPLAY MOD BY SYNAMAX 7/4/2024"
	
;;
;;  Checksum fixes
;;	
	
	ORG	$663D		;; ROM 7 must equal $85
	FCB	$A0
	
	ORG	$8598		;; ROM 9 must equal $51
	FCB	$66
	
	ORG	$EB97		;; ROM 11 must equal $D5
	FCB	$22
	
;;
;;  To find the checksum for ROM 12, we need a fudger check byte.
;;
;;  First zero out $F33F and $F341.  Then calculate the checksum...this value goes in $F33F.
;;  The fudge value at $F341 = ($100 - checksum)
;;	
	
	ORG	$F33E
	FCB	$F0,$74,0,$8C	;; Final
	
	ENDIF

;;--------------------------------------------------------------------------------------------------
;;
;;  Disable ZAP Routines to allow modded code
;;
;;--------------------------------------------------------------------------------------------------

	IFDEF	DisableZAP

;;
;;  (06/29/2024): JZAP is triggering when trying to mod code.  It works by increasing the second byte of LXPOS2 ($A0B2)
;;  when the checksum does not equal #$A1.  LXPOS2 is the X position table for the Lava Troll's bubbles,
;;  so messing up this value causes the game to corrupt itself and crash when these enemies spawn.
;;
;;  JZAP actually takes up a lot of time because it's performing a checksum test during player turn
;;  initialization.  To keep the timing of everything the same, we're replacing the INC LXPOS2+1 with NOPs.
;;
;;  EDIT (07/01/2024): After being stuck on this for several days, I think I finally figured out what's going
;;  on here.  There's two additional ZAP routines that I did not know about!!
;;
;;  I tried adding RTS instructions at the beginning of these routines (LZAP and KZAP) but I was still
;;  running into issues.  These new patches force the game to skip all references to these ZAP routines
;;  as well as disabling any "naughty" instructions to ensure they don't actually cause corruption.
;;
;;  The game also uses a lot of checksums scattered throughout the code for the game.  Here's a list of all of them:
;;
;;  <<< FUDGE BYTES >>>
;;
;;  ROM 7:
;;  $663C	FCB	$20	;A DO NOTHING
;;  $663D	FCB	$99	;FUDGE TO MAKE THIS PROM ($6000) ADD UP TO $85
;;  $663E	FCB	$67	;FUDGE FOR LZAPPER TO SUM CORRECTLY
;;  $663F	FCB	$09	;FUDGE TO ADJUST BACK TO THE $6000 SUM OF $85
;;
;;  $69D9	FCB	$5F	;JZAPPER FUDGE
;;
;;  ROM 9:
;;  $8598	FCB	$CE	;LZAPPER FUDGE
;;
;;  ROM 10:
;;  $D760	FCB	$F3	;(ZAPPER) FUDGE TO GET THIS PART ($D000) ADD UP TO $3D
;;
;;  ROM 11:
;;  $EB97	FCB	$18	;KZAPPER FUDGE
;;
;;
;;  In order to neutralize these ZAP routines, you'll need to replace ROMs 7 and 9 no matter what.
;;  ROM 12 might have to be changed as well, especially if you're doing extensive modding.

;; JZAP
;	ORG	JZAP		;; Skip JZAP entirely
;	RTS

	ORG	$6AD6		;; Make JZAP do nothing
	NOP
	NOP
	
	ORG	$658E
	JMP	$6596		;; Skip JSR JZAP during NOSPL2 (CREATE PLAYERS COLISION DETECT ROUTINE)
	
	
;; LZAP	
;	ORG	LZAP		;; Skip LZAP entirely
;	RTS

	ORG	$85D0		;; NEUTRALIZE LZAP
	NOP			;; JMP $85D0 will also work, but NOPs are easier to read in memory viewer
	NOP
	NOP
	NOP
	NOP
	NOP
	
	ORG	$82FB		;; Skip JSR LZAP during PLAYER KILLED BY ENEMY OR PTERODACTYL routine (SPDIE2)
	NOP
	NOP
	NOP
	
;; KZAP	
;	ORG	KZAP		;; Discovered 7/1
;	RTS			
	
	ORG	$655F		;; Skip loading KZAP into X during NOPLY2 (CREATE PLAYERS COLISION DETECT ROUTINE)
	JMP	$6568		
	
;; RADDR (subroutine used by KZAP to generate a RANDOM ADDRESS)

;	ORG	RADDR		;; This requires editing ROM 8, so disabling KZAP should be enough.
;	RTS			
	
	ENDIF
	
;;--------------------------------------------------------------------------------------------------
;;
;;  Skip Rug Test to speed up debugging
;;
;;--------------------------------------------------------------------------------------------------	
	
	IFDEF SkipRugTest
	
	ORG	$F066
	NOP
	NOP
	
	ORG	$F06C
	NOP
	NOP
	NOP
	
	ENDIF
	
;;--------------------------------------------------------------------------------------------------
;;
;;  Fake Checksum table (to use while testing new code)
;;
;;--------------------------------------------------------------------------------------------------	
	
	IFDEF	FakeChecksums

	ORG	ROMTAB

	FCB	$00,$0	;0000
	FCB	$10,$0	;1000
	FCB	$20,$0	;2000
	FCB	$30,$0	;3000
	FCB	$40,$0	;4000
	FCB	$50,$0	;5000
	FCB	$60,$0	;6000
	FCB	$70,$0	;7000
	FCB	$80,$0	;8000
	FCB	$90,$0	;9000
	FCB	$A0,$0	;A000
	FCB	$B0,$0	;B000
	FCB	$C0,$0	;C000
	FCB	$D0,$0	;D000
	FCB	$E0,$0	;E000
	FCB	$F0,$0	;F000
	FCB	0
	FCB	$0	;CHECK BYTE (FUDGER) FOR THIS PART ($F000)
	
	ENDIF
