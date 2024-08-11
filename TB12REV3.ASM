;********       NLIST
        INCLUDE RAMDEF.ASM                                                      ;;Fixme was: INCLUDE RAMDEF.SRC
        INCLUDE EQU.ASM                                                         ;;Fixme was: INCLUDE EQU.SRC
        INCLUDE MESSEQU.ASM                                                     ;;Fixme was: INCLUDE MESSEQU.SRC
        INCLUDE MESSEQU2.ASM                                                    ;;Fixme was: INCLUDE MESSEQU2.SRC
;       LIST


GODFLG  EQU     PPOSX+48-11     ;THE FLAG TO TELL IF THE ENTERIE WAS GOD        ;;Fixme was: .GODFLG
SCRSV   EQU     PPOSX+48-10     ;THE PEON SCORE AREA SAVE LOCATION              ;;Fixme was: .SCRSV
AREA    EQU     PPOSX+48-8      ;AREA FOR THE PEON TO ENTER AT                  ;;Fixme was: .AREA
PLYNUM  EQU     PPOSX+48-6      ;THIS IS THE PLAYER NUMBER                      ;;Fixme was: .PLYNUM
SAVEA   EQU     PPOSX+48-5      ;WHERE TO STORE A                               ;;Fixme was: .SAVEA
SAVEB   EQU     PPOSX+48-4      ;WHERE TO STORE B                               ;;Fixme was: .SAVEB
SAVEX   EQU     PPOSX+48-3      ;WHERE TO STORE X                               ;;Fixme was: .SAVEX
SAVEY   EQU     PPOSX+48-1      ;WHERE TO STORE Y                               ;;Fixme was: .SAVEY


        ORG     TSBORG
        JMP     CKCMOS
        JMP     OPTSTS                                                          ;;Fixme was: OPTST$
        JMP     CMOSMV
        JMP     ADVSC
        JMP     CKHS    ;CHECK HIGH SCORES (POWER UP)
        JMP     RESHSC  ;RESET HIGH SCORES
        JMP     HSCHK   ;CHECK HIGH SCORES AFTER FAC SET RESTORE
        JMP     HSBUT   ;HIGH SCORE RESET BUTTON
        JMP     AUD                                                             ;;Fixme was: AUD$
        JMP     AUD1                                                            ;;Fixme was: AUD1$
        JMP     SCCLER
        JMP     RCMOSA
        JMP     RCMOSB
        JMP     RCMOSD
        JMP     WCMOSA
        JMP     WCMOSB
        JMP     WCMOSD
        JMP     HIGHPO
        JMP     ACRED
        JMP     COINL
        JMP     COINC
        JMP     COINR
        JMP     DIVAB
        JMP     BCDHEX
        JMP     HEXBCD
        JMP     ENTINT
        JMP     OPOUT
        JMP     ENDGAM  ;END OF GAME HIGH SCORE PROCESSING

AMODE   TST     ANYONE
        BEQ     .2S
        PKILL   $00,$40         ;KILL EVERYONE EXCEPT H.S.T.D. AND START SWITCH
        PCNAP   4
        PSHS    CC
        ORCC    #$FF
        LDD     #$98D3!DMAFIX                                                   ;;Fixme was: LDD #$98D3!XDMAFIX
        STD     $CA06   ;X & Y SIZE OF DMA
        CLRA
        CLRB
        STD     $CA04   ;DESTINATION ADDRESS
;*      ORIGIN WE DON'T CARE ABOUT
        STA     $CA01   ;WRITE CONSTANT OF '00'
        LDA     #$12
        STA     $CA00   ;START DMA FOR CONSTANT WRITE & NO ZERO SUPPRESS
        PULS    CC
        LDX     #$3920          ;--------|
        LDA     #MSBZB          ;        |--GIVE THE CONGRATS
        LDB     #$11            ;        |
        JSR     OUTPHR          ;--------|
        LDX     #$14CA
        LDA     #MSENT3
        LDB     #$99
        JSR     OUTP35
        LDX     VSNHIGH
        JSR     VSND
;********       LDA     #$FF    ;(OLD TIME 255*20=5100TICKS = 1MIN 25 SEC)
;********       STA     .SAVEA,U
        CLR     SAVEA,U         ;(PFUTZ ALTERATION, WAIT FOR  2 MIN 9 SEC)      ;;Fixme was: .SAVEA,U
.1S     PCNAP   30              ; (OLD DATA 20)                                 ;;Fixme was: 1$
        DEC     SAVEA,U                                                         ;;Fixme was: .SAVEA,U
        BEQ     .2S
        LDX     PLINK,U
        LDA     PID,X
        CMPA    #$41
        BEQ     .1S
        CMPA    #$42
        BEQ     .1S
.3S     JMP     VATTRT                                                          ;;Fixme was: 3$
;*
.2S     PKILL   $42,$FF                                                         ;;Fixme was: 2$
        PCNAP   3
        BRA     .3S
;*
;* CMOS MOVE: DESTINATION=Y, SOURCE=X, COUNT=B
;*
CMOSMV  PSHS    A       ;NEED A
CMMV1   LDA     ,X+     ;GET SOURCE
        EXG     X,Y     ;SWAP
        JSR     WCMOSA  ;RITE IT
        EXG     X,Y     ;SWAP BACK
        DECB            ;DONE?
        BNE     CMMV1   ;NO,LOOP
        PULS    A,PC    ;RETURN CLEAN
;*
;* CLEAR CMOS: CRASHES A,B,X
;*
CLRALL  LDX     #CMOS   ;POINT TO START
CLRA1   CLR     ,X+
        CMPX    #CMOS+$400
        BNE     CLRA1   ;NO, LOOP
        RTS     ;BYE
;*
;* INIT CMOS: SAVES STATE
;*
CMINI   PSHS    X,Y,D   ;SAVE STATE                                             ;;Fixme was: CMINI$
        LDX     #DEFALT ;POINT TO ROM
        LDY     #CMOS   ;POINT TO DESTINATION
        LDB     #DEFSIZ ;LENGTH
        BSR     CMOSMV  ;MOVE THEM ALL
        PULS    X,Y,D,PC ;ALL DONE

OPSET   PSHS    X,Y,D
        LDX     #OPD1
        LDY     #OPMESS
        LDB     #52     ;50 BYTES WORTH
        BSR     CMOSMV  ;DO THE XFER
        JSR     OPCHK   ;FIND THE CHECK BYTE
        LDX     #OMESUM ;PLACE TO STORE IT
        JSR     WCMOSA ;WRITE IT
        PULS    X,Y,D,PC
;*
;*
;* DEFAULT HERE FOR NOW
;*
DEFALT  FCB     $20     ;REPLAY @20,000
        FCB     $05     ;NMEN
        FCB     $01     ;HIGH SCORE TO DATE ALLOWED
        FCB     $03     ;CSELCT
        FCB     $01     ;SLOT1M
        FCB     $04     ;SLOT2M
        FCB     $01     ;SLOT3M
        FCB     $01     ;CUNITC
        FCB     $00     ;CUNITB
        FCB     $00     ;MINUNT
        FCB     $05     ;GA1  MASTER DIFFICULTY
        FCB     $03     ;NUMBER OF LETTERS FOR GOD
        FCB     $00     ;FACTORY SETTINGS
        FCB     $00     ;CLEAR AUDIT TOTALS
        FCB     $00     ;CLEAR HSTD
        FCB     $00     ;AUTOCYCLE
        FCB     $00     ;ENTER OPERATOR MESSAGE
        FCB     $00     ;ENTER HSTD
DEFSIZ  EQU     *-DEFALT
OPD1    FCB     CSPC,CSPC,CSPC,CSPC,CSPC,CSPC,CSPC
        FCB     CP,CR,CE,CS,CE,CN,CT,CE,CD,CSPC,CB,CY,CCOLN
        FCB     CSPC,CSPC,CSPC,CSPC,CSPC
OPD2    FCB     CW,CI,CL,CL,CI,CA,CM,CS,CSPC,CE,CL,CE,CC,CT,CR,CO,CN,CI,CC,CS
        FCB     CSPC,CI,CN,CC,CPER
        FCB     $25,$29




ADVSC   JSR     MAKCHK  ;DO THE CHECKSUM
        JSR     SCCLER
ADVSC2  LDA     PIA0
        BITA    #2
        BNE     ADVSC2  ;WAIT FOR RELEASE
ADVSC3  LDA     SPECFN+3 ;CLEAR AUDITS??
        ANDA    #$F
        BEQ     ADVSC4
        CLR     SPECFN+3
        JSR     MAKCHK
        JSR     SCCLER
        JSR     AUDCK4  ;CLEAR THE AUDIT TOTALS AND PRINT THE MESSAGE.
        LDA     #$40
        JSR     NAPV
ADVSC4  LDA     SPECFN+5 ;CHECK AUDIT MESSAGE
        ANDA    #$F
        BEQ     ADVSC6  ;NOT THERE
        CLR     SPECFN+5
        BSR     MAKCHK
        JSR     RSHSV   ;GO AND DO IT
        LDA     #$40
        JSR     NAPV
ADVSC6  LDA     SPECFN+9 ;OPERATOR MESSAGE
        ANDA    #$F     ;LOOK AT RELEVANCE
        BEQ     ADVSC5
        CLR     SPECFN+9
        BSR     MAKCHK
        JSR     SCCLER  ;CLEAR THE SCREEN
        LDA     #TXSETA
        JSR     TEXT    ;PRINT A PROMPTING MESSAGE
        JSR     OPENT   ;GET THE OPERATOR MESSAGE
        LDA     $20
        JSR     NAPV
        JSR     OPCHK   ;FORM THE CHECK BYTE
        LDX     #OMESUM ;POINT
        JSR     WCMOSA  ;AND STORE IT.
ADVSC5  LDA     SPECFN+11 ;ENTER GOD'S NAME??
        ANDA    #$F
        BEQ     ADVSC8
        CLR     SPECFN+11
        BSR     MAKCHK
        JSR     SCCLER  ;CLEAR THE SCREEN
        LDA     #TXSETG
        JSR     TEXT    ;PRINT A PROMPTING MESSAGE
        JSR     GODSET  ;GO AND DO IT
        JSR     MKGODC  ;MAKE GODS CHECK BYTE
ADVSC8  LDA     SPECFN+7 ;AUTO CYCLE
        ANDA    #$F
        BEQ     NOAUT
        CLR     SPECFN+7
        BSR     MAKCHK
        BSR     FSCHK
        JMP     AUTOCY
NOAUT   BSR     FSCHK                                                           ;;Fixme was: NOAUT$
        BRA     CKCMOS

FSCHK   LDA     SPECFN+1
        ANDA    #$F     ;FACTORY SETTINGS??
        BEQ     ADVS33
        INC     ADJSUM
        INC     ADJSUM  ;BASH THE CHECK BYTE...THIS WILL RESTORE.
        CLR     SPECFN+1 ;AND UNDO IT
ADVS33  RTS


MAKCHK  PSHS    X,A
        BSR     FCHK    ;FIND THE NEW CHECKSUM.
        LDX     #ADJSUM
        JSR     WCMOSA
        PULS    X,A,PC

FCHK    PSHS    B,X,Y
        LDX     #CMOS
        LDY     #ENDADJ
        BSR     FCHKS                                                           ;;Fixme was: FCHK$
        PULS    B,X,Y,PC

OPCHK   LDX     #OPMESS
        LDY     #OPMESS+104
;*
FCHKS   STY     XTEMP                                                           ;;Fixme was: FCHK$
        CLRA
FCHK1   LDB     ,X+
        ANDB    #$F
        PSHS    B
        ADDA    ,S+
        CMPX    XTEMP
        BNE     FCHK1
        ADDA    #$37    ;FUDGE FACTOR
        RTS

CKADJ   BSR     FCHK
        PSHS    A
        LDX     #ADJSUM
        JSR     RCMOSA
        CMPA    ,S+
        RTS

CKCMOS  BSR     OPTST   ;CHECK OPERATOR MESSAGE
        BSR     CKADJ   ;CHECK ADJ
        BEQ     CKSRT0
        LDA     #WDATA
        STA     WDOG
        JSR     CMINI                                                           ;;Fixme was: CMINI$
        LDA     #WDATA
        STA     WDOG
        BSR     MAKCHK
        LDA     #WDATA
        STA     WDOG
        JSR     SCCLER  ;CLEAR THE SCREEN
        LDA     #WDATA
        STA     WDOG
        BSR     AUDCHK  ;CHECK FOR FAULTY AUDITS
        JSR     CHKHSV  ;CHECK FOR FAULTY HIGH SCORES
        JSR     CKHSV   ;NOW VALIDATE
        BSR     CKADJ
        BEQ     CKSNOR
        LDA     #TXIMES ;TELL THE OPERATOR WHAT IS GOING ON.
CMLOP0  JSR     TEXT
CMLOP   LDA     #WDATA
        STA     WDOG
        LDA     PIA0    ;CHECK
        BITA    #2
        BEQ     CMLOP   ;NOT PRESSED CONTINUE TO HANG
CKSMRT  JMP     [$EFFE] ;START HIM UP
CKSRT0  JSR     CKHSV   ;FIX UP THE HIGH SCORE AREA AND RETURN
        BRA     CKSMRT
CKSNOR  LDA     #TXREST
        BRA     CMLOP0

AUDCHK  LDX     #SLOT1
        LDB     #4      ;FOUR BAD BYTES IN AUDIT AREA AFTER RESET IS ENOUGH.
AUDCK2  LDA     ,X+     ;GET A BYTE
        ANDA    #$F
        CMPA    #9      ;HEX???
        BLS     AUDCK1  ;NOPE
        DECB            ;ONE MORE
        BEQ     AUDCK4
AUDCK1  CMPX    #ENDBOK+6 ;DONE??
        BNE     AUDCK2
        RTS
AUDCK4  LDA     #TXBKRS
        JSR     TEXT    ;PRINT IT
        LDX     #SLOT1
AUDCK5  CLR     ,X+     ;AND CLEAR EM.
        CMPX    #ENDBOK+6
        BNE     AUDCK5
OPTRTS  RTS

OPTST   BSR     OPTSTS  ;CHECK THE BYTE                                         ;;Fixme was: BSR  OPTST$
        BEQ     OPTRTS  ;ITS OK
        JMP     OPSET   ;NO GOOD DEFAULT IT.


;*
;*      COMPARE FOR OPERATOR MESSAGE CHECK BYTE
;*      BEQ FOR OK
;*

OPTSTS  JSR     OPCHK   ;FORM CHECK BYTE                                                ;;Fixme was: OPTST$
        PSHS    A       ;SAVE
        LDX     #OMESUM ;GET THE SUM
        JSR     RCMOSA
        CMPA    ,S+
        RTS


;*
HSBUT   LDA     #$18    ;3 SECONDS REQUIRED
        STA     BCDD
        LDA     #$3F
        STA     SOUND
HSBUT1  LDA     #$08
        JSR     NAPV    ;CHECK BUTTON
HSBUT2  LDA     PIA0
        BITA    #8      ;STILL PRESSED??
        BEQ     HSBUT3  ;NOPE....BYE
        DEC     BCDD
        BNE     HSBUT1  ;NOT ENOUGH TIME YET
        LDY     #GODNAM ;JUST PUT IN DEFAULT NAME
        LDX     #DEFHSR
        LDB     #23     ;NOT THE SCORE, JUST THE NAMES
        JSR     CMSMOV
        JSR     MKGODC  ;MAKE THE NEW CHECK BYTE
        CLR     SOUND   ;INDICATE MISSION ACCOMPLISHED
HSBUT3  RTS

;*
HSCHK   LDY     #CMSCOR ;START AT BEGINNING OF TABLE
        LDB     #8      ;8 BAD ENTRIES IS ADEQUATE FOR FULL BASH
HSCHK1  JSR     FSCCK   ;FORM THE CHECK BYTE
        EORA    6,Y     ;COMPARE TO CHECK BYTE THERE
        ANDA    #$0F
        BEQ     HSCHK2
        DECB
        BEQ     RESHSC  ;8 BAD ONES..RESET
HSCHK2  LDA     #WDATA
        STA     WDOG
        LEAY    SCRSIZ,Y
        CMPY    #TODAYS ;BEYOND REGION??
        BLO     HSCHK1
        RTS
;*
;***    RESHSC   RESET HIGH SCORES
;*
RESHSC  LDA     #WDATA
        STA     WDOG
        LDX     #DEFHSR ;DEFAULT SCORES
        LDY     #GODNAM ;GODS INITIALS FOLLOWED BY GODS SCORE FOLLOWED BY REST
        LDB     #CDEFS1 ;SIZE OF DEFAULT TABLE
        JSR     CMSMOV  ;TRANSFER THE BLOCK
        LDX     #DEFSC2
        LDY     #GODNAM+(2*CDEFS1)
        LDB     #CDEFS2
        JSR     CMSMOV
        JSR     MKGODC
        LDY     #CMSCOR ;WALK THROUGH
RESHS1  JSR     MKSCCK
        LDA     #WDATA
        STA     WDOG
        LEAY    SCRSIZ,Y
        CMPY    #TODAYS
        BLO     RESHS1
        LDA     #TXRESM ;SAY THAT THEY WERE RESET
        JMP     TEXT    ;AND RETURN

DEFHSR
DEFGOD  FCB     CJ,CO,CU,CS,CT,CSPC                                             ;;"JOUST"
        FCB     CW,CI,CL,CL,CI,CA,CM,CS                                         ;;"WILLIAMS"
        FCB     CSPC,CSPC,CSPC,CSPC,CSPC,CSPC
        FCB     CW,CI,CL        ;#1
        FCB     $00,$10,$91,$02         ;09/10/82 NEW REV. TO HANDEL
;*                                       ATTRACT MODE (AT GAME ADJUST 0 TO 3)
;*                                       NOT ERASEING TEXT
;***********    FCB     $00,$10,$72,$12         ;07/21/82
        FCB     CM,CR,CS        ;#2                                             ;;MRS = Mike Stroll
        FCB     $00,$04,$84,$93
        FCB     CJ,CR,CN        ;#3                                             ;;JRN = John Newcomer
        FCB     $00,$04,$71,$13
        FCB     CP,CF,CZ        ;#4                                             ;;PFZ = Bill "Pfutz" Pfutzenreuter
        FCB     $00,$04,$61,$75
        FCB     CC,CW,CK        ;#5                                             ;;CWK = Cary Kolker
        FCB     $00,$04,$52,$22
        FCB     CK,CF,CL        ;#6                                             ;;KFL = Ken Lantz
        FCB     $00,$04,$42,$10
        FCB     CP,CG,CD        ;#7                                             ;;PGD = Paul Dussault
        FCB     $00,$04,$32,$17
        FCB     CK,CE,CN        ;#8                                             ;;KEN = Ken Fedesna?
        FCB     $00,$04,$29,$99
        FCB     CJ,CA,CN        ;#9                                             ;;JAN = Jan Hendricks
        FCB     $00,$04,$10,$11
        FCB     CC,CJ,CM        ;#10                                            ;;CJM = Constantino Mitchell
        FCB     $00,$04,$05,$23
        FCB     CS,CJ,CM        ;#11                                            ;;SJM =
        FCB     $00,$03,$99,$09
        FCB     CC,CR,CB        ;#12                                            ;;CRB =
        FCB     $00,$03,$80,$01
        FCB     CP,CV,CA        ;#13                                            ;;PVA = Python Anghelo (RIP)
        FCB     $00,$03,$72,$10
        FCB     CG,CW,CW        ;#14                                            ;;GWW =
        FCB     $00,$03,$61,$91
        FCB     CR,CO,CN        ;#15                                            ;;RON = Ron Crouse?
        FCB     $00,$03,$51,$01
CDEFS1  EQU     *-DEFHSR
DEFSC2  FCB     CJ,CO,CE        ;#16                                            ;;JOE =
        FCB     $00,$03,$42,$11
        FCB     CT,CI,CM        ;#17                                            ;;TIM = Tim Murphy
        FCB     $00,$03,$35,$67
        FCB     CE,CSPC,CA      ;#18                                            ;;E A =
        FCB     $00,$03,$28,$90
        FCB     CJ,CI,CM        ;#19                                            ;;JIM =
        FCB     $00,$03,$19,$01
        FCB     CW,CE,CS        ;#20                                            ;;WES =
        FCB     $00,$03,$01,$57
        FCB     CL,CE,CO        ;#21                                            ;;LEO =
        FCB     $00,$02,$92,$30
        FCB     CB,CU,CZ        ;#22                                            ;;BUZ =
        FCB     $00,$02,$87,$77
        FCB     CJ,CJ,CK        ;#23                                            ;;JJK = John Kotlarik
        FCB     $00,$02,$79,$87
        FCB     CS,CA,CK        ;#24                                            ;;SAK =
        FCB     $00,$02,$69,$59
        FCB     CD,CE,CB        ;#25                                            ;;DEB =
        FCB     $00,$02,$58,$88
        FCB     CN,CSPC,CF      ;#26                                            ;;N F = Noah Falstein
        FCB     $00,$02,$46,$75
TODTAB  FCB     CJ,CR,CN        ;#27                                            ;;JRN = (repeat)
        FCB     $00,$02,$33,$10
        FCB     CP,CF,CZ        ;#28                                            ;;PFZ = (repeat)
        FCB     $00,$02,$29,$17
        FCB     CK,CF,CL        ;#29                                            ;;KFL = (repeat)
        FCB     $00,$02,$25,$52
        FCB     CC,CW,CK        ;#30                                            ;;CWK = (repeat)
        FCB     $00,$02,$05,$22
        FCB     CJ,CA,CN        ;#31                                            ;;JAN = (repeat)
        FCB     $00,$01,$76,$35
        FCB     CM,CR,CS        ;#32                                            ;;MRS = (repeat)
        FCB     $00,$01,$65,$35
ENDTOD  FCB     CK,CA,CY        ;#33                                            ;;KAY = Kay Anderson
        FCB     $00,$01,$55,$05
        FCB     CJ,CG,CL        ;#34                                            ;;JGL =
        FCB     $00,$01,$43,$15
        FCB     CR,CA,CM        ;#35                                            ;;RAM =
        FCB     $00,$01,$31,$09
        FCB     CH,CE,CC        ;#36                                            ;;HEC = Harry Cline
        FCB     $00,$01,$20,$10
        FCB     CK,CV,CD        ;#37                                            ;;KVD = Kristina Donofrio
        FCB     $00,$01,$17,$55
        FCB     CE,CJ,CS        ;#38                                            ;;EJS = Ed Suchocki
        FCB     $00,$01,$05,$02
        FCB     CV,CA,CX        ;#39                                            ;;VAX = Reference to VAX/VMS?
        FCB     $00,$00,$94,$05
        FCB     CD,CR,CJ        ;#40                                            ;;DRJ = Eugene "Dr. J" Jarvis
        FCB     $00,$00,$83,$11
        FCB     CJ,CA,CY        ;#41    ;HE'S NEVER REALLY SEEN                 ;;JAY =
        FCB     $00,$00,$70,$01
;*
CDEFS2  EQU     *-DEFSC2        ;LENGTH OF TABLE
;*
NULSCR  FCB     CSPC,CSPC,CSPC
        FCB     $00,$00,$40,$00
NULSIZ  EQU     *-NULSCR


CLRSCR  PSHS    X,Y,B   ;SAVE BASHED
        LDX     #NULSCR ;POINT AT NULL SCORE
        LDB     #NULSIZ ;HALF AN ENTRYS WORTH OF BYTES
        JSR     CMSMOV
        PULS    X,Y,B,PC

MKGODC  PSHS    A
        BSR     FGODC   ;FOR GODS CHECK BYTE    IN LOW HALF OF A
        STA     GODNAM+46 ;STORE AFTER THE CHARACTERS
        PULS    A,PC

;*
;**     FORM GOD'S CHECK BYTE
;*

FGODC   PSHS    X
        LDX     #GODNAM ;LETS START AT THE VERY BEGINNING....
        CLRA
FGODC0  ADDA    ,X      ;ADD THE CURRENT NIBBLE
FGODC1  LEAX    1,X
        CMPX    #GODNAM+46 ;CHECK BYTE???
        BEQ     FGODC1
        CMPX    #GODNAM+54 ;DONE???
        BNE     FGODC0
        PULS    X,PC    ;RETURN IN LOW HALF OF A

MKSCCK  PSHS    A
        BSR     FSCCK   ;FORM THE CHECK BYTE
        STA     6,Y     ;STORE IT
        PULS    A,PC

FSCCK   PSHS    Y,B
        LDB     #SCRSIZ
        CLRA
MSCCK0  CMPB    #SCRSIZ-6 ;ABOUT TO DO CHECK BYTE??
        BEQ     MSCCK1
        ADDA    ,Y      ;ADD THE CURRENT BYTE
MSCCK1  LEAY    1,Y
        DECB
        BNE     MSCCK0
        PULS    Y,B,PC

CKHS    LDA     #50     ;DONT GO THROUGH MORE THAN 50
        PSHS    A
        LDY     #CMSCOR ;WALK THROUGH SCORES
CKHS7   BSR     FSCCK   ;FORM THE SCORE CHECK BYTE
        EORA    6,Y
        ANDA    #$F
        BEQ     CKHS5
CKHS4   JSR     RMENTR  ;REMOVE THE ENTRY
        CLR     CREDST
        CLR     CREDST+1
        DEC     ,S      ;MAKE SURE WE DON'T REMOVE TOO MANY
        BEQ     CKHS67
        BRA     CKHS7   ;DON'T PUSH POINTER YET.
CKHS5   LDA     #3
        LDB     #4
        BSR     CKENT
        BCS     CKHS4
CKHS6   LEAY    SCRSIZ,Y ;MOVE TO NEXT
        CMPY    #TODAYS
        BLO     CKHS7
CKHS67  PULS    A       ;TAKE ENTRY OFF OF STACK
        LDX     #TODTAB ;TODAY'S TABLE (NORMAL BYTES)
        LDY     #TODAYS
        LDB     #ENDTOD-TODTAB
        JSR     CMSMOV
        BSR     FGODC   ;NOW CHECK OUT GOD.
        EORA    GODSCR ;CHECK IT OUT
        ANDA    #$F
        BEQ     CKHS1   ;OK..CONTINUE
        BSR     REMGOD
CKHS1   LDY     #GODNAM ;BEGINNING OF TEXT ONLY PART-CHECK ALPHA NUM
        LDA     #23     ;20 CHARS OF TEXT
        LDB     #4      ;4 BYTES OF NUMBERS PLEASE
        BSR     CKENT   ;MAKE SURE ALPHAS AND NUMERICS
        BCC     CKHS3
        BSR     REMGOD  ;REMOVE GOD
CKHS3   RTS

REMGOD  LDX     #GODNAM ;GOD BAD FIRST BLANK OUT
        LDA     #CSPC
CKHS2S  JSR     WCMOSA                                                          ;;Fixme was: CKHS2$
        CMPX    #GODNAM+40      ;DONE??
        BLO     CKHS2S  ;DO ANOTHER CHARACTER
        LDX     #CMSCOR ;#2
        LDY     #GODNAM
        LDA     #6      ;6 NIBBLES
        JSR     BLKMOV  ;MOVED
        LDY     #GODINT ;X STILL POINTS AT FIRST GUYS INITIALS
        BSR     BLKMOV  ;MOV EM TOO
        LDX     #CMSCOR+6 ;#2 SCORE
        LDY     #GODSCR ;#2 SCORE GOES HERE
        LDA     #8
        BSR     BLKMOV
        JSR     MKGODC  ;MAKE THE CHECK BYTE
        LDY     #CMSCOR ;NOW REMEOVE #2
        BRA     RMENTR  ;REMOVE #2 AND RETURN

CKENT   PSHS    D,X
        LDB     #WDATA
        STB     WDOG
        TFR     Y,X     ;CMOSABLE REGISTER
CKENT1  JSR     RCMOSB  ;READ A BYTE
        CMPB    #$0A    ;LOWER THAN A SPACE??
        BLO     CKENT5  ;YEP...NOT VALID
CKENT4  CMPB    #$24
        BHI     CKENT5  ;HIGHER THAN Z
        DECA            ;ONE LESS ON THIS FRONT
        BNE     CKENT1
        LDA     1,S     ;GET THE SECOND PART COUNTER BACK
        JSR     RCMOSB  ;GET THE CHECK BYTE
        ANDB    #$F
        CMPB    #9
        BHI     CKENT5  ;NO HEX ALLOWED
        DECA
CKENT2  JSR     RCMOSB
        PSHS    B
        ANDB    #$F     ;LOOK AT LOW HALF
        CMPB    #9
        PULS    B
        BHI     CKENT5  ;NOT NUMERIC...ERROR!
        ANDB    #$F0
        CMPB    #$99
        BHI     CKENT5
        DECA
        BNE     CKENT2
CKENT3  ANDCC   #$FE    ;(CLC)
CKENT8  LDA     #WDATA
        STA     WDOG
        PULS    X,D,PC
CKENT5  ORCC    #$01    ;SEC
        BRA     CKENT8

;*
;***    RMENTR - REMOVE SCORE ENTRY POINTED TO BY Y.
;*

RMENTR  PSHS    X,Y,D
        LEAX    SCRSIZ,Y ;X POINTS PAST Y
RMENT0  CMPX    #TODAYS ;ARE WE BEYOND IN X.
        BHS     RMENT1  ;YEP...DONE.
        LDA     #SCRSIZ
        BSR     BLKMOV  ;MOVE THE BLOCK X TO Y
        LEAY    SCRSIZ,Y
        LEAX    SCRSIZ,X
        LDA     #WDATA
        STA     WDOG
        BRA     RMENT0
RMENT1  JSR     CLRSCR  ;CLEAR THE BLOCK NOW POINTED AT BY Y (BOTTOM)
        JSR     MKSCCK  ;AND FORM THE CHECK BYTE
        PULS    X,Y,D,PC

;*      BLKMOV  A BYTES FROM [X] TO [Y]

BLKMOV  PSHS    X,Y,D
BLKMV1  LDB     ,X+
        STB     ,Y+
        DECA
        BNE     BLKMV1
        PULS    X,Y,D,PC
;*
;*      WARNING, DMA SCREEN CLEARS DROP INTERUPTS (AND COINS)
;*
;********SCCLER PSHS    D,X,CC          ***PFUT, NEED INTERUPTS ALL THE TIME
;********       ORCC    #$FF
;********       LDX     #$0000
;********       LDD     #$9880!XDMAFIX
;********       STX     $CA04
;********       STD     $CA06
;********       CLRB
;********       STB     $CA01
;********       LDB     #$12
;********       LDA     #WDATA
;********       STA     WDOG
;********       STB     $CA00
;********       LDX     #$0080
;********       STX     $CA04
;********       LDB     #$12
;********       LDA     #WDATA
;********       STA     WDOG
;********       STB     $CA00
;********       LDA     #WDATA
;********       STA     WDOG
;********       PULS    D,X,CC,PC
;*
SCCLER  PSHS    D,X,Y,U
        LDD     #$0000
        TFR     D,X
        TFR     D,Y
        LDU     #$A000          ;START SCREEN ADDRESS
        LDA     #WDATA
.10S    PSHU    B,X,Y           ;30 CLEARED BYTES                               ;;Fixme was: 10$
        PSHU    B,X,Y
        PSHU    B,X,Y
        PSHU    B,X,Y
        PSHU    B,X,Y
        PSHU    B,X,Y
        STA     WDOG
        CMPU    #-20       ;$A000-((($A000+30-1)/30)*30) COMPLICATED END POINT
        BNE     .10S            ;BR=DO NOT STOP
        PULS    D,X,Y,U,PC
;*
;* CMOS PRIMITIVE FOR READING
;*
RCMOSA  EQU     *
RCMOS   LDA     1,X     ;GET LSB
        ANDA    #$0F    ;LEAVE ONLY LS
        PSHS    A       ;SAVE IT
        LDA     ,X++    ;GET MSB + AUTO INC
        ASLA
        ASLA
        ASLA
        ASLA            ;SHIFT LS TO MSB
        ADDA    ,S+     ;GET LSB + FIX STACK
DRTS    RTS             ;BYE
;*
;* READ CMOS INTO D POINTED TO BY X: A=X,X+1; B=X+2,X+3
;*
RCMOSD  BSR     RCMOSA  ;GET THE FIRST BYTE+FALL THRU FOR 2ND
;*
;* READ CMOS INTO B POINTED TO BY X
;*
RCMOSB  PSHS    A       ;SAVE A
        BSR     RCMOSA  ;GET IN A
        TFR     A,B     ;PUT IT IN B
        PULS    A,PC    ;DONE
;*
;* WRITE TO CMOS PRIMITIVE
;*
WCMOSA  EQU     *
WCMOS   PSHS    A       ;SAVE WHATS TO BE WRITTEN
        STA     1,X     ;SAVE LSB
        LSRA            ;SHIFT  MS TO LS
        LSRA
        LSRA
        LSRA
        STA     ,X++    ;SAVE MSB AND AUTO INC
        PULS    A,PC    ;DONE
;*
;* WRITE CMOS FROM D TO X: A=X,X+1; B=X+2,X+3
;*
WCMOSD  BSR     WCMOSA  ;DO IT AND FALL THRU FOR 2ND
;*
;* WRITE CMOS FROM B TO X
;*
WCMOSB  PSHS    A       ;SAVE A
        TFR     B,A     ;MOVE B TO A
        BSR     WCMOSA  ;FAKE IT
        PULS    A,PC    ;DONE
;*
;*
;* AUDIT: COUNT=A, COUNTER=B (1-7)
;*
AUD1    PSHS    D,X     ;SAVE STATE                                             ;;Fixme was: AUD1$
        LDA     #$01    ;BUMP BY COUNT OF 1
        BRA     AUD2
AUD     PSHS    D,X     ;SAVE STATE                                             ;;Fixme was: AUD$
AUD2    ANDB    #$0F    ;LIMIT TO 0-F
        ASLB            ;MAKE   INTO 4X
        PSHS    B
        ASLB
        ADDB    ,S+     ;6X
        LDX     #CMOS-4+$100 ;POINT TO START-6  (CREDITS TAKES UP 2)
        ABX             ;GET THE CORRECT DESTINATION
        BSR     RCMOSB
        PSHS    B
        BSR     RCMOSB
        PSHS    B
        BSR     RCMOSB
        PSHS    B
        ADDA    ,S
        DAA
        STA     ,S
        LDA     1,S
        ADCA    #0
        DAA
        STA     1,S
        LDA     2,S
        ADCA    #0
        DAA
        LEAX    -6,X
        BSR     WCMOSA
        PULS    B
        PULS    A
        BSR     WCMOSD
        PULS    A
AUDX    PULS    D,X,PC  ;CLEAN UP
;*

HIGHPO
        IF DEBUG <> 0                                                           ;;Fixme was: IFN DEBUG
        NOP
        NOP
        NOP
        ELSE
        JSR     VTEST
        ENDIF

        LDA     #TXHSP  ;ROUTINE TO PUT OUT HIGH SCORE TABLE PAGE
        JSR     TEXT
        CLR     XTEMP
        LDX     #$1170
        LDA     #$F1    ;BLANK THE 0 IN NUMBER ONE
        LDB     #$22    ;COLOR 2
        LDY     #GODNAM
        CMPY    HSPP1
        BNE     .20S
        LDB     #RED
        BRA     .22S
.20S    CMPY    HSPP12                                                          ;;Fixme was: 20$
        BNE     .22S
        LDB     #GREEN
.22S    JSR     OUTBCD                                                          ;;Fixme was: 22$
        LDA     #CBRKR
        JSR     OUTCHR
        LEAX    $300,X  ;IMMITATE A SPACE
        LDA     #20+1
        STA     BCDR
.1S     DEC     BCDR                                                            ;;Fixme was: 1$
        BEQ     .10S
        EXG     X,Y     ;X=CMOS, Y=DEST
        JSR     RCMSA
        CMPA    #CSPC   ;IS IT A SPACE
        BGT     .2S
        TST     XTEMP
        BNE     .3S
        STY     XTEMP
        BRA     .3S
.2S     CLR     XTEMP                                                           ;;Fixme was: 2$
.3S     EXG     X,Y     ;X=DEST, Y=CMOS                                         ;;Fixme was: 3$
        JSR     OUTCHR
        BRA     .1S
.10S    TST     XTEMP                                                           ;;Fixme was: 10$
        BEQ     .12S
        LDX     XTEMP
.12S    LDA     #$04                                                            ;;Fixme was: 12$
        STA     BCDR
        LDY     #GODSCR
        EXG     X,Y     ;X=CMOS, Y=DEST
        JSR     RCMSA
        EXG     X,Y     ;X=DEST, Y=CMOS
        ORA     #$F0
        BITA    #$0F
        BNE     .13S
        ORA     #$0F
.13S    JSR     OUTBCD                                                          ;;Fixme was: 13$
        DEC     BCDR
.11S    EXG     X,Y     ;X=CMOS, Y=DEST                                         ;;Fixme was: 11$
        JSR     RCMSA
        EXG     X,Y     ;X=DEST, Y=CMOS
        JSR     OUTBCD
        DEC     BCDR
        BNE     .11S

;*      TIME TO DO THE SMALL STUFF

        LDX     #$1380  ;STARTING COLUMN
        LDB     #$33    ;COLOR 3
        LDU     #OUTB35
        STU     BCDN
        LDU     #OUTC35
        LDA     #13
        STA     BCDR    ;WE WANT THIRTEEN NAMES IN A COLUMN
        LDA     #$2
        STA     BCDD    ;WERE STARTING AT NUMBER TWO IN THE TABLE
        LDA     #$7
        STA     BCDN+2  ;WE WANT SEVEN LINES BETWEEN THE TOPS
        LDA     #$0E
        STA     BCDTMP+1 ;WE WANT IT 14 OVER FROM THE LEFTMOST COLUMN
        BSR     PEONS
        LDX     #$3D80  ;STARTING COLUMN
        LDA     #13
        STA     BCDR    ;WE WANT THIRTEEN NAMES IN A COLUMN
        LDA     #$15
        STA     BCDD    ;WERE STARTING AT NUMBER FIFTEEN IN THE TABLE
        BSR     PEONS
        LDX     #$6780  ;STARTING COLUMN
        LDA     #13
        STA     BCDR    ;WE WANT THIRTEEN NAMES IN A COLUMN
        LDA     #$28
        STA     BCDD    ;WERE STARTING AT NUMBER TWENTY-EIGHT IN THE TABLE
        BSR     PEONS

        LDX     #$1336  ;STARTING COLUMN
        LDY     #TODAYS
        LDB     #$11    ;COLOR 1
        LDU     #OUTBCD
        STU     BCDN
        LDU     #OUTCHR
        LDA     #3
        STA     BCDR    ;WE WANT THREE NAMES IN A COLUMN
        LDA     #$1
        STA     BCDD    ;WERE STARTING AT NUMBER ONE IN THE TABLE
        LDA     #$A
        STA     BCDN+2  ;WE WANT TEN LINES BETWEEN THE TOPS
        LDA     #21
        STA     BCDTMP+1 ;WE WANT IT 21 OVER FROM THE LEFTMOST COLUMN
        BSR     PEONS
        LDX     #$5336  ;STARTING COLUMN
        LDA     #3
        STA     BCDR    ;WE WANT THREE NAMES IN A COLUMN
        LDA     #$4
        STA     BCDD    ;WERE STARTING AT NUMBER FOUR IN THE TABLE
        BSR     PEONS

        IF DEBUG <> 0                                                           ;;Fixme was: IFN DEBUG
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        ELSE
        PROCCR  VCYCLE,$40
        ENDIF

        RTS

;*      PEONS - A ROUTINE THAT WHEN CALLED WILL PUT OUT A COLUMN
;*              WITH THE SPECIFIED FONT SIZE AND SPACING
;*
;*   REG B.=COLOR AND IS ASSUMED TO CONTAIN IT
;*   REG X.=DESTINATION
;*   REG Y.=CMOS LOCATION
;*   REG U.=ROUTINE TO CALL (OUTCHR OR OUTC35)
;*   BCDN  =ROUTINE TO CALL (OUTBCD OR OUTB35)
;*   BCDN+2=NUMBER OF LINES FROM TOP TO TOP OF EACH LINE
;*   BCDR  =NUMBER OF NAMES IN A COLUMN
;*   BCDD  =STORAGE AREA FOR PLAYER POSITION IN TABLE
;* BCDTMP+1=NUMBER TO SPACE OVER FROM START COLUMN
;*
PEONS   STX     SEED    ;SAVE THE STARTING DESTINATION
PEON    PSHS    B       ;SAVE REG B.
        LDB     #$03    ;THERE ARE 3 LETTERS
        STB     COLR    ;SAVE THIS FACT
        INCB            ;AND THERE ARE 4 BYTES OF SCORE
        STB     BCDTMP  ;SAVE THAT ALSO
        LDB     ,S      ;GET REG B.
        CMPY    HSPP1   ;P1 ALL-TIME
        BEQ     .23S
        CMPY    HSPP2   ;P1 DAILY
        BNE     .20S
.23S    LDB     #RED                                                            ;;Fixme was: 23$
.20S    CMPY    HSPP12  ;P2 ALL-TIME                                            ;;Fixme was: 20$
        BEQ     .21S
        CMPY    HSPP22  ;P2 DAILY
        BNE     .22S
.21S    LDB     #GREEN                                                          ;;Fixme was: 21$
.22S    LDA     BCDD    ;GET THE PLAYER POSITION IN THE TABLE                   ;;Fixme was: 22$
        BITA    #$F0    ;SHOULD WE BLANK THE LEADING ZERO
        BNE     .2S     ;BRA=NO BLANKING NEEDED
        ORA     #$F0    ;BLANK IT
.2S     JSR     [BCDN]  ;USE THE SPECIFIED BCD OUTPUT ROUTINE                   ;;Fixme was: 2$
        LDA     #CBRKR  ;GET THE ')' CHARACTER
        JSR     ,U      ;USE THE SPECIFIED CHARACTER OUTPUT ROUTINE
        LDA     #CSPC   ;PUT IN A SPACE
        JSR     ,U      ;USE THE SPECIFIED CHARACTER OUTPUT ROUTINE
.1S     EXG     X,Y     ;RE: X=CMOS, Y=DEST                                     ;;Fixme was: 1$
        JSR     RCMSA   ;GET THE CHARACTER
        EXG     X,Y     ;RE: X=DEST, Y=CMOS
        JSR     ,U      ;GOTO THE SPECIFIED CHARACTER OUTPUT ROUTINE
        DEC     COLR    ;ONE LESS CHARACTER TO OUTPUT
        BNE     .1S

        STX     XTEMP   ;PUT REG X. AWAY SO AS TO MODIFY IT
        LDX     SEED    ;GET OUT INITIAL DESTINATION BACK
        EXG     D,X     ;SAVE THE D REG.
        LDB     XTEMP+1 ;GET THE LOWER BYTE OF THE CURRENT DESTINATION
        ADDA    BCDTMP+1        ;ADD THE SPACE BETWEEN LINES TO THE UPPER BYTE
        EXG     D,X     ;GET BACK D REG. AND WE'VE FORMED THE NEW DESTINATION

        CLR     BCDR+1  ;CLEAR THE TEST FOR BLANKING
.3S     EXG     X,Y     ;RE: X=CMOS, Y=DEST                                     ;;Fixme was: 3$
        JSR     RCMSA   ;GET THE BCD NUMBER FROM CMOS
        EXG     X,Y     ;RE: X=DEST, Y=CMOS
        TST     BCDR+1  ;LETS SEE IF WE BLANKED THE DIGITS BEFORE US
        BNE     .4S     ;BRA= THE DIGITS BEFORE US WERE NOT BLANKED SO..NO BLANK
        PSHS    A       ;SAVE A
        LDA     #$04    ;TO SEE IF THIS IS THE FIRST
        CMPA    BCDTMP  ;ARE WE ON THE FIRST SET OF DIGITS
        BNE     .5S
        PULS    A
        BRA     .6S
.5S     PULS    A                                                               ;;Fixme was: 5$
        BITA    #$F0    ;SHOULD WE BLANK THE UPPER DIGIT
        BNE     .4S     ;BRA=NO WE SHOULDN'T
.6S     ORA     #$F0    ;BLANK THE DIGIT                                        ;;Fixme was: 6$
        BITA    #$0F    ;SHOULD WE BLANK THE LOWER DIGIT
        BNE     .4S     ;BRA= NO WE BETTER NOT
        ORA     #$0F    ;BLANK THE LOWER DIGIT
.4S     STA     BCDR+1  ;SAVE THE CURRENT CHARACTER                             ;;Fixme was: 4$
        COM     BCDR+1  ;COMPLEMENT BECAUSE. IF FULLY BLANKED THE DIGIT WHEN
;*                      ;COMPLEMENTED WILL BE EQUAL TO ZERO... A VERY EASY TEST
        JSR     [BCDN]  ;GOTO THE SPECIFIED BCD OUTPUT ROUTINE
        DEC     BCDTMP  ;ONE LESS BCD TO OUTPUT
        BNE     .3S
        STX     XTEMP   ;PUT REG X. AWAY SO AS TO MODIFY IT
        LDX     SEED    ;GET OUT INITIAL DESTINATION BACK
        EXG     D,X     ;SAVE THE D REG.
        LDB     XTEMP+1 ;GET THE UPPER BYTE OF THE CURRENT DESTINATION
        ADDB    BCDN+2  ;ADD THE SPACE BETWEEN LINES TO THE UPPER BYTE
        EXG     D,X     ;GET BACK D REG. AND WE'VE FORMED THE NEW DESTINATION
        LDA     BCDD    ;GET THE CURRENT POSITION
        ADDA    #$01    ;INCREMENT BY 1
        DAA             ;MAKE IT INTO BCD
        STA     BCDD    ;AND SAVE IT
        DEC     BCDR    ;ONE LESS COLUMN TO DO
        PULS    B       ;GET B BACK
        LBNE    PEON    ;AND LETS DO SOME MORE NAMES
        RTS             ;ALL DONE....NOW THAT DIDN'T HURT A BIT.......



;*
;*
;* ACRED: ADDS A CREDITS TO TOTAL CREDITS; 99 MAX
;*
ACRED   PSHS    A,X     ;SAVE
        ADDA    CREDIT  ;GET PRESENT
        DAA             ;HUMANIZE
        BCC     ACRD0   ;NO OVERFLOW
        LDA     #$99    ;YES, STAY AT 99
ACRD0   STA     CREDIT  ;SAVE NEW COUNT
        LDX     #CREDST ;BACKUP CREDITS
        JSR     WCMOSA
        PULS    X,A     ;GO BACK CLEAN
        JMP     VCREDIT
;*
;* COIN SLOT ROUTINES
;*
COINR   PSHS    D,X     ;SAVE STATE
        LDB     #$03    ;3RD TOTALS(RIGHT COIN)
        BRA     COINS   ;HANDLE BELOW
COINC   PSHS    D,X     ;SAVE STATE
        LDB     #$02    ;2ND TOTALS(CENTER COIN)
        BRA     COINS   ;HANDLE BELOW
COINL   PSHS    D,X     ;SAVE STATE
        LDB     #$01    ;1ST TOTALS(LEFT COIN)
COINS   JSR     AUD1    ;BUMP COUNT BY 1                                        ;;Fixme was: COIN$  JSR  AUD1$
        ASLB    ;DOUBLE FOR CMOS
        LDX     #SLOT1M-2 ;POINT TO START-2
        ABX             ;REMOVE OFFSET
        JSR     RCMOSB  ;GET CORRECT SLOT X
        BSR     BCDHEX  ;CONVERT TO BINARY
        LDA     BUNITS  ;GET PRESENT BONUS UNITS
        PSHS    B       ;AND ADD PRESENT COUNT TO IT
        ADDA    ,S
        STA     BUNITS  ;UPDATE
        LDA     CUNITS
        ADDA    ,S+     ;GET PRESENT
        STA     CUNITS  ;UPDATE
        LDX     #MINUNT ;GET MINIMUM UNITS
        JSR     RCMOSB  ;FROM CMOS
        BSR     BCDHEX  ;WORK IN BINARY
        PSHS    B       ;FOR CBA
        CMPA    ,S+     ;ENOUGH?
        BCC     COIN1   ;YES, GIVE IT
        PULS    D,X,PC  ;NOT ENOUGH SO FAR, BYE
COIN1   LDX     #CUNITC ;HOW MANY?
        JSR     RCMOSB  ;GET IT
        BSR     BCDHEX  ;CONVERT TO HEX
        BSR     DIVAB   ;SAVE REMAINDER IN B
        PSHS    A       ;SAVE COUNT TO BE AWARDED FOR A WHILE
        STB     CUNITS  ;SAVE REMAINDER
        LDX     #CUNITB ;BONUS REQUIRES HOW MANY?
        JSR     RCMOSB  ;IN B
        LDA     BUNITS  ;GET BONUS SO FAR
        BSR     BCDHEX  ;CONVERT TO BINARY
        BSR     DIVAB   ;DIVIDE
        TSTA            ;ANY YET?
        BEQ     COIN2   ;NO
        CLR     CUNITS  ;YES, RESET ANY EXTRA
        CLR     BUNITS
COIN2   ADDA    ,S+     ;GET OTHER CREDITS EARNED
        DAA             ;HUMANIZE
        LDB     #$04    ;BUMP TOTPDC
        JSR     AUD     ;BY THE COUNT PAID FOR                                  ;;Fixme was: JSR  AUD$
        BSR     ACRED   ;ADD TO CREDITS COUNTER
        PULS    D,X,PC  ;CLEAN + GO
;*
;* DIVAB: A/B, REMAINDER IN B
;*
DIVAB   PSHS    B       ;SAVE
        TSTB            ;ANY?
        BNE     DIVAB0  ;YES, HANDLE
        CLRA            ;NO, SET TO 0
        PULS    B,PC    ;CLEAN RETURN
DIVAB0  EXG     A,B     ;FOR DAA
        LDA     #$99    ;START-1
DIVAB1  ADDA    #$01    ;NEXT
        DAA             ;HUMANIZE
        SUBB    ,S      ;TAKE AWAY N
        BCC     DIVAB1  ;LOOP TILL OVERFLOW
        ADDB    ,S+     ;ADD REMAINDER + FIX STACK
        RTS             ;BTE

;*
;*BCD-HEX CONVERT
;*A=BCD-HEX
BCDHEX  PSHS    A
        CLRA
BCH1    CMPB    #$10
        BLO     BCH2
        ADDA    #10
        SUBB    #$10
        BRA     BCH1
BCH2    PSHS    B
        ADDA    ,S+
        TFR     A,B
        PULS    A,PC
;*
;*HEX-BCD CONVERT
;*A=HEX-BCD
HEXBCD  PSHS    B
        TFR     A,B
        CLRA
HBC1    CMPB    #10
        BLO     HBC2
        ADDA    #$10
        DAA
        SUBB    #10
        BRA     HBC1
HBC2    PSHS    B
        ADDA    ,S+
        DAA
        PULS    B,PC
;*

GODSET  LDY     #$B000
        LDX     #GA1+2
        JSR     RCMOSB
        BSR     BCDHEX
        STB     NUMLET,Y                                                        ;;Fixme was: STB  .NUMLET,Y
        LDB     #20
        LDA     #CSPC
        LEAX    CARAC,Y                                                         ;;Fixme was: LEAX  .CARAC,Y
.5S     STA     ,X+                                                             ;;Fixme was: 5$
        DECB
        BNE     .5S
        LDX     #ENTINT
        STX     WAKUP,Y                                                         ;;Fixme was: STX  .WAKUP,Y
        LDX     #$2080
        STX     XSAVE_,Y                                                        ;;Fixme was: STX  .XSAVE,Y (There's two XSAVE symbols so this one has an underscore)
        LDB     #CSPC
        STB     STCHR,Y                                                         ;;Fixme was: STB  .STCHR,Y
        CLR     CURLET,Y                                                        ;;Fixme was: CLR  .CURLET,Y
        LDA     #CZ+1
        STA     NDCHR,Y                                                         ;;Fixme was: STA  .NDCHR,Y
        LDA     #$3C
        STA     SIDE,Y                                                          ;;Fixme was: STA  .SIDE,Y
        LDA     #$77
        STA     COLOR,Y                                                         ;;Fixme was: STA  .COLOR,Y
.1S     JSR     [WAKUP,Y]                                                       ;;Fixme was: 1$  JSR  [.WAKUP,Y]
        BCS     .2S
        JSR     WAIT
        BRA     .1S
.2S     LDB     #20                                                             ;;Fixme was: 2$
        LDX     #GODNAM
        LEAY    CARAC,Y                                                         ;;Fixme was: LEAY  .CARAC,Y
.3S     LDA     ,Y+                                                             ;;Fixme was: 3$
        JSR     WCMOSA
        DECB
        BNE     .3S
        RTS




;*****************************************************************
;*                                                              *
;*      ENTINT - GETS A CHARACTER FROM THE USERS CONTROLS       *
;*              AND PUTS THE CHARACTER IN A BUFFER POINTED      *
;*              TO BY REG Y. WHICH ALSO CONTAINS PARAMETERS     *
;*              NECESSARY TO "ENTINT". SCREEN ECHO IS POINTED   *
;*              TO BY REG X.                                    *
;*                                                              *
;*      PARAMETERS NEEDED ARE:                                  *
;*              @ .NUMLET,Y - THE NUMBER OF LETTERS TO GET      *
;*              @ .CURLET,Y - AT START MUST BE CLEARED          *
;*              @ .STCHR,Y  - THE START OF THE CHARACTER SET    *
;*              @ .NDCHR,Y  - THE END OF THE CHARACTER SET      *
;*              @ .SIDE,Y   - THE CONTROL BYTE FOR THE WIDGET   *
;*              @ .COLOR,Y  - THE COLOR TO WRITE SCREEN ECHO IN *
;*                                                              *
;*      OUTPUTS ARE:                                            *
;*              @ .CARAC,Y  - THE START OF CHARACTER BUFFER     *
;*                                                              *
;*      IF ENTINT IS NOT DONE IT WILL RETURN WITH THE CARRY     *
;*      CLEAR OTHERWISE WHEN DONE THE CARRY WILL BE SET         *
;*                                                              *
;*****************************************************************


ENTINT  CLRA
        LDB     CURLET,Y        ;GET THE CURRENT LETTER TO INPUT                ;;Fixme was: LDB  .CURLET,Y
        BEQ     .21S
.20S    PSHS    B,X                                                             ;;Fixme was: 20$
        DECB
        ADDB    #CARAC                                                          ;;Fixme was: ADDB  #.CARAC
        LDB     B,Y
        ASLB
        LDX     FONT5
        ADDA    [B,X]
        PULS    B,X
        DECB
        BNE     .20S
.21S    LDX     XSAVE_,Y                                                        ;;Fixme was: 21$ LDX  .XSAVE,Y
        LEAX    D,X     ;AND USE A 16 BIT OFFSET
        STX     CURPOS,Y                                                        ;;Fixme was: STX  .CURPOS,Y
        LDB     #CARAC  ;GET THE CHARACTER STORAGE AREA                         ;;Fixme was: LDB  #.CARAC
        ADDB    CURLET,Y        ;GET THE CURRENT LETTER                         ;;Fixme was: ADDB  .CURLET,Y
        LDA     B,Y
        JSR     WRCUR   ;WRITE THE CURSOR
        LDB     SIDE,Y  ;GET THE CONTROL BYTE TO SEND TO THE WIDGET             ;;Fixme was: LDB  .SIDE,Y
        STB     PIA3+1  ;AND GIVE IT TO IT
        LDB     PIA2    ;READ THE SWITCH INPUTS
        ANDB    #$07    ;WE ONLY WANT 'MOVE LEFT','MOVE RIGHT','FALP'
        BNE     .40S    ;BRA= SWITCHES HAVE BEEN PRESSED
        LDB     DEBONC,Y                                                        ;;Fixme was: LDB  .DEBONC,Y
        BEQ     ENTRET
        DEC     DEBONC,Y                                                        ;;Fixme was: DEC  .DEBONC,Y
        BRA     ENTRET
.40S    LDX     #ENTI2  ;DEBOUNCE THEM A BIT                                    ;;Fixme was: 40$
        STX     WAKUP,Y ;GET THE WAKE-UP ADDRESS                                ;;Fixme was: STX  .WAKUP,Y
        ANDCC   #$FE    ;CLEAR CARRY
        RTS             ;GO AND SLEEP

ENTI2   PSHS    B
        LDB     SIDE,Y                                                          ;;Fixme was: LDB  .SIDE,Y
        STB     PIA3+1
        PULS    B
        CMPB    PIA2    ;IS THE SAME SWITCH STILL PRESSED
        BNE     ENTRET  ;BRA= NO SO IT'S PROBBALY NOISE RETURN TO THE CALLER
        LSRB            ;SHIFT IT BECAUSE IF IT'S BIT 0 THEN IT WILL NOW BE 0
        BNE     .2S     ;BRA= IT'S NOT THIS SWITCH
        LDB     DEBONC,Y                                                        ;;Fixme was: LDB  .DEBONC,Y
        BEQ     .1S
        DEC     DEBONC,Y                                                        ;;Fixme was: DEC  .DEBONC,Y
.1S     BSR     ERSHSC  ;GO AND ERASE THE CHARACTER                             ;;Fixme was: 1$
        CMPA    STCHR,Y ;IS THIS THE START CHARACTER                            ;;Fixme was: CMPA  .STCHR,Y
        BNE     .3S     ;BRA= NO IT'S NOT THE BEGINNING
        LDA     NDCHR,Y ;GET THE LAST CHARACTER "WRAP-AROUND"                   ;;Fixme was: LDA  .NDCHR,Y
        BRA     ENTRET  ;WE WANT TO BRANCH OVER THE DECREMENT
.3S     DECA            ;MOVE TO THE NEXT CHARACTER                             ;;Fixme was: 3$
        BRA     ENTRET  ;GO WRITE AND THE CHARCATER
.2S     LSRB            ;SHIFT IT BECAUSE IF IT'S BIT 1 THEN IT WILL NOW BE 0   ;;Fixme was: 2$
        BNE     .5S     ;BRA= IT'S NOT THIS SWITCH
        LDB     DEBONC,Y                                                        ;;Fixme was: LDB  .DEBONC,Y
        BEQ     .10S
        DEC     DEBONC,Y                                                        ;;Fixme was: DEC  .DEBONC,Y
.10S    BSR     ERSHSC  ;GO AND ERASE THE CHARACTER                             ;;Fixme was: 10$
        CMPA    NDCHR,Y ;IS THIS THE END CHARACTER                              ;;Fixme was: CMPA  .NDCHR,Y
        BNE     .6S     ;BRA= NO IT'S NOT THE START
        LDA     STCHR,Y ;GET THE FIRST CHARACTER "WRAP-AROUND"                  ;;Fixme was: LDA  .STCHR,Y
        BRA     ENTRET  ;WE WANT TO BRANCH OVER THE INCREMENT
.6S     INCA            ;MOVE TO THE NEXT CHARACTER                             ;;Fixme was: 6$
        BRA     ENTRET  ;AND NOW WRITE THE CHARACTER
.5S     LDB     DEBONC,Y                                                        ;;Fixme was: 5$  LDB  .DEBONC,Y
        BEQ     .30S
        DEC     DEBONC,Y                                                        ;;Fixme was: DEC  .DEBONC,Y
        BRA     ENTRET
.30S    LDB     #$2                                                             ;;Fixme was: 30$
        STB     DEBONC,Y                                                        ;;Fixme was: STB  .DEBONC,Y
        CMPA    #CBARRW ;IS THE CHARACTER HE ENTERED THE BACK-ARROW
        BNE     .8S     ;BRA= NO SO IT'S A NORMAL CHARACTER
        TST     CURLET,Y        ;IS THIS THE FIRST CHARACTER                    ;;Fixme was: TST  .CURLET,Y
        BEQ     ENTRET  ;BRA= NICE TRY BUT YOU CAN'T FOOL ME
        BSR     ERSHSC  ;OK WE'LL LET YOU GO BACK ONE CHARACTER
        INC     NUMLET,Y        ;ONE MORE CHARACTER TO INPUT                    ;;Fixme was: INC  .NUMLET,Y
        DEC     CURLET,Y        ;BACK THE CURRENT LETTER POINTER 1              ;;Fixme was: DEC  .CURLET,Y
        BSR     ERCUR   ;ERASE THE CURSOR
        BRA     ENT10S  ;NOW THAT YOUR BACK ONE LET'S RETURN TO THE CALLER
.8S     INC     CURLET,Y        ;MOVE THE POINTER TO THE NEXT CHARACTER         ;;Fixme was: 8$  INC  .CURLET,Y
        BSR     ERCUR   ;ERASE THE CURSOR
        DEC     NUMLET,Y        ;ONE LESS CHARACTER TO INPUT                    ;;Fixme was: DEC  .NUMLET,Y
        BNE     ENTRET  ;IT'S NOT ZERO SO RETURN TO THE CALLER
        ORCC    #$01    ;IT'S ZERO SO RETURN WITH CARRY SET TO INDICATE DONE
ENT10S  LDX     #ENTINT                                                         ;;Fixme was: ENT10$
        STX     WAKUP,Y                                                         ;;Fixme was: STX  .WAKUP,Y
        RTS             ;RETURN TO THE CALLER
ENTRET  BSR     OUTHSC  ;WRITE THE CHARACTER
        ANDCC   #$FE    ;CLEAR CARRY
        BRA     ENT10S

OUTHSC  LDB     #CARAC  ;GET THE CHARACTER STORAGE AREA                         ;;Fixme was: LDB  #.CARAC
        ADDB    CURLET,Y        ;POINT AT THE CURRENT LETTER                    ;;Fixme was: ADDB  .CURLET,Y
        STA     B,Y     ;SAVE THE LETTER
        LDB     COLOR,Y ;GET THE COLOR TO WRITE IN                              ;;Fixme was: LDB  .COLOR,Y
OUT1    LDX     CURPOS,Y        ;GET THE SCREEN CURSOR POSITION                 ;;Fixme was: LDX  .CURPOS,Y
        JSR     OUTCHR  ;WRITE THE CHARACTER
        RTS             ;RETURN

ERSHSC  LDB     #$00    ;COLOR ZERO "BACKGROUND"
        BRA     OUT1    ;REUSE SOME CODE

WAIT    PSHS    D       ;SAVE THE STATE OF THE UNION
        LDA     #$04    ;WE WANT ABOUT 16 X 16MS.
        JSR     NAPV    ;AND LET'S DOSE OFF
        PULS    D,PC    ;RETURN

WRCUR   PSHS    D
        LDB     COLOR,Y                                                         ;;Fixme was: LDB  .COLOR,Y
WCUR    LDA     #CCURS
        LDX     CURPOS,Y                                                        ;;Fixme was: LDX  .CURPOS,Y
        JSR     OUTCHR
        PULS    D,PC

ERCUR   PSHS    D
        LDB     #$00
        BRA     WCUR


OPOUT   LDB     #$66
        STB     COLR
        LDB     #$88    ;GET THE Y COORDINATE
        BSR     OPO1
        LDB     #$9A    ;GET THE Y COORDINATE
        BRA     OPO2

OPO1    PSHS    D,X,Y
        LDX     #OPL1   ;GET THE X COORDINATE FROM CMOS
        JSR     RCMSA   ;READ IT
        TFR     D,Y     ;PUT THE STARTING COORDINATE IN REG Y.
        LDX     #OPMESS ;GET THE START OF THE MESSAGE
        LDB     COLR    ;GET THE COLOR
.1S     JSR     RCMSA   ;READ IN A CHARACTER                                    ;;Fixme was: 1$
        EXG     X,Y     ;EXCHANGE CMOS WITH THE SCREEN
        JSR     OUTCHR  ;WRITE THE CHARACTER TO THE SCREEN
        EXG     X,Y     ;EXCHANGE THE SCREEN WITH CMOS
        CMPX    #OPMESS+50      ;ARE AT THE END OF THE FIRST LINE
        BNE     .1S     ;BRA= NO SO GO AND GET ONE MORE
        PULS    D,X,Y,PC        ;WERE DONE SO LET'S RETURN

OPO2    PSHS    D,X,Y
        LDX     #OPL2   ;GET THE X COORDINATE FROM CMOS
        JSR     RCMSA   ;READ IT
        TFR     D,Y     ;PUT THE STARTING COORDINATE IN REG Y.
        LDX     #OPMESS+50      ;GET THE START OF THE MESSAGE
        LDB     COLR    ;GET THE COLOR
.2S     JSR     RCMSA   ;READ IN A CHARACTER                                    ;;Fixme was: 2$
        EXG     X,Y     ;EXCHANGE CMOS WITH THE SCREEN
        JSR     OUTCHR  ;WRITE THE CHARACTER TO THE SCREEN
        EXG     X,Y     ;EXCHANGE THE SCREEN WITH CMOS
        CMPX    #OPMESS+100     ;ARE AT THE END OF THE SECOND LINE
        BNE     .2S     ;BRA= NO SO GO AND GET ONE MORE
        PULS    D,X,Y,PC        ;WERE DONE SO LET'S RETURN

OPST    LDY     #$B000
        STX     XSAVE_,Y                                                        ;;Fixme was: STX  .XSAVE,Y
        LDD     #ENTINT
        STD     WAKUP,Y                                                         ;;Fixme was: STD  .WAKUP,Y
        LDB     #25
        STB     NUMLET,Y                                                        ;;Fixme was: STB  .NUMLET,Y
        LDB     #20
        LDA     #CSPC
        LEAX    CARAC,Y                                                         ;;Fixme was: LEAX  .CARAC,Y
.5S     STA     ,X+                                                             ;;Fixme was: 5$
        DECB
        BNE     .5S
        STB     CURLET,Y                                                        ;;Fixme was: STB  .CURLET,Y
        STB     STCHR,Y                                                         ;;Fixme was: STB  .STCHR,Y
        CLR     CARAC,Y                                                         ;;Fixme was: CLR  .CARAC,Y
        LDA     #CCOLN
        STA     NDCHR,Y                                                         ;;Fixme was: STA  .NDCHR,Y
        LDA     #$3C
        STA     SIDE,Y                                                          ;;Fixme was: STA  .SIDE,Y
        LDA     #$77
        STA     COLOR,Y                                                         ;;Fixme was: STA  .COLOR,Y
.1S     JSR     [WAKUP,Y]                                                       ;;Fixme was: 1$  JSR  [.WAKUP,Y]
        BCS     .2S
        JSR     WAIT
        BRA     .1S

.2S     RTS                                                                     ;;Fixme was: 2$

OPENT   LDX     #$2560
        BSR     OPST
        LDB     #25
        LDX     #OPMESS
        LEAY    CARAC,Y                                                         ;;Fixme was: LEAY  .CARAC,Y
.3S     LDA     ,Y+                                                             ;;Fixme was: 3$
        JSR     WCMOSA
        DECB
        BNE     .3S
        LDA     #$25
        LDX     #OPL1
        JSR     WCMOSA
        LDB     #$88
        BSR     TXCEN
        LDA     #CCNARW ;GET THE CENTERING ARROW
        LDB     #$22    ;GET THE COLOR
        LDX     #$486A  ;POSITION FOR CENTER
        JSR     OUTCHR  ;WRITE IT OUT
        LDU     #OPE2   ;GET THE EXIT ADDRESS
.1S     LDX     #OPL1   ;GET THE X COORDINATE                                   ;;Fixme was: 1$
        JSR     RCMOSB  ;READ IT
        JSR     LTRT    ;LET HIM ADJUST IT
        STB     SW0ST
        CLR     COLR    ;MAKE THE COLOR 0
        LDB     #$60    ;GET THE Y COORDINATE
        JSR     OPO1    ;ERASE IT
        LDA     SW0ST
        LDX     #OPL1
        JSR     WCMOSA  ;SAVE THE NEW COORDINATE
        LDA     #$22
        STA     COLR
        JSR     OPO1    ;WRITE IT
        BRA     .1S


TXCEN   LDA     #MSPCEN ;WRITE THE CENTERING MESSAGE OUT
        LDX     #$2590
        JSR     OUTPHR
        LDA     #MSAENT ;WRITE THE CENTERING MESSAGE OUT
        LDX     #$25A0
        JMP     OUTPHR


OPE2    LDA     #CCNARW ;GET THE CENTERING ARROW
        LDB     #00     ;GET THE COLOR
        LDX     #$486A  ;POSITION FOR CENTER
        JSR     OUTCHR  ;WRITE IT OUT
        BSR     TXCEN
        LDX     #$2570
        JSR     OPST
        LDB     #25
        LDX     #OPMESS+50
        LEAY    CARAC,Y                                                         ;;Fixme was: LEAY  .CARAC,Y
.3S     LDA     ,Y+                                                             ;;Fixme was: 3$
        JSR     WCMOSA
        DECB
        BNE     .3S
        LDA     #$25
        LDX     #OPL2
        JSR     WCMOSA
        LDB     #$88
        BSR     TXCEN
        LDA     #CCNARW ;GET THE CENTERING ARROW
        LDB     #$22    ;GET THE COLOR
        LDX     #$487A  ;POSITION FOR CENTER
        JSR     OUTCHR  ;WRITE IT OUT
        LDU     #OPEND  ;GET THE EXIT ADDRESS
.2S     LDX     #OPL2   ;GET THE X COORDINATE                                   ;;Fixme was: 2$
        JSR     RCMOSB  ;READ IT
        BSR     LTRT    ;LET HIM ADJUST IT
        STB     SW0ST
        CLR     COLR    ;MAKE THE COLOR 0
        LDB     #$70    ;GET THE Y COORDINATE
        JSR     OPO2    ;ERASE IT
        LDA     SW0ST
        LDX     #OPL2
        JSR     WCMOSA  ;SAVE THE NEW COORDINATE
        LDA     #$22
        STA     COLR
        JSR     OPO2    ;WRITE IT
        BRA     .2S
OPEND   RTS


LTRT    LDA     PIA0
        BITA    #$02
        BEQ     .3S
        LEAS    2,S     ;GET RID OF THE RETURN ADDRESS
        JMP     ,U
.3S     LDA     PIA2    ;READ THE SWITCH                                        ;;Fixme was: 3$
        ANDA    #$03    ;ONLY NEED LEFT OR RIGHT
        JSR     WAIT
        CMPA    PIA2    ;IS THE SAME SWITCH STILL PRESSED
        BNE     LTRT
        TSTA
        BEQ     LTRT
        LSRA            ;SHIFT IT
        BNE     .2S     ;BRA= IT'S NOT THIS SWITCH
        CMPB    #$18    ;IS IT AT THE RIGHT-MOST EDGE
        BEQ     LTRT    ;BRA= YES SO DO NOTHING
        DECB            ;DECREMENT THE X COORDINATE
        RTS
.2S     LSRA            ;SHIFT THE SWITCH                                       ;;Fixme was: 2$
        BNE     LTRT    ;BRA= THE SWITCH IS INVALID
        CMPB    #$40    ;IS IT AT THE LEFT-MOST EDGE
        BEQ     LTRT    ;BRA= YES SO DO NOTHING
        INCB            ;INCREMENT THE X COORDINATE
        RTS

OVERFLO LDA     0,X
        ANDA    #$F0
        BEQ     .1S
        LDD     #$9999
        STD     ,X++
        STD     ,X++
.1S     RTS                                                                     ;;Fixme was: 1$


ENDGAM  CLR     ANYONE  ;CLEAR THE DID ANYONE MAKE THE TABLE FLAG
        LDA     N2SHIP+1        ;ARE HIGH SCORES ALLOWED?
        LSRA
        BCS     .90S    ;BRA= YES
        JMP     VATTRT
.90S    LDX     #SPLY1                                                          ;;Fixme was: 90$
        BSR     OVERFLO
        LDX     #SPLY2
        BSR     OVERFLO
        TST     NPLYRS
        BEQ     .1S
        LDX     #SPLY1  ;PLAYER 1'S SCORE
        LDY     #SPLY2  ;PLAYER 2'S SCORE
        JSR     CMPSCR
        BCS     .1S     ;BRA= PLAYER 1 IS GREATER
        EXG     Y,X
        JSR     GODCHK
        BCC     .2S
        INC     ANYONE  ;TELL THEM THAT SOMEONE HAS GONE TO THE TABLE
        PROCCR  GODESB,$42  ; START GOD PROCESS BUT DON'T RELEASE CONTROL YET.
        LDA     #$10
        STA     PNAP,Y
        LDA     #$1
        STA     PLYNUM,Y        ;INDICATE THAT IT IS PLAYER 2                   ;;Fixme was: STA  .PLYNUM,Y
        LDX     #SPLY2
        STX     SCRSV,Y                                                         ;;Fixme was: STX  .SCRSV,Y
        LDX     #$70A0  ;WHERE HE IS TO ENTER
        STX     AREA,Y                                                          ;;Fixme was: STX  .AREA,Y
        BRA     .7S
.2S     LDX     #SPLY2                                                          ;;Fixme was: 2$
        STX     SCRSV,U                                                         ;;Fixme was: STX  .SCRSV,U
        LDX     #$70A0  ;WHERE HE IS TO ENTER
        STX     AREA,U                                                          ;;Fixme was: STX  .AREA,U
        LDA     #$1
        LDB     #$42
        BSR     EGSUB1  ;CHECK IF HE'S A PEON
.7S     LDX     #SPLY1                                                          ;;Fixme was: 7$
        STX     SCRSV,U                                                         ;;Fixme was: STX  .SCRSV,U
        LDX     #$20A0  ;WHERE HE IS TO ENTER
        STX     AREA,U                                                          ;;Fixme was: STX  .AREA,U
        CLRA
        LDB     #$41
        BSR     EGSUB1  ;CHECK IF HE'S A PEON
        BRA     .6S

.1S     LDX     #SPLY1                                                          ;;Fixme was: 1$
        JSR     GODCHK
        BCC     .4S
        INC     ANYONE  ;TELL THEM THAT SOMEONE HAS GONE TO THE TABLE
        PROCCR  GODESB,$42   ;START GOD PROCESS BUT DON'T RELEASE CONTROL YET.
        LDA     #$10
        STA     PNAP,Y
        CLRA
        STA     PLYNUM,Y        ;INDICATE THAT IT IS PLAYER 1                   ;;Fixme was: STA  .PLYNUM,Y
        LDX     #SPLY1
        STX     SCRSV,Y                                                         ;;Fixme was: STX  .SCRSV,Y
        LDX     #$20A0  ;WHERE HE IS TO ENTER
        STX     AREA,Y                                                          ;;Fixme was: STX  .AREA,Y
        BRA     .5S
.4S     LDX     #SPLY1                                                          ;;Fixme was: 4$
        STX     SCRSV,U                                                         ;;Fixme was: STX  .SCRSV,U
        LDX     #$20A0  ;WHERE HE IS TO ENTER
        STX     AREA,U                                                          ;;Fixme was: STX  .AREA,U
        CLRA
        LDB     #$42
        BSR     EGSUB1  ;CHECK IF HE'S A PEON
.5S     TST     NPLYRS                                                          ;;Fixme was: 5$
        BEQ     .6S
        LDX     #SPLY2
        STX     SCRSV,U                                                         ;;Fixme was: STX  .SCRSV,U
        LDX     #$70A0  ;WHERE HE IS TO ENTER
        STX     AREA,U                                                          ;;Fixme was: STX  .AREA,U
        LDA     #$1
        LDB     #$41
        BSR     EGSUB1  ;CHECK IF HE'S A PEON
.6S     JMP     AMODE   ;JUMP TO GAME OVER (AMODE) PROCESSING                   ;;Fixme was: 6$


EGSUB1  JSR     TODCHK  ;CHECK TODAYS HIGH
        BCC     .1S
        INC     ANYONE  ;TELL THEM THAT SOMEONE HAS GONE TO THE TABLE
        PSHS    A
        LDX     #GETHIM ;START ENTER PROCESS BUT DON'T RELEASE CONTROL YET.
        TFR     B,A
        CLRB
        JSR     VCRPROC
        LDA     #$10
        STA     PNAP,Y
        PULS    A
        STA     PLYNUM,Y                                                        ;;Fixme was: STA  .PLYNUM,Y
        LDX     SCRSV,U                                                         ;;Fixme was: LDX  .SCRSV,U
        STX     SCRSV,Y                                                         ;;Fixme was: STX  .SCRSV,Y
        LDX     AREA,U                                                          ;;Fixme was: LDX  .AREA,U
        STX     AREA,Y                                                          ;;Fixme was: STX  .AREA,Y
        RTS
;*
.1S     JSR     ALLCHK  ;CHECK ALL TIME                                         ;;Fixme was: 1$
        BCC     .2S
        INC     ANYONE  ;TELL THEM THAT SOMEONE HAS GONE TO THE TABLE
        PSHS    A
        LDX     #GETHIM ;START ENTER PROCESS BUT DON'T RELEASE CONTROL YET.
        TFR     B,A
        CLRB
        JSR     VCRPROC
        LDA     #$08
        STA     PNAP,Y
        PULS    A
        STA     PLYNUM,Y                                                        ;;Fixme was: STA  .PLYNUM,Y
        LDX     SCRSV,U                                                         ;;Fixme was: LDX  .SCRSV,U
        STX     SCRSV,Y                                                         ;;Fixme was: STX  .SCRSV,Y
        LDX     AREA,U                                                          ;;Fixme was: LDX  .AREA,U
        STX     AREA,Y                                                          ;;Fixme was: STX  .AREA,Y
.2S     RTS                                                                     ;;Fixme was: 2$

;*
GETHIM  CLR     GODFLG,U                                                        ;;Fixme was: CLR  .GODFLG,U
GETHM2  LDB     PLYNUM,U        ;GET PLAYER NUMBER                              ;;Fixme was: LDB  .PLYNUM,U
        BNE     .2S
        LDX     #$0AB0
        LDB     #$3C
        PSHS    B
        LDB     #RED
        BRA     .3S
.2S     LDX     #$58B0                                                          ;;Fixme was: 2$
        LDB     #$34
        PSHS    B
        LDB     #GREEN
.3S     LDA     #MSPEON                                                         ;;Fixme was: 3$
        JSR     OUTPHR  ;PUT THE MESSAGE OUT
        TFR     B,A     ;PUT THE COLOR IN REG A.
        LEAY    PPOSX,U ;GET THE BUFFER IN THE PROCESS AREA
        LDB     #2              ;***PFUT, ASSUME SWITCH ON TO START
        STB     DEBONC,Y        ;***PFUT, ASSUME SWITCH ON TO START             ;;Fixme was: STB  .DEBONC,Y
        PULS    B
        STB     SIDE,Y                                                          ;;Fixme was: STB  .SIDE,Y
;********       CLR     .DEBONC,Y       ***PFUT, ASSUME SWITCH ON TO START
        LDX     #.1S
        STX     RETURN,Y        ;SAVE IT                                        ;;Fixme was: STX  .RETURN,Y
        LDX     AREA,U  ;PLACE TO DO IT                                         ;;Fixme was: LDX  .AREA,U
        JSR     SETPEON
.1S     LDA     PID,U                                                           ;;Fixme was: 1$
        CMPA    #$42
        BEQ     .31S
        STD     SAVEA,U                                                         ;;Fixme was: STD  .SAVEA,U
        STX     SAVEX,U                                                         ;;Fixme was: STX  .SAVEX,U
        STY     SAVEY,U                                                         ;;Fixme was: STY  .SAVEY,U
.30S    PCNAP   1                                                               ;;Fixme was: 30$
        LDX     PLINK,U
        LDA     PID,X
        CMPA    #$42
        BEQ     .30S
        LDD     SAVEA,U                                                         ;;Fixme was: LDD  .SAVEA,U
        LDX     SAVEX,U                                                         ;;Fixme was: LDX  .SAVEX,U
        LDY     SAVEY,U                                                         ;;Fixme was: LDY  .SAVEY,U
.31S    JSR     TODCHK  ;SEE WHERE TO PUT IT ETC.                               ;;Fixme was: 31$
        BCC     GETHM3  ;NOT THIS TIME JACK
        TST     PLYNUM,U                                                        ;;Fixme was: TST  .PLYNUM,U
        BNE     .4S
        STY     HSPP2
        BRA     .5S
.4S     STY     HSPP22                                                          ;;Fixme was: 4$
.5S     LDX     #TODEND-SCRSIZ ;END OF TODAYS                                   ;;Fixme was: 5$
        JSR     SCTRNS
GETHM3  JSR     ALLCHK  ;CHECK FOR ALL TIME
        BCC     GET789  ;NOPE
        TST     GODFLG,U        ;WAS THIS GOD??                                 ;;Fixme was: TST  .GODFLG,U
        BEQ     GETHM4  ;NOPE
GODSPC  LEAX    PPOSX,U
        LEAX    CARAC,X                                                         ;;Fixme was: LEAX  .CARAC,X
        LDY     #GODINT ;JUST STORE THE INITIALS ON THIS SIDE
        LDB     #3
        JSR     CMOSMV  ;DONE.
        JSR     MKGODC  ;FORM GOD'S NEW CHECK BYTE
        LDA     #5      ;INTERESTED IF THERE ARE 5 OTHERS!
        BSR     SETBSS  ;WELL????                                               ;;Fixme was: BSR SETB$$
GET789  BCC     GETHM5  ;NOPE.
        TFR     X,Y     ;MOVE LOWEST POINTED TO INTO Y
        JSR     RMENTR  ;REMOVE IT.
        BRA     GTTHM8  ;AND TELL HIM IT WAS REMOVED
GETHM4  LEAX    $329A,Y
        BNE     .80S
        LDX     #TODAYS-SCRSIZ
        JSR     BUBDN
        LEAY    6,Y
        LDX     SCRSV,U                                                         ;;Fixme was: LDX  .SCRSV,U
        LDB     #4
        JSR     CMOSMV
        LDY     #GODNAM
        TST     PLYNUM,U                                                        ;;Fixme was: TST  .PLYNUM,U
        BNE     .84S
        STY     HSPP1
        BRA     .85S
.84S    STY     HSPP12                                                          ;;Fixme was: 84$
.85S    LEAX    PPOSX,U                                                         ;;Fixme was: 85$
        LEAX    CARAC,X                                                         ;;Fixme was: LEAX  .CARAC,X
        LDB     #20
        JSR     CMOSMV
        BRA     GODSPC
.80S    JSR     SETBOT  ;FIND PLACE TO BUBBLE DOWN TO (5 MAX RULE)              ;;Fixme was: 80$
        PSHS    CC      ;SAVE ANSWER
        PSHS    X
        CMPY    ,S++
        BHI     GETHM8  ;NOT BETTER THAN HIS TOP 5
        BSR     SCTRNS  ;DONE.
        TST     PLYNUM,U                                                        ;;Fixme was: TST  .PLYNUM,U
        BNE     .4S
        STY     HSPP1
        BRA     GETHM8
.4S     STY     HSPP12                                                          ;;Fixme was: 4$
GETHM8  PULS    CC      ;GET CARRY BACK
        BCC     GETHM5
GTTHM8  LDX     #HSPP1  ;START AT PLAYER 1 SAVE
        LEAY    PPOSX,U
        LDX     AREA,U                                                          ;;Fixme was: LDX  .AREA,U
        LEAX    -$150A,X
        LDA     #ONLY5M
        LDB     COLOR,Y                                                         ;;Fixme was: LDB  .COLOR,Y
        JSR     OUTPHR
        PCNAP   $60
GETHM5  JMP     VSUCIDE

SETBSS  PSHS    Y,D                                                             ;;Fixme was: SETB$$
        BRA     SETBT0

SETBOT  PSHS    Y,D
        LDX     #GODINT ;SEE IF MATCH OF GOD INITIALS
        BSR     SETSUB
        LDA     #4      ;ASSUME MATCH
        BCS     SETBT0  ;YEP...ONLY 4 MORE NEEDED
        INCA
SETBT0  STA     XTEMP
        LDX     #CMSCOR ;POINT AT FIRST ENTRY
SETBT1  BSR     SETSUB  ;SEE IF THIS ONE MATCHES
        BCC     SETBT3  ;NOPE...
        DEC     XTEMP   ;FOUND
        BEQ     SETBT5  ;AND TIME TO EXIT
SETBT3  LEAX    SCRSIZ,X ;PUSH TO NEXT
        CMPX    #TODAYS
        BLO     SETBT1  ;NOT DONE...DO ANOTHER
        LDX     #TODAYS-SCRSIZ ;BUBBLE FROM BOTTOM
        ANDCC   #$FE    ;(CLC)
        PULS    Y,D,PC
SETBT5  ORCC    #$01    ;SEC
        PULS    Y,D,PC  ;AND RETURN IT

SETSUB  PSHS    X
        LEAY    PPOSX,U ;ALT TABLE
        LEAY    CARAC,Y                                                         ;;Fixme was: LEAY  .CARAC,Y
        LDB     #3
SETSB2  JSR     RCMOSA
        CMPA    ,Y+     ;COMPARE TO ALT LETTER
        BNE     SETSB1  ;NO GOOD...MOVE TO NEXT
        DECB            ;ONE LESS TO DO
        BNE     SETSB2
        ORCC    #$01    ;SEC
        PULS    X,PC
SETSB1  ANDCC   #$FE    ;(CLC) NO MATCH
        PULS    X,PC

SCTRNS  PSHS    Y
        JSR     BUBDN   ;BUBBLE EM TO MAKE ROOM
        LEAX    PPOSX,U
        LEAX    CARAC,X                                                         ;;Fixme was: LEAX  .CARAC,X
        LDB     #3
        JSR     CMOSMV  ;TRANSFER THE BLOCK
        LDX     SCRSV,U                                                         ;;Fixme was: LDX  .SCRSV,U
        LDB     #4
        JSR     CMOSMV  ;TRANSFER THE SCORE
        PULS    Y
        JMP     MKSCCK  ;FORM THE CHECK BYTE

BUBDN   PSHS    X,Y
        TFR     X,Y     ;BOTTOM IS DESTINATION
BUBDN1  CMPY    2,S     ;IS OUR DESTINATION WHAT WE WANT TO FILL??
        BEQ     BUBDUN  ;THEN WE'RE DONE
        LEAX    -SCRSIZ,Y ;X IS SOURCE
        LDA     #SCRSIZ ;THAT MANY BYTES
        JSR     BLKMOV  ;MOVE THE BLOCK
        LEAY    -SCRSIZ,Y
        BRA     BUBDN1
BUBDUN  PULS    X,Y,PC  ;BYE



GODESB  INC     GODFLG,U        ;FOR LATER USE                                  ;;Fixme was: INC  .GODFLG,U
        LEAY    PPOSX,U ;GET THE BUFFER IN THE PROCESS AREA
        LDA     PLYNUM,U                                                        ;;Fixme was: LDA  .PLYNUM,U
        BNE     .1S
        LDA     #$3C    ;PLAYER 1 PIA SIDE
        STA     SIDE,Y                                                          ;;Fixme was: STA  .SIDE,Y
        LDA     #RED
        BRA     .2S
.1S     LDA     #$34    ;PLAYER 2 PIA SIDE                                      ;;Fixme was: 1$
        STA     SIDE,Y                                                          ;;Fixme was: STA  .SIDE,Y
        LDA     #GREEN
.2S     TFR     A,B                                                             ;;Fixme was: 2$
        LDA     #MSGOD
        LDX     #$295B  ;WHERE TO PUT THE ENTER MESSAGE
        JSR     OUTPHR  ;WRITE IT
        TFR     B,A
        LDX     #.3S
        STX     RETURN,Y                                                        ;;Fixme was: STX  .RETURN,Y
        JMP     SETGOD
.3S     LEAX    CARAC,Y                                                         ;;Fixme was: 3$  LEAX  .CARAC,Y
        LDY     #GODNAM
        LDB     #20
        JSR     CMOSMV
        LDY     #GODINT ;BUBBLE TO VACATE THIS POSITION
        LDX     #TODAYS-SCRSIZ ;FROM BOTTOM
        JSR     BUBDN   ;BUBBLE EM DOWN
        LDY     #CMSCOR ;POINT AT #2
        JSR     MKSCCK  ;AND FORM HIS CHECK BYTE
        LDX     SCRSV,U ;POINT AT SCORE                                         ;;Fixme was: LDX  .SCRSV,U
        LDY     #GODSCR
        LDB     #4
        JSR     CMOSMV
        LDX     #NULSCR ;BLANK INITIALS
        LDY     #GODINT
        LDB     #3
        JSR     CMOSMV
        JSR     MKGODC
        LDX     #GODNAM
        LDA     PLYNUM,U                                                        ;;Fixme was: LDA  .PLYNUM,U
        BNE     .80S
        STX     HSPP1
        BRA     .81S
.80S    STX     HSPP12                                                          ;;Fixme was: 80$
.81S    JMP     GETHM2  ;JUMP INTO THE ROUTINE TO DO THAT.                      ;;Fixme was: 81$

;* GODCHK - THIS ONE ASKS "WELL, DID HE BEAT GOD?"
;*              AND RETURNS WITH CARRY SET IF HE DID.

GODCHK  LDY     #GODSCR ;POINT AT THE SCORE PART
        BRA     CMPSCR  ;COMPARE SCORES
;*      RETURN THE CARRY BIT

;* TODCHK - WILL CHECK TO SEE IF THE PLAYER SPECIFIED
;*              IN .SCRSV,U IS AMONGST THE DAILY PEONS (BUZZARDS)

TODCHK  PSHS    A,X     ;RETURN ENTRY POINTER IF OK
        LDY     #TODAYS+6
        LDX     SCRSV,U                                                         ;;Fixme was: LDX  .SCRSV,U
TODCK1  BSR     CMPSCR  ;COMPARE
        BCS     TODBYE
        LEAY    SCRSIZ,Y ;PUSH TO NEXT
        CMPY    #TODEND ;BEYOND
        BLO     TODCK1
        ANDCC   #$FE    ;(CLC)
        PULS    A,X,PC
TODBYE  LEAY    -6,Y    ;PUSH BACK TO BEGINNING OF ENTRY TO REPLACE
        PULS    A,X,PC  ;AND RETURN WITH CARRY SET

;* ALLCHK - WILL CHECK TO SEE IF THE PLAYER SPECIFIED
;*              IN .SCRSV,U IS AMONGST THE ALLTIME PEONS (JOUST CHAMPIONS)
;*                      AND EVEN CHECK IF HE'S BEAT GOD

ALLCHK  PSHS    A,X
        LDY     #GODSCR ;POINT AT SCORE PART OF GOD ENTRY
        LDX     SCRSV,U                                                         ;;Fixme was: LDX  .SCRSV,U
ALCK1   BSR     CMPSCR
        BCS     TODBYE
        LEAY    SCRSIZ,Y
        CMPY    #TODAYS-SCRSIZ ;BEYOND VISIBLES??????
        BLO     ALCK1   ;NOPE..CONTINUE
        ANDCC   #$FE    ;CLC
        PULS    A,X,PC  ;NOT GOOD ENOUGH

;* CMPSCR - X=MEMORY LOCATION, Y=CMOS OR MEMORY LOCATION, D IS SAVED
;*      THIS WILL ASK THE DEVINE QUESTION:
;*              IS MEMORY-X GREATER THAN MEMORY-Y ?
;*                      IF TRUE THIS WILL SET THE CARRY BIT.

CMPSCR  PSHS    Y,X,D
        EXG     X,Y     ;MAKE X POINT AT CMOS
        LDB     #4      ;4 BYTES THROUGH
CMPSC1  BSR     NEWCHK  ;THIS IS SO WE CAN COMPARE MEMORY TO MEMORY
        CMPB    #4      ;FIRST TIME THROUGH??
        BNE     CMPSC2
        ANDA    #$0F    ;THEN TAKE AWAY CHECK BYTE
CMPSC2  CMPA    ,Y+     ;COMPARE TO PLAYERS SCORE
        BHI     CMPSC4  ;CMOS SCORE HIGHER
        BLO     CMPSC5  ;PLAYER'S SCORE HIGHER
        DECB            ;SAME...ARE WE DONE??
        BNE     CMPSC1  ;NOPE...COMPARE ANOTHER BYTE
CMPSC4  ANDCC   #$FE    ;CLC
        PULS    X,Y,D,PC
CMPSC5  ORCC    #$01    ;SEC PLAYER IS HIGHER
        PULS    X,Y,D,PC

NEWCHK  CMPX    #$C000  ;IS THIS A CMOS MEMORY LOCATION
        BLO     .1S     ;BRA= NO IT'S IN SCRATCH
        JSR     RCMOSA  ;READ A BYTE
        RTS
.1S     LDA     ,X+     ;READ MEMORY AND MOVE AHEAD ALSO                        ;;Fixme was: 1$
        RTS

;*************************************************
;* VALUES NEEDED UPON ENTRY:                    *
;*                                              *
;*      FOR SETGOD:                             *
;*              REG A.=COLOR TO WRITE IN        *
;*                                              *
;*      FOR SETPEON:                            *
;*              REG A.=COLOR TO WRITE IN        *
;*              REG B.=NUMBER OF LETTERS TO GET *
;*              REG X.=WHERE TO ECHO ON SCREEN  *
;*              REG Y.=MEMORY BUFFER LOCATION   *
;*************************************************
;*      LDY     #$XXXX  MEMORY BUFFER
;*      STA     .SIDE,Y THESE MUST BE DEFINED BEFORE CALLING

SETGOD  LDX     #GA1+2  ;GET THE CMOS VALUE FOR THE NUMBER OF LETTERS TO ENTER
        JSR     RCMOSB  ;READ IT
        JSR     BCDHEX  ;CONVERT IT TO HEX
        LDX     #$2643  ;APPROXIMATE AREA FOR GOD'S SCREEN ECHO
        BRA     SETP1
SETPEON LDB     #$03    ;PEONS ONLY GET THREE LETTERS
SETP1   STA     COLOR,Y         ;SAVE THE COLOR TO WRITE IN                     ;;Fixme was: STA  .COLOR,Y
        STB     NUMLET,Y        ;SAVE THE NUMBER OF LETTERS TO GET              ;;Fixme was: STB  .NUMLET,Y
        STX     XSAVE_,Y        ;SAVE THE START OF THE SCREEN ECHO              ;;Fixme was: STX  .XSAVE,Y  (There are two XSAVE symbols)
        LDB     #20      ;FILL A GENERAL SIZE BUFFER WITH SPACES
        LDA     #CSPC    ;        |
        LEAX    CARAC,Y  ;        |                                             ;;Fixme was: LEAX  .CARAC,Y
.5S     STA     ,X+      ;        |                                             ;;Fixme was: 5$
        DECB             ;        |
        BNE     .5S      ;--------|
        LDX     #ENTINT ;GET THE START OF THE INITIAL ENTERING ROUTINE
        STX     WAKUP,Y ;SAVE IT. SO AS TO DO A JSR OFF OF IT                   ;;Fixme was: STX  .WAKUP,Y
        LDB     #CSPC   ;GET A SPACE AGAIN
        CLR     CURLET,Y                                                        ;;Fixme was: CLR  .CURLET,Y
        STB     STCHR,Y ;MAKE IT FIRST LETTER OF THE GROUP HE CAN ENTER         ;;Fixme was: STB  .STCHR,Y
;*      CLR     .CARAC,Y
        LDA     #CZ+1   ;GET THE BACK-ARROW
        STA     NDCHR,Y ;MAKE IT LAST LETTER OF THE GROUP HE CAN ENTER          ;;Fixme was: STA  .NDCHR,Y
.1S     JSR     [WAKUP,Y]                                                       ;;Fixme was: 1$ JSR [.WAKUP,Y]
        BCS     .2S
        STY     SAVEY,U                                                         ;;Fixme was: STY  .SAVEY,U
        STD     SAVEA,U                                                         ;;Fixme was: STD  .SAVEA,U
        PCNAP   3
        LDY     SAVEY,U                                                         ;;Fixme was: LDY  .SAVEY,U
        LDD     SAVEA,U                                                         ;;Fixme was: LDD  .SAVEA,U
        BRA     .1S
.2S     JMP     [RETURN,Y]      ;WHERE TO RETURN TO                             ;;Fixme was: 2$ JMP [.RETURN,Y]


;*      AND THE EVER POPULAR COPYRIGHT MESSAGE

        FCC     'JOUST-(C)1982 WILLIAMS ELECTRONICS INC.'

TB12END EQU     *                                                               ;;Fixme was: ENDADR EQU * (duplicate symbol and EQU in MESSAGE.ASM)
TB12LEN EQU     TB12END-TSBORG                                                  ;;Fixme was: LENGTH (duplicate symbol in MESSAGE.ASM)
;       END     ;SYSV                                                           ;;We don't need this as we're assembling everything in one pass