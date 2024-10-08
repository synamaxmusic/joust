;;
;;   Decoder ROMs 4 and 6 are needed to run Joust and Sinistar.
;;   Without these, MAME will fail to load the game.
;;
;;   While these files are easy to find online, I wanted to add
;;   them to the source code repositories for completeness sake.
;;
;;----------------------------------------------------------------------
;;
;;   To build your own Decoder roms, type in the following into a
;;   command prompt/terminal:
;;
;;   asl decoder_roms.asm -o decoder.p
;;
;;   Then use P2BIN to generate the two separate decoder roms:
;;
;;   p2bin decoder.p decoder_rom_4.3g -r $0000-$01FF
;;   p2bin decoder.p decoder_rom_6.3c -r $0200-$03FF

        CPU     6809                                                    ;;This is for {AS} so we can use the FCB instruction.
        RADIX   16

;;Decoder ROM 4 ($000-$1FF)

        ORG     0

DECODE4
        FCB     81,02,42,82,03,43,83,04,44,84,05,45,85,06,46,86
        FCB     07,47,87,08,48,88,09,49,89,0A,4A,8A,0B,4B,8B,0C
        FCB     4C,8C,0D,4D,8D,0E,4E,8E,0F,4F,8F,10,50,90,11,51
        FCB     91,12,52,92,13,53,93,14,54,94,15,55,95,16,56,96
        FCB     17,57,97,18,58,98,19,59,99,1A,5A,9A,1B,5B,9B,1C
        FCB     5C,9C,1D,5D,9D,1E,5E,9E,1F,5F,9F,20,60,A0,21,61
        FCB     A1,22,62,A2,23,63,A3,24,64,A4,25,65,A5,26,66,A6
        FCB     27,67,A7,28,68,A8,29,69,A9,2A,6A,AA,2B,6B,AB,2C
        FCB     6C,AC,2D,6D,AD,2E,6E,AE,2F,6F,AF,30,70,B0,31,71
        FCB     B1,32,72,B2,33,73,B3,34,74,B4,35,75,B5,36,76,B6
        FCB     37,77,B7,38,78,B8,39,79,B9,3A,7A,BA,3B,7B,BB,3C
        FCB     7C,BC,3D,7D,BD,3E,7E,BE,3F,7F,BF,00,40,80,01,41
        FCB     C3,CF,D0,D9,D2,C9,C7,C8,D4,80,A8,C3,A9,80,B1,B9
        FCB     B8,B1,80,D7,C9,CC,CC,C9,C1,CD,D3,80,C5,CC,C5,C3
        FCB     D4,D2,CF,CE,C9,C3,D3,80,C9,CE,C3,AE,80,C1,CC,CC
        FCB     80,D2,C9,C7,C8,D4,D3,80,D2,C5,D3,C5,D2,D6,C5,C4
        FCB     34,B3,73,33,B2,72,32,B1,71,31,B0,70,30,AF,6F,2F
        FCB     AE,6E,2E,AD,6D,2D,AC,6C,2C,AB,6B,2B,AA,6A,2A,A9
        FCB     69,29,A8,68,28,A7,67,27,A6,66,26,A5,65,25,A4,64
        FCB     24,A3,63,23,A2,62,22,A1,61,21,A0,60,20,9F,5F,1F
        FCB     9E,5E,1E,9D,5D,1D,9C,5C,1C,9B,5B,1B,9A,5A,1A,99
        FCB     59,19,98,58,18,97,57,17,96,56,16,95,55,15,94,54
        FCB     14,93,53,13,92,52,12,91,51,11,90,50,10,8F,4F,0F
        FCB     8E,4E,0E,8D,4D,0D,8C,4C,0C,8B,4B,0B,8A,4A,0A,89
        FCB     49,09,88,48,08,87,47,07,86,46,06,85,45,05,84,44
        FCB     04,83,43,03,82,42,02,81,74,B4,35,75,B5,36,76,B6
        FCB     37,77,B7,38,78,B8,39,79,B9,3A,7A,BA,3B,7B,BB,3C
        FCB     7C,BC,3D,7D,BD,3E,7E,BE,3F,7F,BF,00,40,80,01,41
        FCB     C3,CF,D0,D9,D2,C9,C7,C8,D4,80,A8,C3,A9,80,B1,B9
        FCB     B8,B1,80,D7,C9,CC,CC,C9,C1,CD,D3,80,C5,CC,C5,C3
        FCB     D4,D2,CF,CE,C9,C3,D3,80,C9,CE,C3,AE,80,C1,CC,CC
        FCB     80,D2,C9,C7,C8,D4,D3,80,D2,C5,D3,C5,D2,D6,C5,C4

;;Decoder ROM 6 ($200-$3FF)

DECODE6_TABLE1
        FCB     00,00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E
        FCB     0F,10,11,12,13,14,15,16,17,18,19,1A,1B,1C,1D,1E
        FCB     1F,20,21,22,23,24,25,26,27,28,29,2A,2B,2C,2D,2E
        FCB     2F,30,31,32,33,34,35,36,37,38,39,3A,3B,3C,3D,3E
        FCB     3F,40,41,42,43,44,45,46,47,48,49,4A,4B,4C,4D,4E
        FCB     4F,50,51,52,53,54,55,56,57,58,59,5A,5B,5C,5D,5E
        FCB     5F,60,61,62,63,64,65,66,67,68,69,6A,6B,6C,6D,6E
        FCB     6F,70,71,72,73,74,75,76,77,78,79,7A,7B,7C,7D,7E
        FCB     7F,80,81,82,83,84,85,86,87,88,89,8A,8B,8C,8D,8E
        FCB     8F,90,91,92,93,94,95,96,97,98,99,9A,9B,9C,9D,9E
        FCB     9F,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,AA,AB,AC,AD,AE
        FCB     AF,B0,B1,B2,B3,B4,B5,B6,B7,B8,B9,BA,BB,BC,BD,BE
        FCB     BF,C0,C1,C2,C3,C4,C5,C6,C7,C8,C9,CA,CB,CC,CD,CE
        FCB     CF,D0,D1,D2,D3,D4,D5,D6,D7,D8,D9,DA,DB,DC,DD,DE
        FCB     DF,E0,E1,E2,E3,E4,E5,E6,E7,E8,E9,EA,EB,EC,ED,EE
        FCB     EF,F0,F1,F2,F3,F4,F5,F6,F7,00,00,00,00,00,00,00

DECODE6_TABLE2 ;;(Mirrored)
        FCB     00,00,00,00,00,00,00,F7,F6,F5,F4,F3,F2,F1,F0,EF
        FCB     EE,ED,EC,EB,EA,E9,E8,E7,E6,E5,E4,E3,E2,E1,E0,DF
        FCB     DE,DD,DC,DB,DA,D9,D8,D7,D6,D5,D4,D3,D2,D1,D0,CF
        FCB     CE,CD,CC,CB,CA,C9,C8,C7,C6,C5,C4,C3,C2,C1,C0,BF
        FCB     BE,BD,BC,BB,BA,B9,B8,B7,B6,B5,B4,B3,B2,B1,B0,AF
        FCB     AE,AD,AC,AB,AA,A9,A8,A7,A6,A5,A4,A3,A2,A1,A0,9F
        FCB     9E,9D,9C,9B,9A,99,98,97,96,95,94,93,92,91,90,8F
        FCB     8E,8D,8C,8B,8A,89,88,87,86,85,84,83,82,81,80,7F
        FCB     7E,7D,7C,7B,7A,79,78,77,76,75,74,73,72,71,70,6F
        FCB     6E,6D,6C,6B,6A,69,68,67,66,65,64,63,62,61,60,5F
        FCB     5E,5D,5C,5B,5A,59,58,57,56,55,54,53,52,51,50,4F
        FCB     4E,4D,4C,4B,4A,49,48,47,46,45,44,43,42,41,40,3F
        FCB     3E,3D,3C,3B,3A,39,38,37,36,35,34,33,32,31,30,2F
        FCB     2E,2D,2C,2B,2A,29,28,27,26,25,24,23,22,21,20,1F
        FCB     1E,1D,1C,1B,1A,19,18,17,16,15,14,13,12,11,10,0F
        FCB     0E,0D,0C,0B,0A,09,08,07,06,05,04,03,02,01,00,00