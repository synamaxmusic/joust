;       NAM     MESSAGE BLOCK OUTPUT ROUTINES AND DATA
;********       NLIST
;       INCLUDE RAMDEF.ASM                                      ;;Fixme was: INCLUDE RAMDEF.SRC  (All of these are already in TB12)
;       INCLUDE EQU.ASM                                         ;;Fixme was: INCLUDE EQU.SRC
;       INCLUDE MESSEQU.ASM                                     ;;Fixme was: INCLUDE MESSEQU.SRC
;       INCLUDE MESSEQU2.ASM                                    ;;Fixme was: INCLUDE MESSEQU2.SRC
;       LIST

;*********************************************************
;*                                                       *
;*      CHARACTER,MESSAGE, & BCD OUTPUT ROUTINE          *
;*                                                       *
;*      STARTED : MAY 25, 1982  BY : CARY KOLKER         *
;*                                                       *
;*********************************************************


;*      DMA EQUATES     *
;* DMA BECAUSE BILL HAS IT ALREADY
;*DMA   EQU     $CA00   ;CONTROL REGISTER OF DMA
CON     EQU     DMA+1   ;CONSTANT WRITE REGISTER
ORG     EQU     CON+1   ;ORIGIN (WHERE DATA IS FROM) 2-BYTES
DES     EQU     ORG+2   ;DESTINATION (WHERE DATA IS TO GO) 2-BYTES
XSIZE   EQU     DES+2   ;HORIZONTAL SIZE (X-SIZE)
YSIZE   EQU     XSIZE+1 ;VERTICAL SIZE (Y-SIZE)


        ORG     MESS    ;START AT THE ADDRESS SPECIFIED ABOVE
        JMP     CHROUT  ;JUMP TO THE CHARACTER OUTPUT ROUTINE
        JMP     PHROUT  ;JUMP TO THE PHRASE OUTPUT ROUTINE
        JMP     BCDOUT  ;JUMP TO THE B.C.D. OUTPUT ROUTINE
        JMP     CHR35   ;JUMP TO THE CHARACTER 3X5 OUTPUT ROUTINE
        JMP     PHR35   ;JUMP TO THE PHRASE 3X5 OUTPUT ROUTINE
        JMP     BCD35   ;JUMP TO THE B.C.D. 3X5 OUTPUT ROUTINE
        JMP     OUTTEXT ;JUMP TO THE TEXT 5X7 OUTPUT ROUTINE
        JMP     OUTT35  ;JUMP TO THE TEXT 3X5 OUTPUT ROUTINE
        FDB     FONT57  ;FOR BILL SO HE CAN USE THE NUMBERS
        JMP     ERTEXT  ;JUMP TO THE TEXT 3X5 ERASE ROUTINE
        JMP     ERTT35  ;JUMP TO THE TEXT 5X7 ERASE ROUTINE

;       PAGE

;*********************************************************
;*                                                       *
;*      CHROUT - REQUIRES:                               *
;*              A - CONTAIN THE SELECT CHARACTER         *
;*              B - CONTAIN THE COLOR TO WRITE IT IN     *
;*              X - CONTAIN THE ADDRESS TO WRITE AT      *
;*                                                       *
;*                      OR                               *
;*                                                       *
;*      CHR35 - REQUIRES THE SAME PARAMETERS             *
;*              BUT IS ONLY FOR 3X5 CHARACTERS           *
;*                                                       *
;*      RESULT IS:                                       *
;*              CC - IS ALTERED SLIGHTLY                 *
;*              D,Y,U,S,DP - REMAIN UNCHANGED            *
;*                                                       *
;*      CHROUT - WILL WRITE A CHARACTER TO THE LOCATION  *
;* POINTED TO BY X, WITH THE COLOR IN B, SELECT CHARACTER*
;* IN A...      NOTE: THIS WILL DO A CONSTANT WRITE OF   *
;* COLOR SPEC. WITH ZERO SUPRESS.       TO ERASE CALL    *
;* CHROUT WITH A COLOR OF ZERO (WHEN BACKGROUND IS 0)    *
;*                                                       *
;*********************************************************

CHR35   PSHS    U,Y,D,CC        ;SAVE THE CONDITIONS
        LDY     #FONT35 ;GET THE FONT TABLE OF THE CHARACTERS
        ORCC    #$FF    ;TELL HIM NOT TO DISTURB ME WHILE I WRITE
        STB     CON     ;STORE THE COLOR SO WE CAN NOW USE THE D. REG.
        BSR     OUTPUT  ;GO TO THE NORMAL ROUTINE
        PULS    U,Y,D,CC,PC     ;RESTORE THE CONDITIONS WE HAD WHEN WE ENTERED


CHROUT  PSHS    U,Y,D,CC        ;SAVE THE CONDITIONS
        LDY     #FONT57 ;GET THE FONT TABLE OF THE CHARACTERS
        ORCC    #$FF    ;TELL HIM NOT TO DISTURB ME WHILE I WRITE
        STB     CON     ;STORE THE COLOR SO WE CAN NOW USE THE D. REG.
        BSR     OUTPUT  ;GO TO THE NORMAL ROUTINE
        PULS    U,Y,D,CC,PC     ;RESTORE THE CONDITIONS WE HAD WHEN WE ENTERED


OUTPUT  STX     DES     ;STORE THE DESTINATION, SO AS TO USE X AND SAVE 1-CYCLE
        ASLA            ;MAKE THE CHARACTER # AN ADDRESS OFFSET
        LDY     A,Y     ;GET THE ADDRESS OF THE ACTUAL CHARACTER DATA
        LDD     ,Y++    ;GET THE X & Y SIZES OF THE CHARACTER
        EORA    #$04    ;-----|--FOR THE INVERTED BIT DMA
        EORB    #$04    ;-----|
        STD     XSIZE   ;STORE THE X & Y SIZES TO THE DMA
        STY     ORG     ;STORE THE ORIGIN TO THE DMA
        LDB     #$1A    ;READ SERIAL, WRITE BLOCK, CONSTANT SUBB, ZERO SUPPRESS
        STB     DMA     ;START THE DMA WITH THE SELECTED OPERATION
        EORA    #$04    ;HAVE TO DO IT BECAUSE OF THE INVERTED DMA'S
        CLRB            ;MAKE D. HAVING B. A 00
        LEAX    D,X     ;MOVE ME TO THE NEXT SPOT
        RTS

;       PAGE

;*********************************************************
;*                                                       *
;*      PHROUT - SAME AS CHROUT EXCEPT:                  *
;*              A - CONTAINS A PHRASE NUMBER TO OUTPUT   *
;*              AT THE ADDRESS SPECIFIED BY THE X REG.   *
;*              THIS IS FOR 5X7 CHARACTER OUTPUT ONLY    *
;*                                                       *
;*                      OR                               *
;*                                                       *
;*      PHR35 - SAME AS PHROUT BUT FOR 3X5 CHARACTERS    *
;*              ONLY...                                  *
;*                                                       *
;*      RESULTS - SAME AS CHROUT                         *
;*                                                       *
;*********************************************************

PHR35   PSHS    U,Y,D,CC        ;SAVE THE CONDITIONS
        LDY     #FONT35 ;GET THE (3 X 5) FONT TABLE
        STY     XSAVE   ;STORE TO XSAVE EVEN IF ITS Y
        ORCC    #$FF    ;TELL HIM NOT TO DISTURB ME WHILE I WRITE
        STB     CON     ;STORE THE COLOR SO WE CAN NOW USE THE D. REG.
        BSR     PHROT1  ;AND GO TO THE NORMAL ROUTINE
        PULS    U,Y,D,CC,PC     ;RESTORE THE CONDITIONS WE HAD WHEN WE ENTERED


PHROUT  PSHS    U,Y,D,CC        ;SAVE THE CONDITIONS
        LDY     #FONT57 ;GET THE (5 X 7) FONT TABLE
        STY     XSAVE   ;STORE TO XSAVE EVEN IF ITS Y
        ORCC    #$FF    ;TELL HIM NOT TO DISTURB ME WHILE I WRITE
        STB     CON     ;STORE THE COLOR SO WE CAN NOW USE THE D. REG.
        BSR     PHROT1  ;GO TO THE NORMAL ROUTINE
        PULS    U,Y,D,CC,PC     ;RESTORE THE CONDITIONS WE HAD WHEN WE ENTERED


PHROT1  LDU     #PHRASE ;GET THE TABLE OF PHRASES
        LEAU    A,U     ;BECAUSE OF SIGNED OFFSETS WE HAVE TO MOVE U AHEAD
;*                      ;THEN LOAD OFF OF THE NEXT INSTRUCTION
        LDU     A,U     ;MOVE THE TABLE TO THAT POSITION
.1S     LDA     0,U     ;GET THE CHARACTER POINTED TO BY Y.                             ;;Fixme was: 1$
        LDY     XSAVE   ;GET THE FONT TABLE
        JSR     OUTPUT  ;PUT IT OUT AND USE CHROUT'S RETURN
        TST     ,U+     ;TEST IF THIS WAS THE LAST CHARACTER OF THE PHRASE
        BPL     .1S     ;BRANCH IF IT WAS NOT (BIT 7 NOT SET)
        RTS             ;RETURN TO THE CALLER


;       PAGE

;*********************************************************
;*                                                       *
;*      BCDOUT - SAME AS CHROUT EXECPT:                  *
;*              A - CONTAINS B.C.D. NUMBER TO OUTPUT     *
;*              FOR 5X7 CHARACTER OUTPUT ONLY            *
;*                                                       *
;*                      OR                               *
;*                                                       *
;*      BCD35 - SAME AS CHROUT EXECPT:                   *
;*              A - CONTAINS B.C.D. NUMBER TO OUTPUT     *
;*              FOR 3X5 CHARACTER OUTPUT ONLY            *
;*                                                       *
;*      RESULTS - NUMBER IS OUTPUTED SAME AS CHROUT      *
;*              WITH HIGH NIBBLE WHERE X POINTED         *
;*              ALSO IF HIGH NIBBLE IS GREATER THAN      *
;*              9 THEN IT IS BLANKED                     *
;*                                                       *
;*********************************************************

BCD35   PSHS    U,Y,D,CC        ;SAVE THE CONDITIONS
        LDY     #FONT35 ;GET THE (3 X 5) FONT TABLE
        STY     XSAVE   ;STORE TO XSAVE EVEN IF ITS Y
        ORCC    #$FF    ;TELL HIM NOT TO DISTURB ME WHILE I WRITE
        STB     CON     ;STORE THE COLOR SO WE CAN NOW USE THE D. REG.
        BSR     BCDOT1  ;GO TO THE NORMAL FOR THE REST OF THE WORK
        PULS    U,Y,D,CC,PC     ;RESTORE THE CONDITIONS WE HAD WHEN WE ENTERED


BCDOUT  PSHS    U,Y,D,CC        ;SAVE THE CONDITIONS
        LDY     #FONT57 ;GET THE (5 X 7) FONT TABLE
        STY     XSAVE   ;STORE TO XSAVE EVEN IF ITS Y
        ORCC    #$FF    ;TELL HIM NOT TO DISTURB ME WHILE I WRITE
        STB     CON     ;STORE THE COLOR SO WE CAN NOW USE THE D. REG.
        BSR     BCDOT1  ;GO TO THE NORMAL FOR THE REST OF THE WORK
        PULS    U,Y,D,CC,PC     ;RESTORE THE CONDITIONS WE HAD WHEN WE ENTERED


BCDOT1  STA     ASAVE   ;SAVE A REG. FOR FUTURE USE
        LSRA            ;------|
        LSRA            ;------|--WE ONLY WANT THE UPPER NIBBLE
        LSRA            ;------|
        LSRA            ;------|
        CMPA    #$0A    ;CHECK TO SEE IF WE SHOULD BLANK THIS DIGIT
        BLE     .1S
        LDA     #CSPC   ;GET A SPACE
.1S     LDY     XSAVE   ;GET THE FONT TABLE                                             ;;Fixme was: 1$
        JSR     OUTPUT  ;AND PUT THE NUMBER OUT
        LDA     ASAVE   ;GET THE B.C.D. NUMBER BACK
        ANDA    #$0F    ;WE ONLY WANT THE LOWER NIBBLE
        CMPA    #$0A    ;CHECK TO SEE IF WE SHOULD BLANK THIS DIGIT
        BLE     .2S
        LDA     #CSPC   ;GET A SPACE
.2S     LDY     XSAVE   ;GET THE FONT TABLE                                             ;;Fixme was: 2$
        JMP     OUTPUT  ;PUT IT OUT AND USE CHROUT'S RETURN

;* TEXT OUTPUT ROUTINE *

ERTT35  INC     FLAG    ;SET THE ERASE FLAG
        BRA     OUT35A
OUTT35  CLR     FLAG    ;CLEAR THE ERASE FLAG
OUT35A  LDU     #OUTP35 ;LOAD THE PHRASE OUTPUT ROUTINE
        BRA     OUTTX1  ;USE THE CODE OVER

ERTEXT  INC     FLAG    ;SET THE ERASE FLAG
        BRA     OUTTX2
OUTTEXT CLR     FLAG    ;CLEAR THE ERASE FLAG
OUTTX2  LDU     #OUTPHR ;LOAD THE PHRASE OUTPUT ROUTINE
OUTTX1  LDY     #TXT    ;GET THE TEXT TABLE
        LEAY    A,Y     ;FIND THE ADDRESS OF THE TEXT TO USE FROM THE TABLE
        LDY     A,Y     ;---|
.1S     LDX     ,Y++    ;GET THE ADDRESS TO WRITE IT AT                                 ;;Fixme was: 1$
        LDB     ,Y+     ;GET THE COLOR TO WRITE IT IN
        TST     FLAG    ;ARE WE TO ERASE THIS
        BEQ     .2S     ;BRA= NO SO USE THE COLOR
        CLRB            ;HE SAYS WERE TO ERASE IT SO CLEAR THE COLOR
.2S     LDA     ,Y      ;GET THE PHRASE TO USE                                          ;;Fixme was: 2$
        ANDA    #$7F    ;GET RID OF THE END OF TEXT FLAG
        JSR     ,U      ;JSR TO THE SPECIFIED OUTPUT ROUTINE
        TST     ,Y+     ;CHECK THE END OF TEXT FLAG B7=1 - DONE, B7=0 - NOT DONE
        BPL     .1S     ;BRA= WERE NOT DONE YET
        RTS             ;LET'S GO HOME......


;       PAGE

;*********************************************************
;*                                                       *
;*      CHARACTER TABLES:                                *
;*              5X7 FONT FIRST                           *
;*              3X5 FONT SECOND                          *
;*                                                       *
;*********************************************************

FONT57  FDB     L0
        FDB     L1
        FDB     L2
        FDB     L3
        FDB     L4
        FDB     L5
        FDB     L6
        FDB     L7
        FDB     L8
        FDB     L9
        FDB     LSPC
        FDB     LA
        FDB     LB
        FDB     LC
        FDB     LD
        FDB     LE
        FDB     LF
        FDB     LG
        FDB     LH
        FDB     LI
        FDB     LJ
        FDB     LK
        FDB     LL
        FDB     LM
        FDB     LN
        FDB     LO
        FDB     LP
        FDB     LQ
        FDB     LR
        FDB     LS
        FDB     LT
        FDB     LU
        FDB     LV
        FDB     LW
        FDB     LX
        FDB     LY
        FDB     LZ
        FDB     LBARW
        FDB     LEQU
        FDB     LDSH
        FDB     LQUE
        FDB     LEXC
        FDB     LBRKL
        FDB     LBRKR
        FDB     LSQOT
        FDB     LCMMA
        FDB     LPER
        FDB     LSLSH
        FDB     LAMP
        FDB     LDQOT
        FDB     LCOLON
        FDB     LCUR
        FDB     LCNARW

FONT35  FDB     S0
        FDB     S1
        FDB     S2
        FDB     S3
        FDB     S4
        FDB     S5
        FDB     S6
        FDB     S7
        FDB     S8
        FDB     S9
        FDB     SSPC
        FDB     SA
        FDB     SB
        FDB     SC
        FDB     SD
        FDB     SE
        FDB     SF
        FDB     SG
        FDB     SH
        FDB     SI
        FDB     SJ
        FDB     SK
        FDB     SL
        FDB     SM
        FDB     SN
        FDB     S0
        FDB     SP
        FDB     SQ
        FDB     SR
        FDB     S5
        FDB     ST
        FDB     SU
        FDB     SV
        FDB     SW
        FDB     SX
        FDB     SY
        FDB     SZ
        FDB     SBARW
        FDB     SEQU
        FDB     SDSH
        FDB     SQUE
        FDB     SEXC
        FDB     SBRKL
        FDB     SBRKR
        FDB     SSQOT
        FDB     SCMMA
        FDB     SPER
        FDB     S000
        FDB     SARRW

;********       NLIST

L0      FCB     $03,$07         ;XSIZE,YSIZE
        FCB     $01,$11,$00     ;CHARACTER '0'
        FCB     $10,$00,$10
        FCB     $10,$01,$10
        FCB     $10,$10,$10
        FCB     $11,$00,$10
        FCB     $10,$00,$10
        FCB     $01,$11,$00

L1      FCB     $03,$07
        FCB     $00,$10,$00     ;CHARACTER '1'
        FCB     $01,$10,$00
        FCB     $00,$10,$00
        FCB     $00,$10,$00
        FCB     $00,$10,$00
        FCB     $00,$10,$00
        FCB     $11,$11,$10

L2      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER '2'
        FCB     $10,$00,$10
        FCB     $00,$00,$10
        FCB     $00,$11,$00
        FCB     $01,$00,$00
        FCB     $10,$00,$10
        FCB     $11,$11,$10


L3      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER '3'
        FCB     $10,$00,$10
        FCB     $00,$00,$10
        FCB     $00,$11,$00
        FCB     $00,$00,$10
        FCB     $10,$00,$10
        FCB     $01,$11,$00


L4      FCB     $03,$07
        FCB     $00,$01,$10     ;CHARACTER '4'
        FCB     $00,$10,$10
        FCB     $01,$00,$10
        FCB     $10,$00,$10
        FCB     $11,$11,$10
        FCB     $00,$00,$10
        FCB     $00,$00,$10


L5      FCB     $03,$07
        FCB     $11,$11,$10     ;CHARACTER '5'
        FCB     $10,$00,$00
        FCB     $11,$11,$00
        FCB     $00,$00,$10
        FCB     $00,$00,$10
        FCB     $10,$00,$10
        FCB     $01,$11,$00


L6      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER '6'
        FCB     $10,$00,$00
        FCB     $10,$11,$00
        FCB     $11,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $01,$11,$00


L7      FCB     $03,$07
        FCB     $11,$11,$10     ;CHARACTER '7'
        FCB     $10,$00,$10
        FCB     $00,$01,$00
        FCB     $00,$10,$00
        FCB     $01,$00,$00
        FCB     $01,$00,$00
        FCB     $01,$00,$00


L8      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER '8'
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $01,$11,$00
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $01,$11,$00


L9      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER '9'
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$01,$10
        FCB     $01,$10,$10
        FCB     $00,$00,$10
        FCB     $01,$11,$00

LSPC    FCB     $03,$07
        FCB     $00,$00,$00     ;CHARACTER ' '
        FCB     $00,$00,$00
        FCB     $00,$00,$00
        FCB     $00,$00,$00
        FCB     $00,$00,$00
        FCB     $00,$00,$00
        FCB     $00,$00,$00

LA      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER 'A'
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $11,$11,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10


LB      FCB     $03,$07
        FCB     $11,$11,$00     ;CHARACTER 'B'
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$11,$00
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $11,$11,$00


LC      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER 'C'
        FCB     $10,$00,$10
        FCB     $10,$00,$00
        FCB     $10,$00,$00
        FCB     $10,$00,$00
        FCB     $10,$00,$10
        FCB     $01,$11,$00


LD      FCB     $03,$07
        FCB     $11,$10,$00     ;CHARACTER 'D'
        FCB     $10,$01,$00
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $11,$11,$00


LE      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER 'E'
        FCB     $10,$00,$10
        FCB     $10,$00,$00
        FCB     $11,$11,$00
        FCB     $10,$00,$00
        FCB     $10,$00,$10
        FCB     $01,$11,$00


LF      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER 'F'
        FCB     $10,$00,$10
        FCB     $10,$00,$00
        FCB     $11,$11,$00
        FCB     $10,$00,$00
        FCB     $10,$00,$00
        FCB     $10,$00,$00


LG      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER 'G'
        FCB     $10,$00,$10
        FCB     $10,$00,$00
        FCB     $10,$00,$00
        FCB     $10,$01,$10
        FCB     $10,$00,$10
        FCB     $01,$11,$00


LH      FCB     $03,$07
        FCB     $01,$00,$10     ;CHARACTER 'H'
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $11,$11,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10


LI      FCB     $02,$07
        FCB     $11,$10         ;CHARACTER 'I'
        FCB     $01,$00
        FCB     $01,$00
        FCB     $01,$00
        FCB     $01,$00
        FCB     $01,$00
        FCB     $11,$10


LJ      FCB     $03,$07
        FCB     $00,$01,$10     ;CHARACTER 'J'
        FCB     $00,$00,$10
        FCB     $00,$00,$10
        FCB     $00,$00,$10
        FCB     $00,$00,$10
        FCB     $10,$00,$10
        FCB     $01,$11,$00


LK      FCB     $03,$07
        FCB     $10,$00,$10     ;CHARACTER 'K'
        FCB     $10,$01,$00
        FCB     $10,$10,$00
        FCB     $11,$00,$00
        FCB     $10,$10,$00
        FCB     $10,$01,$00
        FCB     $10,$00,$10


LL      FCB     $03,$07
        FCB     $01,$00,$00     ;CHARACTER 'L'
        FCB     $10,$00,$00
        FCB     $10,$00,$00
        FCB     $10,$00,$00
        FCB     $10,$00,$00
        FCB     $10,$00,$10
        FCB     $11,$11,$10


LM      FCB     $04,$07
        FCB     $01,$10,$11,$00 ;CHARACTER 'M'
        FCB     $10,$01,$00,$10
        FCB     $10,$01,$00,$10
        FCB     $10,$01,$00,$10
        FCB     $10,$01,$00,$10
        FCB     $10,$00,$00,$10
        FCB     $01,$00,$01,$00


LN      FCB     $03,$07
        FCB     $10,$00,$10     ;CHARACTER 'N'
        FCB     $11,$00,$10
        FCB     $10,$10,$10
        FCB     $10,$10,$10
        FCB     $10,$10,$10
        FCB     $10,$01,$10
        FCB     $10,$00,$10


LO      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER 'O'
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $01,$11,$00


LP      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER 'P'
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $11,$11,$00
        FCB     $10,$00,$00
        FCB     $10,$00,$00
        FCB     $10,$00,$00


LQ      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER 'Q'
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$10,$10
        FCB     $10,$01,$00
        FCB     $01,$10,$10


LR      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER 'R'
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $11,$11,$00
        FCB     $10,$10,$00
        FCB     $10,$01,$00
        FCB     $10,$00,$10

LS      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER 'S'
        FCB     $10,$00,$10
        FCB     $11,$00,$00
        FCB     $00,$11,$00
        FCB     $00,$00,$10
        FCB     $10,$00,$10
        FCB     $01,$11,$00

LT      FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER 'T'
        FCB     $10,$10,$10
        FCB     $00,$10,$00
        FCB     $00,$10,$00
        FCB     $00,$10,$00
        FCB     $00,$10,$00
        FCB     $01,$11,$00


LU      FCB     $03,$07
        FCB     $01,$00,$10     ;CHARACTER 'U'
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $01,$11,$00


LV      FCB     $03,$07
        FCB     $01,$00,$10     ;CHARACTER 'V'
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $01,$01,$00
        FCB     $01,$01,$00
        FCB     $00,$10,$00


LW      FCB     $04,$07
        FCB     $01,$00,$01,$00 ;CHARACTER 'W'
        FCB     $10,$00,$00,$10
        FCB     $10,$00,$00,$10
        FCB     $10,$01,$00,$10
        FCB     $10,$01,$00,$10
        FCB     $10,$01,$00,$10
        FCB     $01,$10,$11,$00


LX      FCB     $03,$07
        FCB     $10,$00,$10     ;CHARACTER 'X'
        FCB     $10,$00,$10
        FCB     $01,$01,$00
        FCB     $00,$10,$00
        FCB     $01,$01,$00
        FCB     $10,$00,$10
        FCB     $10,$00,$10


LY      FCB     $03,$07
        FCB     $01,$00,$10     ;CHARACTER 'Y'
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $01,$01,$00
        FCB     $00,$10,$00
        FCB     $00,$10,$00
        FCB     $00,$10,$00

LZ      FCB     $03,$07
        FCB     $01,$11,$10     ;CHARACTER 'Z'
        FCB     $00,$00,$10
        FCB     $00,$01,$00
        FCB     $00,$10,$00
        FCB     $01,$00,$00
        FCB     $10,$00,$00
        FCB     $11,$11,$10

LBARW   FCB     $03,$07
        FCB     $00,$01,$00     ;CHARACTER '<-'
        FCB     $00,$10,$00
        FCB     $01,$00,$00
        FCB     $11,$11,$10
        FCB     $01,$00,$00
        FCB     $00,$10,$00
        FCB     $00,$01,$00

LEQU    FCB     $03,$05
        FCB     $00,$00,$00     ;CHARACTER '='
        FCB     $00,$00,$00
        FCB     $11,$11,$10
        FCB     $00,$00,$00
        FCB     $11,$11,$10

LDSH    FCB     $03,$04
        FCB     $00,$00,$00     ;CHARACTER '-'
        FCB     $00,$00,$00
        FCB     $00,$00,$00
        FCB     $11,$11,$10

LQUE    FCB     $03,$07
        FCB     $01,$11,$00     ;CHARACTER '?'
        FCB     $10,$00,$10
        FCB     $10,$00,$10
        FCB     $00,$01,$00
        FCB     $00,$10,$00
        FCB     $00,$00,$00
        FCB     $00,$10,$00

LEXC    FCB     $01,$07
        FCB     $10             ;CHARACTER '!'
        FCB     $10
        FCB     $10
        FCB     $10
        FCB     $10
        FCB     $00
        FCB     $10

LBRKL   FCB     $02,$07
        FCB     $00,$10         ;CHARACTER '('
        FCB     $01,$00
        FCB     $10,$00
        FCB     $10,$00
        FCB     $10,$00
        FCB     $01,$00
        FCB     $00,$10

LBRKR   FCB     $02,$07
        FCB     $10,$00         ;CHARACTER ')'
        FCB     $01,$00
        FCB     $00,$10
        FCB     $00,$10
        FCB     $00,$10
        FCB     $01,$00
        FCB     $10,$00

LSQOT   FCB     $01,$02
        FCB     $10             ;CHARACTER '''
        FCB     $10

LCMMA   FCB     $01,$07
        FCB     $00             ;CHARACTER ','
        FCB     $00
        FCB     $00
        FCB     $00
        FCB     $00
        FCB     $10
        FCB     $10

LPER    FCB     $01,$07
        FCB     $00             ;CHARACTER '.'
        FCB     $00
        FCB     $00
        FCB     $00
        FCB     $00
        FCB     $00
        FCB     $10

LSLSH   FCB     $03,$07
        FCB     $00,$00,$10     ;CHARACTER '/'
        FCB     $00,$00,$10
        FCB     $00,$01,$00
        FCB     $00,$10,$00
        FCB     $01,$00,$00
        FCB     $10,$00,$00
        FCB     $10,$00,$00

LAMP    FCB     $03,$07
        FCB     $01,$00,$00     ;CHARACTER '&'
        FCB     $10,$10,$00
        FCB     $10,$10,$00
        FCB     $01,$00,$00
        FCB     $10,$10,$10
        FCB     $10,$01,$00
        FCB     $01,$10,$10

LDQOT   FCB     $02,$02
        FCB     $10,$10         ;CHARACTER '"'
        FCB     $10,$10

LCOLON  FCB     $02,$07
        FCB     $00,$00         ;CHARACTER ':'
        FCB     $11,$10
        FCB     $11,$10
        FCB     $00,$00
        FCB     $00,$00
        FCB     $11,$10
        FCB     $11,$10

LCUR    FCB     $03,$08
        FCB     $00,$00,$00     ;CHARACTER '_'
        FCB     $00,$00,$00
        FCB     $00,$00,$00
        FCB     $00,$00,$00
        FCB     $00,$00,$00
        FCB     $00,$00,$00
        FCB     $00,$00,$00
        FCB     $11,$11,$10

LCNARW  FCB     $03,$07
        FCB     $00,$10,$00     ;CHARACTER '^'
        FCB     $01,$11,$00
        FCB     $10,$10,$10
        FCB     $00,$10,$00
        FCB     $00,$10,$00
        FCB     $00,$10,$00
        FCB     $00,$10,$00

S0      FCB     $02,$05         ;CHARACTER '0 & O'
        FCB     $11,$10
        FCB     $10,$10
        FCB     $10,$10
        FCB     $10,$10
        FCB     $11,$10

S1      FCB     $02,$05
        FCB     $01,$00         ;CHARACTER '1'
        FCB     $11,$00
        FCB     $01,$00
        FCB     $01,$00
        FCB     $11,$10

S2      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER '2'
        FCB     $00,$10
        FCB     $11,$10
        FCB     $10,$00
        FCB     $11,$10

S3      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER '3'
        FCB     $00,$10
        FCB     $11,$10
        FCB     $00,$10
        FCB     $11,$10

S4      FCB     $02,$05
        FCB     $10,$10         ;CHARACTER '4'
        FCB     $10,$10
        FCB     $11,$10
        FCB     $00,$10
        FCB     $00,$10

S5      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER '5 & S'
        FCB     $10,$00
        FCB     $11,$10
        FCB     $00,$10
        FCB     $11,$10

S6      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER '6'
        FCB     $10,$00
        FCB     $11,$10
        FCB     $10,$10
        FCB     $11,$10

S7      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER '7'
        FCB     $00,$10
        FCB     $01,$00
        FCB     $01,$00
        FCB     $01,$00

S8      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER '8'
        FCB     $10,$10
        FCB     $11,$10
        FCB     $10,$10
        FCB     $11,$10

S9      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER '9'
        FCB     $10,$10
        FCB     $11,$10
        FCB     $00,$10
        FCB     $00,$10

SSPC    FCB     $02,$05
        FCB     $00,$00         ;CHARACTER ' '
        FCB     $00,$00
        FCB     $00,$00
        FCB     $00,$00
        FCB     $00,$00

SA      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER 'A'
        FCB     $10,$10
        FCB     $11,$10
        FCB     $10,$10
        FCB     $10,$10

SB      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER 'B'
        FCB     $10,$10
        FCB     $11,$00
        FCB     $10,$10
        FCB     $11,$10

SC      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER 'C'
        FCB     $10,$00
        FCB     $10,$00
        FCB     $10,$00
        FCB     $11,$10

SD      FCB     $02,$05
        FCB     $11,$00         ;CHARACTER 'D'
        FCB     $10,$10
        FCB     $10,$10
        FCB     $10,$10
        FCB     $11,$00

SE      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER 'E'
        FCB     $10,$00
        FCB     $11,$00
        FCB     $10,$00
        FCB     $11,$10

SF      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER 'F'
        FCB     $10,$00
        FCB     $11,$00
        FCB     $10,$00
        FCB     $10,$00

SG      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER 'G'
        FCB     $10,$00
        FCB     $10,$10
        FCB     $10,$10
        FCB     $11,$10

SH      FCB     $02,$05
        FCB     $10,$10         ;CHARACTER 'H'
        FCB     $10,$10
        FCB     $11,$10
        FCB     $10,$10
        FCB     $10,$10

SI      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER 'I'
        FCB     $01,$00
        FCB     $01,$00
        FCB     $01,$00
        FCB     $11,$10

SJ      FCB     $02,$05
        FCB     $00,$10         ;CHARACTER 'J'
        FCB     $00,$10
        FCB     $00,$10
        FCB     $10,$10
        FCB     $11,$10

SK      FCB     $02,$05
        FCB     $10,$10         ;CHARACTER 'K'
        FCB     $10,$10
        FCB     $11,$00
        FCB     $10,$10
        FCB     $10,$10

SL      FCB     $02,$05
        FCB     $10,$00         ;CHARACTER 'L'
        FCB     $10,$00
        FCB     $10,$00
        FCB     $10,$00
        FCB     $11,$10

SM      FCB     $03,$05
        FCB     $11,$11,$10     ;CHARACTER 'M'
        FCB     $10,$10,$10
        FCB     $10,$10,$10
        FCB     $10,$00,$10
        FCB     $10,$00,$10

SN      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER 'N'
        FCB     $10,$10
        FCB     $10,$10
        FCB     $10,$10
        FCB     $10,$10

SP      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER 'P'
        FCB     $10,$10
        FCB     $11,$10
        FCB     $10,$00
        FCB     $10,$00

SQ      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER 'Q'
        FCB     $10,$10
        FCB     $10,$10
        FCB     $01,$00
        FCB     $00,$10

SR      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER 'R'
        FCB     $10,$10
        FCB     $11,$00
        FCB     $10,$10
        FCB     $10,$10


ST      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER 'T'
        FCB     $01,$00
        FCB     $01,$00
        FCB     $01,$00
        FCB     $01,$00

SU      FCB     $02,$05
        FCB     $10,$10         ;CHARACTER 'U'
        FCB     $10,$10
        FCB     $10,$10
        FCB     $10,$10
        FCB     $11,$10

SV      FCB     $02,$05
        FCB     $10,$10         ;CHARACTER 'V'
        FCB     $10,$10
        FCB     $10,$10
        FCB     $01,$00
        FCB     $01,$00


;*      AND THE EVER POPULAR COPYRIGHT MESSAGE

        FCC     ' JOUST - COPYRIGHT  (C) 1982 WILLIAMS ELECTRONICS INC. '
        FCC     ' ALL RIGHTS RESERVED '


SW      FCB     $03,$05
        FCB     $10,$00,$10     ;CHARACTER 'W'
        FCB     $10,$00,$10
        FCB     $10,$10,$10
        FCB     $10,$10,$10
        FCB     $11,$11,$10

SX      FCB     $02,$05
        FCB     $10,$10         ;CHARACTER 'X'
        FCB     $10,$10
        FCB     $01,$00
        FCB     $10,$10
        FCB     $10,$10

SY      FCB     $02,$05
        FCB     $10,$10         ;CHARACTER 'Y'
        FCB     $10,$10
        FCB     $11,$10
        FCB     $01,$00
        FCB     $01,$00

SZ      FCB     $02,$05
        FCB     $11,$10         ;CHARACTER 'Z'
        FCB     $00,$10
        FCB     $01,$00
        FCB     $10,$00
        FCB     $11,$10

SBARW   FCB     $02,$05
        FCB     $00,$10         ;CHARACTER '<-'
        FCB     $01,$00
        FCB     $11,$10
        FCB     $01,$00
        FCB     $00,$10

SEQU    FCB     $02,$04
        FCB     $00,$00         ;CHARACTER '='
        FCB     $11,$10
        FCB     $00,$00
        FCB     $11,$10

SDSH    FCB     $02,$03
        FCB     $00,$00         ;CHARACTER '-'
        FCB     $00,$00
        FCB     $11,$10

SQUE    FCB     $02,$05
        FCB     $11,$10         ;CHARACTER '?'
        FCB     $00,$10
        FCB     $01,$10
        FCB     $00,$00
        FCB     $01,$00

SEXC    FCB     $01,$05
        FCB     $10             ;CHARACTER '!'
        FCB     $10
        FCB     $10
        FCB     $00
        FCB     $10

SBRKL   FCB     $02,$05
        FCB     $00,$10         ;CHARACTER '('
        FCB     $01,$00
        FCB     $10,$00
        FCB     $01,$00
        FCB     $00,$10

SBRKR   FCB     $02,$05
        FCB     $10,$00         ;CHARACTER ')'
        FCB     $01,$00
        FCB     $00,$10
        FCB     $01,$00
        FCB     $10,$00

SSQOT   FCB     $01,$02
        FCB     $10             ;CHARACTER '''
        FCB     $10

SCMMA   FCB     $01,$05
        FCB     $00             ;CHARACTER ','
        FCB     $00
        FCB     $00
        FCB     $10
        FCB     $10

SPER    FCB     $01,$05
        FCB     $00     ;$00    ;CHARACTER '.'
        FCB     $00
        FCB     $00
        FCB     $00
        FCB     $10

S000    FCB     $06,$05
        FCB     $11,$10,$11,$10,$11,$10
        FCB     $10,$10,$10,$10,$10,$10
        FCB     $10,$10,$10,$10,$10,$10
        FCB     $10,$10,$10,$10,$10,$10
        FCB     $11,$10,$11,$10,$11,$10

SARRW   FCB     $03,$05
        FCB     $00,$10,$00     ;CHARACTER ' '
        FCB     $00,$01,$00
        FCB     $11,$11,$10
        FCB     $00,$01,$00
        FCB     $00,$10,$00

MESSEND EQU     *               ;ROUTINE & FONT; LAST ABSOLUTE ADDRESS          ;;Fixme was: ENDAD1
LENGT1  EQU     *-MESS          ;ROUTINE & FONT; NUMBER OF BYTES THE MODULE USES
;       LIST

;********       NLIST

        INCLUDE PHRASE.ASM                                                      ;;Fixme was: INCLUDE PHRASE.SRC
;       LIST
ENDADR  EQU     *               ;LAST ABSOLUTE ADDRESS
MESSLEN EQU     *-MESS          ;NUMBER OF BYTES THE MODULE USES                ;;Fixme was: LENGTH (symbol already defined)
;*
        IF *-GAMORG > 0         ;OVERFLOW INTO NEXT MODULE?                     ;;Fixme was: IFGT *-GAMORG
         FCB    $1111           ;OVERFLOWED INTO NEXT MODULE!!
        ENDIF
;       END     ;SYSV                                                           ;;We don't need this as we're assembling everything in one pass