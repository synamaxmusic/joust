;;This mod from 2008 is by Chris Brooks @ Coinoplove.com
;;(disassembled and rewritten with comments by SynaMax to work with the Joust Source code rewrite)

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