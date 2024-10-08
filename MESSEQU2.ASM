CEND    EQU     $80                                     ;;Fixme was: END (renamed to avoid confusion with END instruction)
C0      EQU     $00
C1      EQU     $01
C2      EQU     $02
C3      EQU     $03
C4      EQU     $04
C5      EQU     $05
C6      EQU     $06
C7      EQU     $07
C8      EQU     $08
C9      EQU     $09
CSPC    EQU     $0A
CA      EQU     $0B
CB      EQU     $0C
CC      EQU     $0D
CD      EQU     $0E
CE      EQU     $0F
CF      EQU     $10
CG      EQU     $11
CH      EQU     $12
CI      EQU     $13
CJ      EQU     $14
CK      EQU     $15
CL      EQU     $16
CM      EQU     $17
CN      EQU     $18
CO      EQU     $19
CP      EQU     $1A
CQ      EQU     $1B
CR      EQU     $1C
CS      EQU     $1D
CT      EQU     $1E
CU      EQU     $1F
CV      EQU     $20
CW      EQU     $21
CX      EQU     $22
CY      EQU     $23
CZ      EQU     $24
CBARRW  EQU     $25
CEQU    EQU     $26
CDSH    EQU     $27
CQUE    EQU     $28
CEXC    EQU     $29
CBRKL   EQU     $2A
CBRKR   EQU     $2B
CSQOT   EQU     $2C
CCMMA   EQU     $2D
CPER    EQU     $2E

;**** OFFSETS FOR SMALL FONT SPECIAL ****
CTHOU   EQU     $2F     ;SMALL FONT ONLY!!!!
CCURSR  EQU     $30

;**** OFFSETS FOR LARGE FONT SPECIAL ****
CSLSH   EQU     $2F
CAMP    EQU     $30
CDQOT   EQU     $31
CCOLN   EQU     $32
CCURS   EQU     $33
CCNARW  EQU     $34


;*****  TEXT EQUATES   *****

TXROMK  EQU     $00    ;'ALL ROMS OK','RAM TEST FOLLOWS','PRESS ADVANCE TO EXIT'
TXRAMK  EQU     $01     ;'NO RAM ERRORS DETECTED'
TXCMOK  EQU     $02     ;'NO CMOS RAM ERRORS DETECTED'
TXCMER  EQU     $03     ;'CMOS RAM ERROR'
TXCMDR  EQU     $04     ;'CMOS RAM ERROR','OR WRITE PROTECT FAILURE','.....'
TXCMT   EQU     $05     ;'COLOR RAM TEST','VERTICAL BARS INDICATE ERROR'
TXSWTS  EQU     $06     ;'SWITCH TEST'
TXBOOK  EQU     $07     ;'BOOKKEEPING TOTALS'
TXADJT  EQU     $08     ;'GAME ADJUSTMENTS'
TXBADJ  EQU     $09     ;'USE 'PLAYER 1 MOVE' TO SELECT ADJUSTMENT'
;*                      ;'USE 'PLAYER 2 MOVE' TO CHANGE THE VALUE'
;*                      ;'PRESS ADVANCE TO EXIT'
TXSETA  EQU     $0A     ;'SET ATTRACT MODE MESSAGE'
;*                      ;'USE 'PLAYER 1 MOVE' TO SELECT LETTER'
;*                      ;'USE 'PLAYER 1 FLAP' TO ENTER'
TXIMES  EQU     $0B     ;'ADJUSTMENT FAILURE'
;*                      ;'RESTORE FACTORY SETTINGS'
;*                      ;'BY OPENING FRONT DOOR OR TABLE TOP'
;*                      ;'AND TURNING GAME ON AND OFF'
TXREST  EQU     $0C     ;'FACTORY SETTINGS RESTORED'
TXBKRS  EQU     $0D     ;'BOOKKEEPING TOTALS CLEARED'
TXRESM  EQU     $0E     ;'HIGH SCORE TABLE RESET'
TXHSP   EQU     $0F     ;'DAILY BUZZARDS'
;*                      ;'JOUST CHAMPIONS'
TXSETG  EQU     $10     ;'SET HIGHEST SCORE NAME'
;*                      ;'USE 'PLAYER 1 MOVE' TO SELECT LETTER'
;*                      ;'USE 'PLAYER 1 FLAP' TO ENTER'
ATX1    EQU     $11     ;'WELCOME TO JOUST'
ATX2    EQU     $12     ;'TO FLY,'
;*                      ;'REPEATEDLY PRESS 'FLAP' BUTTON'
ATX3    EQU     $13     ;'TO SURVIVE A JOUST
;*                      ;'THE HIGHEST LANCE WINS'
;*                      ;'IN A COLLISION'
ATX4    EQU     $14     ;'PICK UP THE EGGS'
;*                      ;'BEFORE THEY HATCH'
ATX5    EQU     $15     ;'MEET THY ENEMIES'
ATX6    EQU     $16     ;'BOUNDER (500)'
ATX7    EQU     $17     ;'HUNTER (750)'
ATX8    EQU     $18     ;'SHADOW LORD (1500)'
ATX9    EQU     $19     ;'PRESS 1 PLAYER TO START'
;*                      ;'OR'
;*                      ;'INSERT ADDITIONAL COIN FOR'
;*                      ;'2 PLAYER EXCITMENT'
ATX10   EQU     $1A     ;'READY FOR 2 PLAYER'
;*                      ;'JOUST'
ATX11   EQU     $1B     ;'BEWARE OF THE "UNBEATABLE?" PTERADACTYL'
ATX12   EQU     $1C     ;'THIS IS JOUST'                                        ;;This is unused?
;*                      ;'DESIGNED BY WILLIAMS ELECTRONICS INC.'
;*                      ;'(C) 1982 WILLIAMS ELECTRONICS INC.'
;*                      ;'ALL RIGHTS RESERVED'
ATX13   EQU     $1D     ;'TEMPORARY SAFTEY'
;*                      ;'UNTIL A CONTROL IS PRESSED'