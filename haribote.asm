; haribote-os
; TAB=4

    ORG     0xc200

    MOV     AL, 0x13            ; VGAグラフィックス 320 x 200 x 8bit カラー
    MOV     AH, 0x00
    INT     0x10

fin:
    HLT
    JMP     fin