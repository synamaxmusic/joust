;*
;* LINE DRAWING SUBROUTINE
;*      Kenneth F. Lantz        c@ March 1982   William Electronics
;*
;       NLIST
;       INCLUDE RAMDEF.SRC
;       INCLUDE EQU.SRC
;       INCLUDE MESSEQU.SRC
;       LIST
;*
;*      COLOR PROCESSES WORK SPACE
;*
        ORG     PRAM
PCOUNT  RMB     2       ;COUNTER TILL ALL OF NEW COLOR RAM IS DUMPED
PDUMP   RMB     1       ;COUNTER FOR HOW MANY BYTES ARE LEFT TO YSAVE
PCOLOR  RMB     2       ;POINTER TO CURRENT COLOR PALET
PYSAVE  RMB     2       ;POINTER FOR NEXT COLOR BYTE TO DUMP
;*
        ORG     $BC00   ;in scratch memory
XLOC    FDB     0       ;range 0-304    !these four parameters set upon
YLOC    FDB     0       ;range 0-240    !entry, XLOC & YLOC are destroyed
ENDPTX  FDB     0       ;ditto          !
ENDPTY  FDB     0       ;ditto          !
CCOLOR  FCB     $11     ;set desired line color (left/right pixel respective)
        FCB     $11
FILDWN  FCB     0       ;none zero value here causes pixels to be filled in
;*                      ;in a downward direction until same color incountered
HCOUNT  FCB     0
COUNT   FDB     0
START   FDB     $5050
ERRCNT  FDB     0
ABSDX   FDB     0
ABSDY   FDB     0
QUAD    FDB     0
TAIL    FDB     $A0A0
SAVE    FDB     0
RLMASK  EQU     $40
TEMPM   FDB     0
CONTRL  EQU     $C900
OFFSET  FDB     $0000
FILL    EQU     $80
NOFILL  EQU     0
CL1     EQU     $11
CL2     EQU     $22
CL3     EQU     $33
CL4     EQU     $44
XPOS    EQU     4       ;OFFSET FROM ORGINAL START POSITION
;***********************************
        ORG     $D000           ;in high memory due to screen access
MARQUE  PKILL   $00,$08         ;KILL H.S.T.D. PROCESSES
        LDX     VNULL           ;CHEAPIE BLANK THE SCREEN
        JSR     VDCOLOR
        PCNAP   2
        JSR     SCCLR           ;CLEAR SCREEN
        LDX     #MARCOL         ;MARQUE COLORS
        JSR     VDCOLOR
        JSR     OPWRT           ;WRITE THE OPERATORS MESSAGE
        LDD     #MSCOPY*256+$55 ;WILLIAMS COPYRIGHT MESSAGE
        LDX     #$1CBD
        JSR     OUTPHR
        LDY     #$1211          ;BACKGROUND FILL OF COLOR NIBBLE 11
        JSR     VDCRE2          ;DISPLAY CREDITS
        LDX     #REPLAY
        JSR     RCMSA
        TSTA                    ;ANY EXTRA MEN ALLOWED?
        BEQ     .20S            ; BR=NO, SO SKIP THIS MESSAGE
        LDD     #MSW17*256+$33  ;EXTRA MAN AT XX,000 POINTS
        LDX     #$1FAB
        JSR     OUTPHR
        LDB     #$CC
        PSHS    X
        LDX     #REPLAY         ;GET REPLAY LEVEL
        JSR     RCMSA
        PULS    X
        BITA    #$F0
        BNE     .10S
        ORA     #$F0
.10S    JSR     OUTBCD          ;DISPLAY THOUSANDS OF REPLAY POINTS             ;;Fixme was: 10$
        LDA     #MSW18
        JSR     OUTPHR
.20S    PCNAP   1               ;DELAYS, DELAYS, WHEN DO WE SHIP IT!            ;;Fixme was: 20$
        SECCR   STRIP,$11       ;STRIPE GENERATOR
        SECCR   FLASH,$10       ;COLOR RAM FLASH
;*
GO      LDU     #LIST
        CLR     OFFSET
        LDA     ,U+
        STA     OFFSET+1
TOP     LDA     ,U+
        STA     FILDWN
        LDD     ,U++
        STD     CCOLOR
DEMO    CLRA
        LDB     ,U+
        ADDD    OFFSET  ;done this way to avoid the carry on an 8bit to 16bit +
        STD     XLOC
        CLRA
        LDB     ,U+
        STD     YLOC
        CLRA
        LDB     ,U
        BEQ     .1S
        ADDD    OFFSET
        STD     ENDPTX
        CLRA
        LDB     1,U
        STD     ENDPTY
        JSR     LINE
        BRA     DEMO
;*
.1S     LEAU    1,U                                                             ;;Fixme was: 1$
        LDB     ,U+     ;a double zero ends a character
        BEQ     .2S
        BRA     TOP
.2S     LDA     ,U+                                                             ;;Fixme was: 2$
        BEQ     .9S     ;another zero ends it all
        STA     OFFSET+1
        BRA     TOP
;*
.9S     LDU     PEXEC                                                           ;;Fixme was: 9$
        LDA     #111            ;111 * 10 = 1,110 = 18.5 SEC
        STA     PRAM,U
.20S    PCNAP   10                                                              ;;Fixme was: 20$
        DEC     PRAM,U
        BNE     .20S
        PKILL   $00,$40         ;KILL ALL NON-ATTRACT MODE PROCESSES
        LDY     #RAMCOL+1
        LDD     #$FFFF
        STD     ,Y++
        LDD     #0
        STD     ,Y++
        STD     ,Y++
        STD     ,Y++
        STD     ,Y++
        STD     ,Y++
        STD     ,Y++
        STA     ,Y
        JMP     VSIM            ;INSTRUCTIONAL PAGE (GAME SIMULATION)
;*
;*      COLOR RAM FLASH GENERATOR
;*
FLASH   LDD     #-1             ;INITILA COLOR CHANGE AFTER STRIPE ROUTINE
        STD     PCOUNT,U
        LDD     #MARCOL+8
        STD     PCOLOR,U
.10S    PCNAP   2                                                               ;;Fixme was: 10$
        LDX     RAMCOL+15
        LDD     PCOUNT,U
        BPL     .11S
        LDY     PLINK,U
        LDA     PID,Y
        CMPA    #$11            ;STRIPE I.D.?
        BEQ     .20S
        LDD     #16             ;INITIAL DELAY
.11S    BEQ     .17S                                                            ;;Fixme was: 11$
        ADDD    #-1
        STD     PCOUNT,U
        BNE     .20S
        LDY     PCOLOR,U
        LEAY    8,Y
        CMPY    #MAREND
        BLO     .15S
        LDY     #MARCOL+8
.15S    STY     PCOLOR,U                                                        ;;Fixme was: 15$
        STY     PYSAVE,U
        LDA     #8
        STA     PDUMP,U
.17S    LDY     PYSAVE,U        ;IN MIDDLE OF RE-DUMPPING NEW COLOR             ;;Fixme was: 17$
        LDX     ,Y+
        STY     PYSAVE,U
        DEC     PDUMP,U
        BNE     .20S
        LDD     #((((2*60+30)/16)+1)*8)+7 ;CHANGE COLORS EVERY 2 1/2 SECONDS
        STD     PCOUNT,U
.20S    LDD     RAMCOL+13                                                       ;;Fixme was: 20$
        STD     RAMCOL+14
        LDD     RAMCOL+11
        STD     RAMCOL+12
        LDD     RAMCOL+9
        STD     RAMCOL+10
        TFR     X,D
        LDB     RAMCOL+8
        STD     RAMCOL+8
        BRA     .10S
;*
;*      STRIPE GENERATOR
;*
XLENS   EQU     16
YLENS   EQU     16
STRIP   CLR     PRAM+8,U
        LDX     #$10-1
        LDY     #$10
        LDA     #8
.10S    LEAX    1,X                                                             ;;Fixme was: 10$
        BSR     WRPIXH
        CMPX    #$8F*2+XLENS
        BLO     .10S
        LEAX    -XLENS,X
        LEAY    YLENS-1,Y
.20S    LEAY    1,Y                                                             ;;Fixme was: 20$
        BSR     WRPIXV
        CMPY    #$F2
        BLO     .20S
        LEAY    -YLENS,Y
.30S    LEAX    -1,X                                                            ;;Fixme was: 30$
        BSR     WRPIXH
        CMPX    #$0033*2
        BNE     .35S
.35S    CMPX    #$0                                                             ;;Fixme was: 35$
        BHI     .30S
.40S    LEAY    -1,Y                                                            ;;Fixme was: 40$
        BSR     WRPIXV
        CMPY    #$10
        BHI     .40S
        JMP     VSUCIDE
;*
WRPIXH  INCA
        ANDA    #$0F
        ORA     #$08
        STX     PRAM,U
        STY     PRAM+2,U
        STD     PRAM+4,U
        LDB     #YLENS
.10S    BSR     WRANIB                                                          ;;Fixme was: 10$
        LEAY    1,Y
        INCA
        ANDA    #$0F
        ORA     #$08
        DECB
        BNE     .10S
        BRA     WRPRTS
;*
WRPIXV  INCA
        ANDA    #$0F
        ORA     #$08
        STX     PRAM,U
        STY     PRAM+2,U
        STD     PRAM+4,U
        LDB     #XLENS
.10S    BSR     WRANIB                                                          ;;Fixme was: 10$
        LEAX    1,X
        INCA
        ANDA    #$0F
        ORA     #$08
        DECB
        BNE     .10S
WRPRTS  LDD     ,S++
        STD     PRAM+6,U
        DEC     PRAM+8,U
        BGT     .10S
        LDA     #3
        STA     PRAM+8,U
        PCNAP   1
.10S    LDD     PRAM+4,U                                                        ;;Fixme was: 10$
        LDY     PRAM+2,U
        LDX     PRAM+0,U
        JMP     [PRAM+6,U]
;*
WRANIB  PSHS    D,X,Y
        LDA     #$0             ;READ SCREEN
        STA     DRRUC
        STA     RRUC
        TFR     X,D
        LSRA
        RORB
        TFR     B,A
        LDB     5,S
        TFR     D,X
        LDA     #$0F
        LDB     ,S
        BCS     .10S
        ASLB
        ASLB
        ASLB
        ASLB
        LDA     #$F0
.10S    ANDA    ,X                                                              ;;Fixme was: 10$
        BNE     .20S
        ORB     ,X
        STB     ,X
.20S    LDA     #$01            ;READ ROM!                                      ;;Fixme was: 20$
        STA     DRRUC
        STA     RRUC
        PULS    D,X,Y,PC
;*
;*      INITIAL COLORS FOR THE MARQUE PAGE
;*
MARCOL  FCB     $00,$00,$07,$3F,$05,@377,$E8,@350
        FCB     @000,@001,@003,@005,@007,@005,@003,@001
        FCB     @000,@010,@030,@050,@070,@050,@030,@010
        FCB     @000,@000,@100,@200,@300,@200,@100,@000
        FCB     @000,@011,@033,@055,@077,@055,@033,@011
        FCB     @000,@011,@122,@244,@377,@244,@122,@011
MAREND  EQU     *
;*
;*********************************************
;*
FILLDN  PSHS    X       ;This routine is entered with the current
        LEAX    1,X     ;location in X and color in A
.1S     LDD     SAVE                                                            ;;Fixme was: 1$
        ANDA    CCOLOR+1
        PSHS    A
        LDA     SAVE
        ANDA    ,X
        BNE     .2S
        ANDB    ,X
        ORB     ,S+
        STB     ,X
        EXG     D,X
        INCB
        EXG     X,D
        BNE     .1S
        PSHS    A
.2S     PULS    A,X,PC                                                          ;;Fixme was: 2$
;*************************
;* pixel movers  one pixel subroutines
;*************************
LFTRT   LDA     #RLMASK
        BITA    QUAD
        BNE     .1S     ;go right
        LDD     XLOC
        SUBD    #1
        BRA     .2S
.1S     LDD     XLOC                                                            ;;Fixme was: 1$
        ADDD    #1
.2S     STD     XLOC                                                            ;;Fixme was: 2$
        RTS
UPDN    TST     QUAD
        BMI     .1S     ;go down
        LDD     YLOC
        SUBD    #1
        BRA     .2S
.1S     LDD     YLOC                                                            ;;Fixme was: 1$
        ADDD    #1
.2S     STD     YLOC                                                            ;;Fixme was: 2$
        RTS
;******************************************
;*  line drawing subroutine
;***********************first calculate the quadrant and total distance
LINE    CLR     QUAD
        LDD     XLOC
        SUBD    ENDPTX
        ROR     QUAD
        BPL     .1S
        COMA
        COMB
        ADDD    #1
.1S     STD     ABSDX                                                           ;;Fixme was: 1$
        STD     ERRCNT
        LDD     YLOC
        SUBD    ENDPTY
        ROR     QUAD    ;bit7 set=down  bit6 set=right
        BMI     .2S
        COMA
        COMB
        ADDD    #1
.2S     SUBD    #1                                                              ;;Fixme was: 2$
        STD     ABSDY
        CLR     HCOUNT
        COMA
        COMB
        CLRA
        ADDD    ABSDX
        BCC     .3S
        INC     HCOUNT
.3S     STD     COUNT                                                           ;;Fixme was: 3$
        BRA     STP1
;*  drawing loop follows *
MOVX    JSR     LFTRT
STP1    LDD     ERRCNT
        ADDD    ABSDY
COUNTS  STD     ERRCNT
        PSHS    CC
        CLR     DRRUC           ;THIS 1ST, BECAUSE INTERUPTS CAN CHANGE THIS
        CLR     CONTRL
        LDD     XLOC
        ASRA
        RORB
        TFR     B,A
        LDB     YLOC+1
        TFR     D,X
        LDB     #$F0
        BCC     .3S
        COMB
.3S     TFR     B,A                                                             ;;Fixme was: 3$
        COMB
        STD     SAVE
        ANDA    CCOLOR
        ANDB    ,X
        PSHS    B
        TFR     A,B
        ORB     ,S+
        CMPX    #$9800
        BHS     RNGERR
        STB     ,X
        TST     FILDWN
        BPL     .6S
        JSR     FILLDN
.6S     LDA     #1                                                              ;;Fixme was: 6$
        STA     DRRUC           ;THIS 1ST, BECAUSE INTERUPTS CAN CHANGE THIS
        STA     CONTRL
        LDD     COUNT
        SUBD    #1
        BNE     .1S
        TST     HCOUNT
        BEQ     DONE
        DEC     HCOUNT
.1S     STD     COUNT                                                           ;;Fixme was: 1$
        PULS    CC
        BCS     MOVX
MOVY    JSR     UPDN
        LDD     ERRCNT
        ADDD    ABSDX
        BRA     COUNTS
;*
RNGERR  LEAS    2,S     ;pop one level and clean up the stack
DONE    PULS    CC,PC
;*
;**************************************************************************
;*
;***********************************************************
;* O  -OH-    **************************************************
LIST    FCB     $40+XPOS
        FCB     NOFILL,CL1,CL1
        FCB     2,80,3,100,8,116,12,122,20,127,30,127,38,122,42,117
        FCB     48,100,48,80,0,1
        FCB     NOFILL,CL2,CL2
        FCB     28,92,28,85,30,80,32,75,0,1
;*
        FCB     NOFILL,CL1,CL1
        FCB     32,75,35,86,35,94,0,1
;*
        FCB     FILL,CL1,CL3
        FCB     14,86,14,95,17,104,22,112,27,112,33,104,36,94,0,1
;*
        FCB     FILL,CL2,CL4,28,92,29,98,33,104,0,1
;*
        FCB     FILL,CL1,CL4
        FCB     14,95,14,86,17,76,21,68,23,66,26,66,28,68,32,74,0,1
;*
        FCB     FILL,CL1,CL3
        FCB     3,100,2,80,8,66,14,58,22,54,30,54,37,58
        FCB     44,66,48,80,0,1
        FCB     FILL,CL2,CL4,32,53,43,58,0,0
;***** -J- *************************
        FCB     1+XPOS,NOFILL,CL1,CL1,9,109,12,110,22,122,32,127,41,126,47,123,52,121,0,1
        FCB     NOFILL,CL2,CL2,46,124,70,117,0,1
;*
        FCB     FILL,CL1,CL4
        FCB     69,116,65,100,64,80,0,1
;*
        FCB     FILL,CL1,CL4
        FCB     52,121,58,112,58,80,60,72,65,59,0,1
        FCB     FILL,CL2,CL4,65,59,71,65,0,1
;*
        FCB     NOFILL,CL2,CL2
        FCB     30,76,44,76,0,1
;*
        FCB     FILL,CL1,CL4
        FCB     30,75,44,70,0,1
;*
        FCB     FILL,CL1,CL3
        FCB     30,75,30,70,65,59,0,1
;*
        FCB     FILL,CL1,CL3
        FCB     44,70,44,104,42,108,36,111,31,110
        FCB     27,106,24,100,23,95,22,93,21,95,9,109,0,1
;*
        FCB     FILL,CL2,CL4
        FCB     22,93,36,91,38,92,40,99,44,100,0,0
;******************************************************
;* U -YOU- ****************************************
        FCB     $6A+XPOS,NOFILL,CL2,CL3,1,118,13,107,0,1
        FCB     FILL,CL1,CL4,1,117,7,100,0,1
        FCB     NOFILL,CL1,CL4,10,88,10,98,12,106,0,1
        FCB     NOFILL,CL1,CL4,13,107,19,117,26,124,34,126,44,126
        FCB     51,124,54,122,0,1
        FCB     NOFILL,CL2,CL3,54,122,56,127,0,1
        FCB     NOFILL,CL1,CL3,57,118,56,128,63,126,68,126,76,128,0,1
        FCB     FILL,CL1,CL4,53,121,57,118,0,1
        FCB     FILL,CL1,CL3,74,126,71,114,70,84,0,1
        FCB     FILL,CL1,CL3,26,80,26,88,28,96,31,102,36,105,42,106,48,104
        FCB     53,100,56,90,57,77,58,66,0,1
        FCB     NOFILL,CL1,CL1,8,52,12,62,0,1,NOFILL,CL2,CL2,12,63,20,62,0,1
        FCB     NOFILL,CL1,CL1,78,50,72,64,70,84,0,1
        FCB     FILL,CL2,CL4,39,44,42,88,44,92,46,88,46,60,54,44,0,1
        FCB     FILL,CL1,CL4,54,44,56,54,57,66,57,77,0,1
        FCB     FILL,CL1,CL3,54,44,60,45,78,49,0,1
        FCB     FILL,CL1,CL4,26,80,28,70,34,54,39,44,0,1
        FCB     FILL,CL1,CL3,10,88,12,79,16,68,20,62,31,48,0,1
        FCB     FILL,CL1,CL4,13,62,20,54,31,48,0,1
        FCB     FILL,CL1,CL3,9,51,17,47,26,45,39,43,0,1
        FCB     FILL,CL2,CL4,0,58,16,68
        FCB     0,0
;*  -S-  CEA  *
        FCB     166+XPOS,NOFILL,CL1,CL3,56,118,48,124,40,127,25,123,18,122,0,1
        FCB     NOFILL,CL2,CL4,18,122,12,114,0,1
        FCB     FILL,CL1,CL3,19,121,20,113,20,102,0,1
        FCB     FILL,CL1,CL4,20,102,18,90,0,1
        FCB     FILL,CL2,CL4,12,85,19,90,0,1
        FCB     FILL,CL1,CL3,18,90,34,106,41,108,44,104,44,99,0,1
        FCB     FILL,CL1,CL4,43,98,40,94,20,82,16,78,15,70,0,1
        FCB     NOFILL,CL2,CL4,56,118,68,123,0,1        ;*
        FCB     FILL,CL1,CL4,55,118,59,109,0,1
        FCB     FILL,CL1,CL3,58,108,56,99,50,88,32,76,30,70,0,1
        FCB     NOFILL,CL2,CL4,36,78,56,82,0,1
        FCB     FILL,CL1,CL4,55,81,48,72,37,66,32,66,30,70,0,1
        FCB     FILL,CL1,CL3,55,81,55,63,44,57,36,54,28,53,23,56,16,64,16,78,0,1

        FCB     FILL,CL2,CL4,13,63,21,58
        FCB     0,0
;* -T- TEA  *
        FCB     218+XPOS,NOFILL,CL1,CL3,15,122,21,126,32,127,52,125,60,102,0,1
        FCB     NOFILL,CL1,CL3,30,96,40,78,0,1
        FCB     NOFILL,CL1,CL3,48,68,65,55,0,1
        FCB     NOFILL,CL2,CL4,40,78,60,76,0,1
        FCB     NOFILL,CL1,CL3,60,76,64,72,0,1
        FCB     FILL,CL1,CL4,41,77,45,75,60,75,0,1
        FCB     FILL,CL1,CL4,15,121,10,111,0,1
        FCB     FILL,CL1,CL3,11,110,11,104,14,96,21,81,32,72,0,1
        FCB     FILL,CL1,CL3,59,103,52,112,40,116,32,112,30,106,30,96,0,1
        FCB     FILL,CL2,CL4,59,102,47,99,42,102,36,106,30,106,0,1
        FCB     FILL,CL2,CL4,1,90,11,79,0,1
        FCB     FILL,CL1,CL4,11,79,26,74,31,73,0,1
        FCB     NOFILL,CL2,CL4,4,80,7,81,0,1
        FCB     FILL,CL2,CL4,4,65,9,62,0,1
        FCB     FILL,CL1,CL3,9,80,9,62,26,64,37,66,50,58,64,55,0,1
        FCB     FILL,CL1,CL3,48,68,63,72
        FCB     0,0
        FCB     0,0
;*
;*      AND THE EVER POPULAR COPYRIGHT MESSAGE
;*
        FCC     'JOUST (C)1982 WILLIAMS ELECTRONICS INC.'
;*
ATTLEN  EQU     *               ;$D000 TO HERE                                  ;;Fixme was: LENGTH (duplicate symbol)
        IF *-$D7FF > 0                                                          ;;Fixme was: IFGT *-$D7FF
         FCB    $1111           ;OVERFLOWED $D000,$D7FF AREA
        ENDIF
;       END     SYSV                                                            ;;We don't need this