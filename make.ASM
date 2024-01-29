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
;
;===============================================================================
;  Macro Assembler AS Instructions
	CPU 6809
;===============================================================================
;  Order of files taken from Pfutz's "DOWNLDS.COM" 
	
	INCLUDE JOUSTI.ASM	;;Sprite Images
	INCLUDE TB12REV3.ASM	;;CMOS and High score routines
	INCLUDE MESSAGE.ASM	;;Message display routines and phrase strings
	INCLUDE ATT.ASM		;;Ken Lantz's attract screen
	INCLUDE SYSTEM.ASM	
	INCLUDE JOUSTRV4.ASM	;;Game program (version 4 - final release)
	INCLUDE T12REV3.ASM	;;Test Rom
	
	
	END