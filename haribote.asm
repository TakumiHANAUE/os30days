; haribote-os
; TAB=4

; BOOT_INFO
CYLS    EQU     0x0ff0          ; ブートセクタが設定する
LEDS    EQU     0x0ff1
VMODE   EQU     0x0ff2          ; 何ビットカラーか
SCRNX   EQU     0x0ff4          ; 解像度のX
SCRNY   EQU     0x0ff6          ; 解像度のY
VRAM    EQU     0x0ff8          ; グラフィックバッファの開始番地

    ORG     0xc200

    MOV     AL, 0x13            ; VGAグラフィックス 320 x 200 x 8bit カラー
    MOV     AH, 0x00
    INT     0x10
    MOV     BYTE    [VMODE], 8
    MOV     WORD    [SCRNX], 320
    MOV     WORD    [SCRNY], 200
    MOV     DWORD   [VRAM], 0x000a0000

; キーボードのLED状態をBIOSに教えてもらう

    MOV     AH, 0x02
    INT     0x16                ; keyboard BIOS
    MOV     [LEDS], AL

fin:
    HLT
    JMP     fin