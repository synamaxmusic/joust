;       NOGEN
;       NCLIST
;       BLIST
DEBUG   EQU     0       ;=0 IS ROM VERSION, <>0 IS DEBUGGING RAM VERSION
;*
;*      SYSTEM MACRO'S
;*
PROCCR  MACRO   ADDR,ID
         LDX    #ADDR
         LDD    #(ID)*256
         JSR    VCRPROC
        ENDM
;*
SECCR   MACRO   ADDR,ID
         LDX    #ADDR
         LDD    #(ID)*256+255
         JSR    VCRPROC
        ENDM
;*
PKILL   MACRO   ID,MASK
         LDD    #(ID)*256+MASK
         JSR    VKLPROC
        ENDM
;*
NAP     MACRO   TIME
         LDA    #TIME
         LDX    #*+6
         JMP    VNAPTIM
        ENDM
;*
PCNAP   MACRO   TIME
         LDA    #TIME
         JSR    VNAPTPC
        ENDM
;*
NAPGO   MACRO   TIME,ADDR
         LDA    #TIME
         LDX    #ADDR
         JMP    VNAPTIM
        ENDM
;*
;*      SYSTEM VECTORED SUBROUTINES
;*
SYSV    EQU     $E000   ;START OF VECTORS
        ORG     SYSV
VINIT2  RMB     9       ;STANDARD OVERHEAD VECTORS
VCRPROC RMB     3       ;CREATE A PROCESS
VKLPROC RMB     3       ;KILL A PROCESS
VSUCIDE RMB     3       ;KILL SELF PROCESS
VNAPTIM RMB     3       ;NAP ENTERANCE
VDCOLOR RMB     3       ;LOAD COLOR RAM ADDR OF COLORS
VRAND   RMB     3       ;RANDOM NUMBER GENERATOR
VCL1ALL RMB     3       ;ALLOCATE DMA AREA FOR ERASE OPERATION
VWR1ALL RMB     3       ;ALLOCATE DMA AREA FOR WRITE OPERATION
VCL1CLS RMB     3       ;ALLOCATE & FLAVOR AREA FOR 1 ERASE OPERATION
VWR1CLS RMB     3       ;ALLOCATE & FLAVOR AREA FOR 1 WRITE OPERATION
VCL2CLS RMB     3       ;ALLOCATE & FLAVOR AREA FOR 2 ERASE OPERATION
VWR2CLS RMB     3       ;ALLOCATE & FLAVOR AREA FOR 2 WRITE OPERATION
VSND    RMB     3       ;SOUND ROUTINE, INPUT REG.X AS SOUND TABLE ADDRESS
VCUPROC RMB     3       ;CREATE A PROCESS, AFTER REG.U PROCESS
VCOLOR1 RMB     2       ;ADDRESS OF COLOR TABLET
VLAVA   RMB     2       ;LAVA PROCESS, (NEEDS TO READ SCREEN)
VNAPTPC RMB     3       ;NAP VIA A JSR ENTERANCE
VNEWCL5 RMB     3       ;THE NEW CLIF5 UN-COMPACTOR ROUTINE
;*
GAMORG  EQU     $5ED0
        ORG     GAMORG
VPWRUP  RMB     3       ;POWER UP VECTOR FROM SYSTEM.SRC TO JOUST.SRC
VATTRT  RMB     3       ;ATTRACT MODE FOR THE GAME, (FOR H.S.T.D.)
VGSTART RMB     2       ;GAME START PUSH BUTTONS
VCREDIT RMB     3       ;VECTOR FOR ANY CREDIT CHANGES
VSNHIGH RMB     2       ;H.S.T.D. SOUND ADDRESS
VHSTD   RMB     3       ;DISPLAY H.S.T.D.'S
VDCRED  RMB     3       ;VECTOR TO DISPLAY CREDIT CHANGES
VSIM    RMB     3       ;GAME SIMULATION OR INSTRUCTIONAL PAGE START
VDCRE2  RMB     3       ;VECTOR TO DISPLAY CREDIT CHANGES (VARIABLE BACKGROUND)
VNULL   RMB     2       ;ADDRESS OF NULL COLOR RAM BLOCK
;*
;*      PROGRAMS OBJECT DEFINITIONS
;*
        ORG     $0
CLIF1L  RMB     2       ;BACKGROUNG CLIFFS
CLIF1R  RMB     2       ;BACKGROUNG CLIFFS
CLIF2   RMB     2       ;BACKGROUNG CLIFFS
CLIF3U  RMB     2       ;BACKGROUNG CLIFFS
CLIF3L  RMB     2       ;BACKGROUNG CLIFFS
CLIF3R  RMB     2       ;BACKGROUNG CLIFFS
CLIF4   RMB     2       ;BACKGROUNG CLIFFS
CLIF5   RMB     2       ;BACKGROUNG CLIFFS
TRANS1  RMB     2       ;TRANSPORTER #1
TRANS2  RMB     2       ;TRANSPORTER #2
TRANS3  RMB     2       ;TRANSPORTER #3
TRANS4  RMB     2       ;TRANSPORTER #4
OSTRICH RMB     2       ;COMPLETE OSTRICH IMAGES
BUZARD  RMB     2       ;COMPLETE BUZZARD IMAGES
STORK   RMB     2       ;COMPLETE STORK IMAGES
PLYR1   RMB     2       ;PLAYER #1 SITTING ON OSTRICH
PLYR2   RMB     2       ;PLAYER #2 SITTING ON OSTRICH
PLYR3   RMB     2       ;PLAYER #3 (ENEMY) SITTING ON BUZARD
PLYR4   RMB     2       ;PLAYER #4 (ENEMY) SITTING ON BUZARD
PLYR5   RMB     2       ;PLAYER #5 (ENEMY) SITTING ON BUZARD
EGGI    RMB     2       ;EGG STILLS & HATCHING
ILAVAT  RMB     2       ;LAVA TROLL STILLS
IFLAME  RMB     2       ;LAVAS FLAMES
POOF1   RMB     2       ;PLAYERS POOF DEATH
POOF2   RMB     2       ;PLAYERS POOF DEATH
POOF3   RMB     2       ;PLAYERS POOF DEATH
IPTERO  RMB     2       ;THE INDESTRUCABLE PTERODACTYL
VCOMCL5 RMB     2       ;THE COMPACTED CLIF5 DATA
ASH1R   RMB     2       ;PTERODACTYL, ASHES TO ASHES, DUST TO DUST
ASH1L   RMB     2       ;PTERODACTYL, ASHES TO ASHES, DUST TO DUST
;*
;*  SYSTEM I/O EQUATES
;*
BASE    EQU     $A000   ;START OF BASE PAGE (POWERUP)
        ASSUME DPR:$A0  ;       DEFAULT DP FOR ASSEMBLER                        ;;Fixme was: SETDP      !H(BASE)
STACK   EQU     $BF00   ;SYSTEMS STACK
IOPORT  EQU     $C000   ;I/O PORTS
UARTST  EQU     $C404   ;UART STATUS; BIT1=1-OK TO TRANS, BIT0=1-OK TO REC
UARTDA  EQU     $C405   ;UART (TERMINAL I/O), DATA
;*CRAM  EQU     $C000   ;COLOR RAM
DRRUC   EQU     $BFFF   ;DCON CARBON COPY OF RRUC
RRUC    EQU     $C900   ;RAM/ROM UPRIGHT COCKTAIL CONTROL
;*                      ;  BIT0 =1 READ ROM  =0 READ SCREEN
;*                      ;  BIT1 =1 INVERTED  =0 UPRIGHT
VSCAN   EQU     $CB00   ;VERTCAL SCAN COUNT
WPIAA   EQU     $C804   ;A INPUT                WIDGET-BRD INPUTS;
WCPIAA  EQU     $C805   ;A CONTROL      GAME CNTRLS, PLYR1 AND 2 STARTS
WPIAB   EQU     $C806   ;B INPUT
WCPIAB  EQU     $C807   ;B CONTROL
PIAA    EQU     $C80C   ;COIN DOOR,INTERRUPT,SOUND BRD PIA'S
CPIAA   EQU     $C80D   ;16MS CONTROL - CA1
PIAB    EQU     $C80E   ;SOUND BOARD OUTPUTS
CPIAB   EQU     $C80F   ;4MS CONTROL - CB1      B0=1 ENABLE  B0=0 DISABLE
;*WDOG  EQU     $CBFF   ;WATCHDOG CIRCUIT
DMA     EQU     $CA00   ;DMA CONTROL WORDS
KDMA    EQU     DMA+1   ; CONSTANT SUBSTITUTION
SDMA    EQU     DMA+2   ; SOURCE OF CHARACTER
DDMA    EQU     DMA+4   ; DESTINATION OF CHARACTER
WDMA    EQU     DMA+6   ; HORIZONTAL WIDTH (BIT 2 INVERTED)
HDMA    EQU     DMA+7   ; VERTICAL HEIGHT (BIT 2 INVERTED)
;*DMAFIX        EQU     $0404   ;DMA X,Y LENGTH BIT 2 INVERSION FOR CURRENT DMA FIX
        ORG     0
WCDMA   RMB     1       ;WRITE/CLEAR'S DMA CONTROL BYTE
WCCON   RMB     1       ;WRITE/CLEAR'S DMA CONSTANT BYTE
WCSRC   RMB     2       ;WRITE/CLEAR'S DMA SOURCE ADDRESS
WCDEST  RMB     0       ;WRITE/CLEAR'S DMA DESTINATION ADDRESS
WCX     RMB     1       ;WRITE/CLEAR'S DMA DESTINATION X PIXEL LOCATION
WCY     RMB     1       ;WRITE/CLEAR'S DMA DESTINATION Y PIXEL LOCATION
WCLEN   RMB     0       ;WRITE/CLEAR'S DMA X,Y LENGTH (NO INVERSION)
WCLENX  RMB     1       ;WRITE/CLEAR'S DMA X LENGTH (NO INVERSION)
WCLENY  RMB     1       ;WRITE/CLEAR'S DMA Y LENGTH (NO INVERSION)
;*
;*  DMA BITS: H,L,F,K Z,S,W,R
;*H-SUPRESS CONSTANT HIGH NIBBLE
;*L-SUPRESS CONSTANT LOW NIBBLE
;*F-FLAVOR RIGHT
;*K-REPLACE DATA WITH CONSTANT
;*Z-SUPRESS ZEROES
;*S-SLOW FOR RAM
;*W-WRITE       BLOCK
;*R-READ        BLOCK
;*
;*      SYSTEM OVERHEAD EQUATES
;*
PBLKM   EQU     40      ;NUMBER OF MAXIMUM PROCESSES THAT CAN EXIST
        ORG     $0      ;PROCESS BLOCK OFFSETS
PLINK   RMB     2       ;PROCESS OVERHEAD, LINK TO NXT PROC (IF=0 END LINK)
PID     RMB     1       ;   "      "      I.D. NBR (IF=0 NO PROCESS)
PPRI    RMB     1       ;   "       "     START LINK OF OBJECT(S) BLOCK
PNAP    RMB     1       ;   "      "      SLEEP TIME IF<>0
PPC     RMB     2       ;   "      "      PROCESSES PC COUNTER
PPOSX   RMB     3       ;PROCESS'S OBJECT X LOCATION (AND FRACTIONAL DISTANCE)
PPOSY   RMB     3       ;PROCESS'S OBJECT Y LOCATION (AND FRACTIONAL DISTANCE)
PRAML   EQU     43      ;NUMBER OF PROCESSES RAM BYTES
PRAM    RMB     PRAML   ;PROCESSES  EXCLUSIVE RAM
;*                              RAM 0, HI BYTE OF REG.Y (AT CREATION TIME)
;*                              RAM 1, LO BYTE OF REG.Y (AT CREATION TIME)
;*                              RAM 2, BYTE OF REG.B (AT CREATION TIME)
PBLKL   EQU     *               ;8 OVERHEAD BYTES + PROCESSES EXCLUSIVE RAM
;*
;*      JOUST OFFSETS
;*
        ORG     PRAM            ;NEW OFFSETS FROM PROCESSES RAM
PDECSN  RMB     2               ;JOYSTICK,SCORE, AND OTHER DECISION AREA
PFACE   RMB     1               ;0=RIGHT FACED, <>0=LEFT FACE
PFRAME  RMB     1               ;MAJOR FRAME ANIMATION NUMBER
PVELY   RMB     2               ;FACTIONAL SIGNED VELOCITY Y-DIRECTION
PTIMUP  RMB     1               ;TIME BETWEEN WING FLAPS
PVELX   RMB     1               ;TABLE LOOK-UP FLYING VELOCITY-X
PACCX   RMB     1               ;LAND'S ACCELERATION RATE
PTIMX   RMB     1               ;LAND'S TIME TILL NEXT FRAME
PIMAGE  RMB     1               ;PICTURES FRAME NUMBER
PHORSE  RMB     2               ;START ANIMATION OF HORSE(OSTRICH)
PRIDER  RMB     2               ;START ANIMATION OF RIDER
PPICH   RMB     2               ;PROCESSES LAST/CURRENT HORSE IMAGE PICTURE
PPICR   RMB     2               ;PROCESSES LAST/CURRENT RIDER IMAGE PICTURE
PSTATE  RMB     2               ;STATE OF PLAYER'S GROUND MOVEMENT (ADDRESS)
PBUMPX  RMB     1               ;BUMPING DELTA X
PBUMPY  RMB     1               ;BUMP REGISTER IN Y DIRECTION
PJOY    RMB     2               ;JOYSTICK SERVICE ROUTINE
PLANTZ  RMB     1               ;LANTZ OFFSET FOR SKIDDING
PCOLY1  RMB     1               ;COLISION DETECTS BOTTOM LINE OF ROUGH BOX
PCOLY2  RMB     1               ;COLISION DETECTS TOP LINE OF ROUGH BOX
PCOLX   RMB     2               ;COLISION DETECT RIGHT HAND SIDE OF COLISION
PDIST   RMB     2               ;ENEMY TRAGET DISTANCES (FOR EMEMY TRACKING)
PJOYT   RMB     1               ;FLIP/FLAP TIMES (FOR EMEMY TRACKING)
PRDIR   RMB     1               ;REVERSE DIRECTION COUNTER (FOR EMEMY TRACKING)
PPVELX  RMB     1               ;OLD PLAYERS X VELOCITY (FOR EMEMY TRACKING)
PADGRA  RMB     2               ;ADD GRAVITY ROUTINE (FLYING & LAVA TROLLS)
PLAVT   RMB     1               ;LAVA TROLL LOOKING TIME (FOR ENEMY TRACKING)
PEGG    RMB     1               ;EMEMIES NBR OF EGGS LEFT BEFORE TOTAL DEATH
PCHASE  RMB     1               ;ENEMIES CHASE (=1) OR NON-CHASE (=0) FLAG
PFEET   RMB     1               ;L.S.BIT INDICATES WHICH FOOT HORSE IS ON.
PNBR    EQU     *               ;NUMBER OF PROCESS RAM LOCATIONS
        IF PNBR-PBLKL > 0                                                       ;;Fixme was: IFGT       PNBR-PBLKL
         FCB    $1111           ;TOO FEW PROCESS RAM LOCATIONS
        ENDIF
;*
;*  SYSTEM RAM - SCRATCH PAD (BASE PAGE ADDRESSES)
;*
        ORG     BASE
DMABEG  RMB     2       ;BEGIN ADDR FOR QUADRANT A ERASE DMA TABLE (DTBL1,DTBL2)
        RMB     2       ;BEGIN ADDR FOR QUADRANT A WRITE DMA TABLE (DTBL1,DTBL2)
DMAEND  RMB     2       ;END ADDR FOR QUADRANT A ERASE DMA TABLE (DTBL1,DTBL2)
        RMB     2       ;END ADDR FOR QUADRANT A WRITE DMA TABLE (DTBL1,DTBL2)
PFREE   RMB     2       ;       START LIST OF FREE RAM BLOCKS FOR PROCESSES
PDUMMY  RMB     2       ;       DUMMY PROCESS LINK ADDR OF 1ST LINKED PROCESS
TIMER   RMB     1       ;60 CYCLE INTERUPT (BOTTOM OF SCREEN)
RANDOM  RMB     2       ;LAST RANDOM NUMBER
RAMCOL  RMB     16      ;A COPY OF THE CURRENT COLOR RAM VALUES
IRQSTK  RMB     2       ;IRQ'S NON-REENTERENT STACK POINTER SAVE AREA
ISQPTR  RMB     2       ;IRQ'S CURRENT DMA BLOCK'S SEQUENCED QUADRANT POINTER
ISQCNT  RMB     1       ;IRQ'S NEXT BEAM SEQUENCED QUADRANT TO UPDATE
DMAINT  RMB     1       ;INTERUPTS NEXT DMA TABLE IF>=0,DTBL1 IF<0,DTBL2
ITBL    RMB     2       ;INTERUPTS START QUADRANT ADDRESS IN TABLE (DTBL1,DTBL2)
DMAFOR  RMB     1       ;EXECS' NEXT DMA TABLE IF>=0,DTBL1 IF<0,DTBL2
DTBL    RMB     2       ;FOREGROUNDS START ADDRESS OF DMA TABLE (DTBL1,DTBL2)
DMAFRE  RMB     2       ;FOREGROUNDS NEXT FREE BLOCK OF DMA1 OR DMA2
PPREV   RMB     2       ;ADDR OF PREVIOUSLY EXECUTED PROCESS BLOCK
PEXEC   RMB     2       ;ADDR OF CURRENT EXECUTING PROCESS BLOCK
CLSX    RMB     1       ;CLASIFIED OBJECT'S X POSITION
CLSY    RMB     1       ;CLASIFIED OBJECT'S Y POSITION
CURJOY  RMB     2       ;STORE AREA TO REMEMBER LAST JOYSTICK OPERATION
COLDX   RMB     2       ;BACKGROUND COLISION DETECT PIXEL DELTA X
EGGS1   RMB     1       ;NUMBER OF EGGS PLAYER 1 HAS KILLED
EGGS2   RMB     1       ;NUMBER OF EGGS PLAYER 2 HAS KILLED
NPSERV  RMB     1       ;PLAYERS "TAKE A NUMBER" INPUT STACK FOR TRANSPORTER
LPSERV  RMB     1       ;PLAYERS "TAKE A NUMBER" NUMBER IN SERVICE FOR ".
NESERV  RMB     1       ;ENEMIES "TAKE A NUMBER" INPUT STACK FOR TRANSPORTER
LESERV  RMB     1       ;ENEMIES "TAKE A NUMBER" NUMBER IN SERVICE FOR ".
TRSMALL RMB     1       ;NBR WAVES LEFT BEFORE A SMALL SAFTEY TRANSPORTER ZONE
EGGNBR  RMB     1       ;QUE FOR EGG SCORE(S) TO OVERLAP IN ORDER OF COLLECTION
;*
         IF BASE+$40-* <= 0                                                     ;;Fixme was: IFLE       BASE+$40-*
          FCB   $1111   BASE+$40 OVERRUN!!!!
         ENDIF
        ORG     BASE+$40
DMABBE  RMB     2       ;BEGIN ADDR FOR QUADRANT B ERASE DMA TABLE (DTBL1,DTBL2)
        RMB     2       ;BEGIN ADDR FOR QUADRANT B WRITE DMA TABLE (DTBL1,DTBL2)
DMABEN  RMB     2       ;END ADDR FOR QUADRANT B ERASE DMA TABLE (DTBL1,DTBL2)
        RMB     2       ;END ADDR FOR QUADRANT B WRITE DMA TABLE (DTBL1,DTBL2)
;*
GRAV    RMB     1       ;GRAVITY FOR ALL PLAYERS
COLOBJ  RMB     2       ;COLISION DETECT OF OBJECT (SAVE AREA)
BCKRFS  RMB     1       ;BACKGROUND IMAGE REFRESH RAM CELL
SPLY1   RMB     4+1+1+1 ;PLYR #1 SCORE (4 BCD BYTES),SCORE OCCURED,NBR MEN LEFT
;*                      & AUX NUMBER OF MEN LEFT (FOR EARLY GAME OVER)
        RMB     1+2     ;BCD OFFSET FOR LEVEL PASS, & CURRENT BCD LEVEL TO PASS
SPLY2   RMB     4+1+1+1 ;PLYR #2 SCORE (4 BCD BYTES),SCORE OCCURED,NBR MEN LEFT
;*                      & AUX NUMBER OF MEN LEFT (FOR EARLY GAME OVER)
        RMB     1+2     ;BCD OFFSET FOR LEVEL PASS, & CURRENT BCD LEVEL TO PASS
NPLYRS  RMB     1       ;N-1 PLAYERS IN THE GAME
STMR    RMB     1       ;TIME LEFT TILL CURRENT SOUND IS COMPLETE
SPRI    RMB     1       ;LAST PIRORITY SOUND, -1,0,+1 (EASIEST TO HARDEST)
SNDPTR  RMB     2       ;NEXT SOUND CODE GROUP TO BE SEND TO SOUND BOARD(IF<>0)
PRISEC  RMB     1       ;IF=0 EXECUTING PRIMARY PROCESSES, ELSE SECONDARY PROC.
PSEC    RMB     2       ;LAST SECONDARY PROCESS EXECUTED
PDTBL   RMB     2       ;LAST DMA BUFFERED DATA BLOCK TABLE USED
STTR1   RMB     1       ;WORKSPACE FOR FINDING A FREE TRANSPORTER
STTR2   RMB     1       ;WORKSPACE FOR FINDING A FREE TRANSPORTER
STTR3   RMB     1       ;WORKSPACE FOR FINDING A FREE TRANSPORTER
STTR4   RMB     1       ;WORKSPACE FOR FINDING A FREE TRANSPORTER
CURTR1  RMB     1       ;IF<>0 THIS TRANSPORTER IS IN USE
CURTR2  RMB     1       ;IF<>0 THIS TRANSPORTER IS IN USE
CURTR3  RMB     1       ;IF<>0 THIS TRANSPORTER IS IN USE
CURTR4  RMB     1       ;IF<>0 THIS TRANSPORTER IS IN USE
TEMP    RMB     1       ;TEMPORARY LOCATION FOR "WRCLS"
TARPLY  RMB     2       ;TARGETED PLAYERS WORKSPACE
TARPL2  RMB     2       ;TARGETED PLAYERS WORKSPACE
NLIVES  RMB     1       ;NUMBER OF PLAYER 1 & 2 LIVES IN A GAME
;*
         IF BASE+$80-* <= 0                                                     ;;Fixme was: IFLE       BASE+$80-*
          FCB   $1111   ;RAM+$80 OVERRUN!!!!
         ENDIF
        ORG     BASE+$80
DMACBE  RMB     2       ;BEGIN ADDR FOR QUADRANT C ERASE DMA TABLE (DTBL1,DTBL2)
        RMB     2       ;BEGIN ADDR FOR QUADRANT C WRITE DMA TABLE (DTBL1,DTBL2)
DMACEN  RMB     2       ;END ADDR FOR QUADRANT C ERASE DMA TABLE (DTBL1,DTBL2)
        RMB     2       ;END ADDR FOR QUADRANT C WRITE DMA TABLE (DTBL1,DTBL2)
;*
AREA1   RMB     1       ;TOP AREA EMPTY FLAG FOR SELARE
AREA2   RMB     1       ;MIDDLE AREA EMPTY FLAG FOR SELARE
AREA3   RMB     1       ;BOTTOM AREA EMPTY FLAG FOR SELARE
SWDEB   RMB     1       ;DEBOUNCED SWITCHES IN THIER CURRENT STATE
SWTEMP  RMB     1       ;SWITCH DEBOUNCE TEMPORARY LOCATION
SWSLAM  RMB     1       ;SLAM SWITCH SLOPPY DEBOUNCE TO DISABLE COIN SWITCHES
NSMART  RMB     1       ;CURRENT NUMBER OF ATTACKING ENEMIES
WSMART  RMB     1       ;NUMBER OF ENEMIES THAT SHOULD ATTACK IN A WAVE
GOVER   RMB     1       ;0=GAME IN PROGRESS, $80=GAME OVER
COLX    RMB     2       ;DEBUG, COLISION DETECTS REG.X
COLU    RMB     2       ;DEBUG, COLISION DETECTS REG.U
LAVEMY  RMB     1       ;LAVA TROLL, NBR OF ENEMIES LEFT TO EAT
LAVNBR  RMB     1       ;LAVA TROLL, NBR OF ACTIVE LAVA TROLLS
LEVPAS  RMB     2       ;LEVEL PASS BCD AMOUNT, JUSTIFIED TO SCORE BYTES
MINUTE  RMB     2       ;INTERUPTS COUNTER FOR MINUTES OF GAME PLAY
SAFRAM  RMB     1       ;WANTED SCREEN LEVEL OF THE LAVA FOR THE LAVA PROCESS
SAFRM2  RMB     2       ;CURRENT SCREEN LEVEL OF THE LAVA FOR THE LAVA PROCESS
WAVBCD  RMB     1       ;CURRENT BCD WAVE NUMBER
TBRIDGE RMB     1       ;NBR OF WAVES LEFT TILL BRIDGE IS GONE                  ;;Fixme was: TBRIDG
TTROLL  RMB     1       ;NBR WAVES LEFT FOR LAVA TROLL TO ENTER (AFTER TBRIDG)
NENEMY  RMB     1       ;NBR OF ENEMIES ON THE SCREEN
WENEMY  RMB     1       ;MAX NBR OF ENEMIES FOR HATCHING SEQUENCE (SET IN WAVE)
PLYG1   RMB     1       ;GLADIATOR/TEAM WAVE NBR OF TIMES KILLED PLAYER 2
PLYG2   RMB     1       ;GLADIATOR/TEAM WAVE NBR OF TIMES KILLED PLAYER 1
PLYD1   RMB     1       ;NBR OF TIME PLAYER 1 DIED IN THE WAVE (SURVIVAL WAVE)
PLYD2   RMB     1       ;NBR OF TIME PLAYER 2 DIED IN THE WAVE (SURVIVAL WAVE)
TARTIM  RMB     1       ;MASTER DELAY BEFORE TARGETING THE PLAYER
TARTM1  RMB     1       ;CURRENT TIME LEFT (FOR "TARPLY") UNTIL FINDING PLAYER
TARTM2  RMB     1       ;CURRENT TIME LEFT (FOR "TARPL2") UNTIL FINDING PLAYER
NRIDER  RMB     1       ;NBR OF RIDERS (TOTAL ACTIVE/INACTIVE) LEFT IN THE WAVE
NBAIT   RMB     1       ;CURRENT NBR OF BAITERS ON THE SCREEN
DBAIT   RMB     1       ;A DELAY FOR REMOVAL OF BAITERS FROM THE SCREEN (IF<>0)
CBAIT   RMB     2       ;CURRENT TIME LEFT BEFORE BAITERS COME ONTO THE SCREEN
WPTER   RMB     1       ;CURRENT/LAST NUMBER OF PTERODACTYLS FOR PTER-WAVE
EMYTIM  RMB     1       ;PAUSE TIME BETWEEN ENEMIES MOVEMENTS
LXPOS2  RMB     2       ;FOR LAVA BUBBLES, AN X BYTE POSITION TABLE
CRDCHG  RMB     1       ;NON-ZERO INDICATES A COIN WAS DROPPED INTO COIN SLOT
SWT0    RMB     9       ;SWITCH DEBOUNCING STATES, T0,T1,T2,...,T8
;*
         IF BASE+$C0-* <= 0                                                     ;;Fixme was: IFLE       BASE+$C0-*
          FCB   $1111   ;BASE+$C0 OVERRUN!!!!
         ENDIF
        ORG     BASE+$C0
DMADBE  RMB     2       ;BEGIN ADDR FOR QUADRANT D ERASE DMA TABLE (DTBL1,DTBL2)
        RMB     2       ;BEGIN ADDR FOR QUADRANT D WRITE DMA TABLE (DTBL1,DTBL2)
DMADEN  RMB     2       ;END ADDR FOR QUADRANT D ERASE DMA TABLE (DTBL1,DTBL2)
        RMB     2       ;END ADDR FOR QUADRANT D WRITE DMA TABLE (DTBL1,DTBL2)
;*
;*      RAM TABLES
;*
        ORG     (*/256+1)*256   ;PUT TABLES ON A 1/4K BOUNDARY
PBLKST  RMB     PBLKM*PBLKL     ;PROCESS BLOCK START OF RAM
PBLKEN  EQU     *               ;PROCESS BLOCK END OF RAM
;*
DTBL1   RMB     1       ;STATUS OF DMA1, -1=INTERUPT USER, 0=EMPTY/BEING FILLED
;*                                      +1=READY FOR INTERUPT
DTBL1A  RMB     2       ;DMA BLOCK DATA WHILE BEAM IS IN QUADRANT B
DTBL1B  RMB     2       ;DMA BLOCK DATA WHILE BEAM IS IN QUADRANT C
DTBL1C  RMB     2       ;DMA BLOCK DATA WHILE BEAM IS IN QUADRANT D
DTBL1D  RMB     2       ;DMA BLOCK DATA WHILE BEAM IS IN QUADRANT A
DMA1    RMB     10*60   ;ONLY 60 DMA TRANSFERS PER SCREEN (8 DMA BYTES + LINK)
;*
DTBL2   RMB     1       ;STATUS OF DMA2, -1=INTERUPT USER, 0=EMPTY/BEING FILLED
;*                                      +1=READY FOR INTERUPT
DTBL2A  RMB     2       ;DMA BLOCK DATA WHILE BEAM IS IN QUADRANT B
DTBL2B  RMB     2       ;DMA BLOCK DATA WHILE BEAM IS IN QUADRANT C
DTBL2C  RMB     2       ;DMA BLOCK DATA WHILE BEAM IS IN QUADRANT D
DTBL2D  RMB     2       ;DMA BLOCK DATA WHILE BEAM IS IN QUADRANT A
DMA2    RMB     10*60   ;ONLY 60 DMA TRANSFERS PER SCREEN (8 DMA BYTES + LINK)
;
BCKXD1  RMB     $20     ;BACKGROUND COLISION AREA -$20 TO -$01
BCKXTB  RMB     $140    ;BACKGROUND COLISION AREA $00 TO $140
BCKXD2  RMB     0       ;END OF BACKGROUND COLISION AREA
;*
LNDXD1  RMB     $20     ;BACKGROUND LANDING AREA -$20 TO -$01
LNDXTB  RMB     $140    ;BACKGROUND LANDING AREA $00 TO $140
LNDXD2  RMB     0       ;END OF BACKGROUND LANDING AREA
;*
EGPTBL  RMB     69      ;NBR OF LOCATIONS ON ALL CLIFFS FOR AN EGG TO BE PLACED
EGLTBL  RMB     6       ;LEDGE COUNTER FOR RANDOM LEDGE ORDER
EGLEND  RMB     0       ; (FOR EGG WAVE)
;*
        RMB     32      ;FUDGE FACTOR SPACE
;*
DYNADJ  RMB     0       ;START OF DYNAMIC GAME ADJUSTMENTS
        rmb     1       ;       make the below byte into a word
LAVTIM  RMB     1+1     ;LAVA TROLL, FRAME TIME
LAVGRA  RMB     2+1     ;LAVA TROLL, GRAVITY FORCE TO OVERCOME
        rmb     1       ;       make the below byte into a word
LNTLAV  RMB     1+1     ;TIME INCREMENTS TO LOOK FOR A LAVA TROLL
        rmb     1       ;       make the below byte into a word
EGGWT   RMB     1+1     ;TIME TO WAIT BEFORE STARTING EGG HATCHIN SEQUENCE
        rmb     1       ;       make the below byte into a word
EGGWT2  RMB     1+1     ;TIME TO WAIT BEFORE STARTING EGG HATCHIN (EGG WAVES)
BODNRG  RMB     2+1     ;BOUNDAR, GOING DOWN SHORT/LONG RANGE LENGTH
BODNDI  RMB     2+1     ;BOUNDAR, GOING DOWN LONG RANGE DOWN DISTANCE
BODNVY  RMB     2+1     ;BOUNDAR, GOING DOWN MAXIMUM Y VELOCITY
BOUPRG  RMB     2+1     ;BOUNDAR, GOING UP SHORT/LONG RANGE LENGTH
BOUPDI  RMB     2+1     ;BOUNDAR, GOING UP LONG RANGE DOWN DISTANCE
        rmb     1       ;       make the below byte into a word
BOUPWD  RMB     1+1     ;BOUNDAR, GOING UP WING DOWN TIME
        rmb     1       ;       make the below byte into a word
BOUPWU  RMB     1+1     ;BOUNDAR, GOING DOWN WING DOWN TIME
        rmb     1       ;       make the below byte into a word
BOLETM  RMB     1+1     ;BOUNDAR, "LEVEL" FLIGHT UNTIL NEXT DECISION
HUDNRG  RMB     2+1     ;HUNTER, GOING DOWN SHORT/LONG RANGE LENGTH
HUDNDI  RMB     2+1     ;HUNTER, GOING DOWN LONG RANGE DOWN DISTANCE
HUDNVY  RMB     2+1     ;HUNTER, GOING DOWN MAXIMUM Y VELOCITY
HUUPRG  RMB     2+1     ;HUNTER, GOING UP SHORT/LONG RANGE LENGTH
HUUPDI  RMB     2+1     ;HUNTER, GOING UP LONG RANGE DOWN DISTANCE
        rmb     1       ;       make the below byte into a word
HUUPWD  RMB     1+1     ;HUNTER, GOING UP WING DOWN TIME
        rmb     1       ;       make the below byte into a word
HUUPWU  RMB     1+1     ;HUNTER, GOING DOWN WING DOWN TIME
HUUPVY  RMB     2+1     ;HUNTER, MAXIMUM GOING UP VELOCITY
        rmb     1       ;       make the below byte into a word
HULETM  RMB     1+1     ;HUNTER, "LEVEL" FLIGHT UNTIL NEXT DECISION
SHDNRG  RMB     2+1     ;SHADOW LORD, GOING DOWN SHORT/LONG RANGE LENGTH
SHUPRG  RMB     2+1     ;SHADOW LORD, GOING UP SHORT/LONG RANGE LENGTH
SHUPVY  RMB     2+1     ;SHADOW LORD, GOING UP VELOCITY
        rmb     1       ;       make the below byte into a word
SHUPTM  RMB     1+1     ;SHADOW LORD, SHORT RANGE GOING UP TIME
        rmb     1       ;       make the below byte into a word
SHLETM  RMB     1+1     ;SHADOW LORD, LEVEL FLIGHT TIME TILL NEXT DECISION
        rmb     1       ;       make the below byte into a word
SHCLTM  RMB     1+1     ;SHADOW LORD, "AVOIDING CLIFF" FLAP TIME
DYNEND  RMB     0       ;END OF DYNAMIC GAME ADJUSTS
;*
ENDRAM  EQU     *       ;END ADDRESS OF RAM